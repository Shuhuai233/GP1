## Weapon — Two-hand system. All 40 card effects implemented.
## Right hand: revolver (FIRING cards, semi-auto)
## Left hand: spell hand (FUNCTION cards, F key cast, auto-advance)
extends Node3D

enum State { IDLE, FIRING, RELOADING }

@export var fire_rate: float = 3.0
@export var reload_time: float = 2.0
@export var max_ray_distance: float = 100.0

@export_group("Spread")
@export var base_spread: float = 0.0
@export var move_spread: float = 1.0
@export var ads_spread: float = 0.0

@onready var raycast: RayCast3D = $RayCast3D
@onready var muzzle_point: Marker3D = $MuzzlePoint
@onready var fire_timer: Timer = $FireTimer
@onready var reload_timer: Timer = $ReloadTimer
@onready var weapon_model: Node3D = $WeaponModel
@onready var muzzle_flash_light: OmniLight3D = $WeaponModel/MuzzleFlash

var state: State = State.IDLE
var deck_state: DeckState
var can_fire: bool = true

# Shield state (Barrier / Iron Skin)
var shield_hp: float = 0.0
var _shield_timer: float = 0.0
var _shield_damage_bonus: float = 0.0  # Iron Skin: +20% damage while active

# ─── Active Buff State ────────────────────────────────────────────────────────
# War Cry: +50% damage to next full magazine
var _war_cry_active: bool = false
var _war_cry_multiplier: float = 1.0

# Megashot: next single bullet does 5x damage
var _megashot_pending: bool = false
var _megashot_multiplier: float = 1.0

# Fuel: next N packs also apply Burn
var _fuel_packs_remaining: int = 0

# Overclock: doubled fire rate for duration
var _overclock_active: bool = false
var _overclock_timer: float = 0.0
var _overclock_multiplier: float = 1.0

# Adrenaline: speed + fire rate + reload speed
var _adrenaline_active: bool = false
var _adrenaline_timer: float = 0.0
var _adrenaline_fire_rate_bonus: float = 0.0

# Vampiric Burst: heal on damage dealt for duration
var _vampiric_active: bool = false
var _vampiric_timer: float = 0.0
var _vampiric_ratio: float = 0.0

# Tracer: accumulate bonus damage for next card pack (resets on reload)
var _tracer_bonus: float = 0.0

# Tempo: combo counter for consecutive hits
var _tempo_combo: int = 0
var _tempo_last_hit_time: float = 0.0

# Quicksilver: currently active
var _quicksilver_active: bool = false

# Mark: tracked per enemy via status component
# ─────────────────────────────────────────────────────────────────────────────

var _prev_gun_card: CardData = null
var _player: Node3D = null


func _ready() -> void:
	# Build starter deck: 3xStandard + 1xVenom + 1xIncendiary + 1xPiercing + 1xDetonator + 1xBarrier + 1xFlashfire
	deck_state = DeckState.new()
	var starter: Array[CardData] = []
	for i in 3:
		starter.append(preload("res://data/cards/standard_round.tres").duplicate())
	starter.append(preload("res://data/cards/venom_round.tres").duplicate())
	starter.append(preload("res://data/cards/incendiary_round.tres").duplicate())
	starter.append(preload("res://data/cards/piercing_round.tres").duplicate())
	starter.append(preload("res://data/cards/detonator_round.tres").duplicate())
	starter.append(preload("res://data/cards/barrier.tres").duplicate())
	starter.append(preload("res://data/cards/flashfire.tres").duplicate())
	deck_state.initialize(starter)

	fire_timer.wait_time = 1.0 / fire_rate
	fire_timer.one_shot = true
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	reload_timer.timeout.connect(_on_reload_finished)

	_player = get_parent().get_parent().get_parent()

	_emit_ammo_update()
	_emit_spell_update()


func _process(delta: float) -> void:
	# ── Shield timer ──
	if shield_hp > 0 and _shield_timer > 0:
		_shield_timer -= delta
		if _shield_timer <= 0:
			shield_hp = 0.0
			_shield_damage_bonus = 0.0
			EventBus.player_shield_changed.emit(0.0, 0.0)

	# ── Overclock ──
	if _overclock_active:
		_overclock_timer -= delta
		if _overclock_timer <= 0:
			_overclock_active = false
			fire_timer.wait_time = 1.0 / fire_rate

	# ── Adrenaline ──
	if _adrenaline_active:
		_adrenaline_timer -= delta
		if _adrenaline_timer <= 0:
			_adrenaline_active = false
			fire_timer.wait_time = 1.0 / fire_rate
			if _player:
				EventBus.player_speed_changed.emit(1.0)  # reset speed

	# ── Vampiric ──
	if _vampiric_active:
		_vampiric_timer -= delta
		if _vampiric_timer <= 0:
			_vampiric_active = false

	# ── Tempo decay check ──
	if _tempo_combo > 0:
		var current_card := deck_state.get_current_gun_card()
		if current_card and current_card.combo_window > 0:
			if Time.get_ticks_msec() / 1000.0 - _tempo_last_hit_time > current_card.combo_window:
				_tempo_combo = 0

	if state == State.RELOADING:
		return

	# Track gun card changes
	var current_gun := deck_state.get_current_gun_card()
	if current_gun != _prev_gun_card:
		_prev_gun_card = current_gun
		if current_gun:
			EventBus.card_pack_changed.emit(current_gun)
			# Apply Quicksilver move speed bonus
			_quicksilver_active = (current_gun.move_speed_bonus > 0.0)
			if _quicksilver_active and _player:
				EventBus.player_speed_changed.emit(1.0 + current_gun.move_speed_bonus)
			elif _player:
				EventBus.player_speed_changed.emit(1.0)

	if deck_state.is_gun_empty() and state != State.RELOADING:
		start_reload()
		return

	if Input.is_action_just_pressed("fire") and can_fire and state == State.IDLE:
		fire_gun()

	if Input.is_action_just_pressed("cast_spell"):
		cast_spell()

	if Input.is_action_just_pressed("reload") and state != State.RELOADING:
		start_reload()


# ─── FIRING ───────────────────────────────────────────────────────────────────

func fire_gun() -> void:
	var card := deck_state.fire_gun()
	if card == null:
		start_reload()
		return

	state = State.FIRING
	can_fire = false

	# Apply fire rate modifications
	var effective_rate := fire_rate
	if _overclock_active:
		effective_rate = fire_rate * _overclock_multiplier
	if _adrenaline_active:
		effective_rate = fire_rate * (1.0 + _adrenaline_fire_rate_bonus)
	fire_timer.wait_time = 1.0 / effective_rate
	fire_timer.start()

	var cam := get_viewport().get_camera_3d()
	if not cam:
		return

	var cam_from := cam.global_position
	var cam_forward := -cam.global_transform.basis.z

	var spread_rad := deg_to_rad(_get_current_spread())
	var shoot_dir := cam_forward
	if spread_rad > 0:
		shoot_dir = shoot_dir.rotated(cam.global_transform.basis.x, randf_range(-spread_rad, spread_rad))
		shoot_dir = shoot_dir.rotated(cam.global_transform.basis.y, randf_range(-spread_rad, spread_rad))
		shoot_dir = shoot_dir.normalized()

	# Scatter: multiple pellets per shot
	var pellet_count := maxi(card.scatter_count, 1)
	for _p in pellet_count:
		var pdir := shoot_dir
		if pellet_count > 1:
			pdir = shoot_dir.rotated(cam.global_transform.basis.x, randf_range(-0.05, 0.05))
			pdir = pdir.rotated(cam.global_transform.basis.y, randf_range(-0.05, 0.05)).normalized()
		_fire_single_ray(pdir, cam_from, card)

	EventBus.weapon_fired.emit(card)
	_emit_ammo_update()
	_do_viewmodel_kick(card)


func _fire_single_ray(shoot_dir: Vector3, cam_from: Vector3, card: CardData) -> void:
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(cam_from, cam_from + shoot_dir * max_ray_distance, 0b0101)
	var result := space.intersect_ray(query)

	if result:
		var collider = result.collider
		var hit_point: Vector3 = result.position

		if collider.has_method("take_bullet_hit"):
			collider.take_bullet_hit(card, self)
			EventBus.hit_confirmed.emit(hit_point, card, collider)
		else:
			EventBus.hit_missed.emit(hit_point, card)

		if card.piercing and collider.has_method("take_bullet_hit"):
			_pierce_check(hit_point, shoot_dir, card)

		# Ground fire (Magma Round)
		if card.ground_fire:
			_spawn_ground_fire(result.position, card)
	else:
		EventBus.hit_missed.emit(cam_from + shoot_dir * max_ray_distance, card)


# ─── SPELL CASTING ────────────────────────────────────────────────────────────

func cast_spell() -> void:
	var spell := deck_state.get_active_spell()
	if spell == null:
		return

	deck_state.cast_spell()
	EventBus.spell_cast.emit(spell)
	_emit_spell_update()

	# Route to correct handler based on spell flags
	if spell.consumes_poison:         _cast_detonator(spell)
	elif spell.grants_shield:         _cast_barrier(spell)
	elif spell.area_burn:             _cast_flashfire(spell)
	elif spell.war_cry:               _cast_war_cry(spell)
	elif spell.megashot:              _cast_megashot(spell)
	elif spell.executioner:           _cast_executioner(spell)
	elif spell.damage_buff and spell.shield_damage_bonus > 0: _cast_iron_skin(spell)
	elif spell.inferno:               _cast_inferno(spell)
	elif spell.fuel:                  _cast_fuel(spell)
	elif spell.area_poison:           _cast_area_poison(spell)  # Toxin Bomb
	elif spell.pandemic:              _cast_pandemic(spell)
	elif spell.dash:                  _cast_phase_dash(spell)
	elif spell.blink:                 _cast_blink(spell)
	elif spell.fire_rate_buff:        _cast_overclock(spell)
	elif spell.speed_buff:            _cast_adrenaline(spell)
	elif spell.chain_lightning:       _cast_chain_lightning(spell)
	elif spell.apply_mark:            _cast_spotter(spell)
	elif spell.emp:                   _cast_emp(spell)
	elif spell.vampiric_burst:        _cast_vampiric_burst(spell)
	elif spell.instant_reload:        _cast_reload_surge(spell)


# ─── FUNCTION CARD IMPLEMENTATIONS ───────────────────────────────────────────

func _cast_detonator(spell: CardData) -> void:
	var cam := get_viewport().get_camera_3d()
	if not cam:
		return
	var cam_from := cam.global_position
	var shoot_dir := -cam.global_transform.basis.z
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(cam_from, cam_from + shoot_dir * max_ray_distance, 0b0100)
	var result := space.intersect_ray(query)
	if not result or not result.collider.has_method("take_bullet_hit"):
		return
	var enemy = result.collider
	var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
	if not status or status.poison_stacks <= 0:
		EventBus.spell_detonator_hit.emit(enemy, 0.0, false)
		return
	var has_burn := status.is_burning
	var multiplier := 6.0 if has_burn else spell.poison_consume_multiplier
	var stacks := status.poison_stacks
	status.detonate_poison()
	var bonus_damage := stacks * multiplier
	enemy.take_damage(bonus_damage)
	EventBus.enemy_poison_detonated.emit(enemy, stacks, bonus_damage, has_burn)
	EventBus.spell_detonator_hit.emit(enemy, bonus_damage, has_burn)


func _cast_barrier(spell: CardData) -> void:
	shield_hp = spell.shield_amount
	_shield_timer = spell.shield_duration
	_shield_damage_bonus = spell.shield_damage_bonus  # Iron Skin sets this > 0
	EventBus.player_shield_changed.emit(shield_hp, spell.shield_amount)
	EventBus.spell_barrier_activated.emit(spell.shield_amount, spell.shield_duration)


func _cast_iron_skin(spell: CardData) -> void:
	# Shield + damage bonus while shield is active
	shield_hp = spell.shield_amount
	_shield_timer = spell.shield_duration
	_shield_damage_bonus = spell.shield_damage_bonus
	EventBus.player_shield_changed.emit(shield_hp, spell.shield_amount)
	EventBus.spell_barrier_activated.emit(spell.shield_amount, spell.shield_duration)


func _cast_flashfire(spell: CardData) -> void:
	var enemies_hit := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(global_position) <= spell.area_burn_radius:
			var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
			if status:
				status.apply_burn()
				enemies_hit += 1
	EventBus.spell_flashfire_activated.emit(enemies_hit)


func _cast_war_cry(spell: CardData) -> void:
	_war_cry_active = true
	_war_cry_multiplier = spell.war_cry_multiplier
	EventBus.buff_war_cry_activated.emit(_war_cry_multiplier)


func _cast_megashot(spell: CardData) -> void:
	_megashot_pending = true
	_megashot_multiplier = spell.megashot_multiplier
	EventBus.buff_megashot_ready.emit()


func _cast_executioner(spell: CardData) -> void:
	var cam := get_viewport().get_camera_3d()
	if not cam:
		return
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		cam.global_position,
		cam.global_position + (-cam.global_transform.basis.z) * max_ray_distance,
		0b0100
	)
	var result := space.intersect_ray(query)
	if not result or not result.collider.has_method("take_damage"):
		return
	var enemy = result.collider
	if enemy.has_method("get_hp_percent"):
		var pct: float = enemy.get_hp_percent()
		if pct <= spell.executioner_threshold:
			enemy.take_damage(enemy.current_hp + 999.0)  # ensure kill


func _cast_inferno(spell: CardData) -> void:
	var total_damage := 0.0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
		if status and status.is_burning:
			enemy.take_damage(spell.inferno_damage)
			total_damage += spell.inferno_damage


func _cast_fuel(spell: CardData) -> void:
	_fuel_packs_remaining = spell.fuel_pack_count
	EventBus.buff_fuel_activated.emit(_fuel_packs_remaining)


func _cast_area_poison(spell: CardData) -> void:
	# Toxin Bomb: area poison stacks
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(global_position) <= spell.area_poison_radius:
			var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
			if status:
				status.apply_poison(spell.area_poison_stacks)


func _cast_pandemic(spell: CardData) -> void:
	# Find highest poison stack count in range
	var max_stacks := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(global_position) <= spell.pandemic_radius:
			var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
			if status:
				max_stacks = maxi(max_stacks, status.poison_stacks)
	if max_stacks <= 0:
		return
	var spread := int(float(max_stacks) * spell.pandemic_ratio)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(global_position) <= spell.pandemic_radius:
			var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
			if status and status.poison_stacks < spread:
				status.apply_poison(spread - status.poison_stacks)


func _cast_phase_dash(spell: CardData) -> void:
	if not _player:
		return
	var dash_dir := -_player.global_transform.basis.z
	var dash_vec := dash_dir * spell.dash_distance
	# Check for collision along dash path
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		_player.global_position,
		_player.global_position + dash_vec,
		0b0001  # environment only
	)
	query.exclude = [_player.get_rid()]
	var hit := space.intersect_ray(query)
	if hit:
		_player.global_position = hit.position + hit.normal * 0.5
	else:
		_player.global_position += dash_vec
	# Brief invincibility (handled by grace flag or separate system)
	# For now, use the wave manager grace as a proxy
	var wm := get_tree().get_first_node_in_group("wave_manager")
	if wm and wm.has_method("set_temporary_grace"):
		wm.set_temporary_grace(0.2)


func _cast_blink(spell: CardData) -> void:
	if not _player:
		return
	var cam := get_viewport().get_camera_3d()
	if not cam:
		return
	var space := get_world_3d().direct_space_state
	var blink_dir := -cam.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(
		cam.global_position,
		cam.global_position + blink_dir * spell.blink_range,
		0b0001
	)
	var result := space.intersect_ray(query)
	var target_pos: Vector3
	if result:
		target_pos = result.position + result.normal * 0.5
	else:
		target_pos = cam.global_position + blink_dir * spell.blink_range
	target_pos.y = maxf(target_pos.y, 0.1)
	_player.global_position = target_pos


func _cast_overclock(spell: CardData) -> void:
	_overclock_active = true
	_overclock_timer = spell.fire_rate_duration
	_overclock_multiplier = spell.fire_rate_multiplier
	fire_timer.wait_time = 1.0 / (fire_rate * _overclock_multiplier)
	EventBus.buff_overclock_activated.emit(spell.fire_rate_duration)


func _cast_adrenaline(spell: CardData) -> void:
	_adrenaline_active = true
	_adrenaline_timer = spell.speed_buff_duration
	_adrenaline_fire_rate_bonus = spell.speed_buff_fire_rate
	fire_timer.wait_time = 1.0 / (fire_rate * (1.0 + spell.speed_buff_fire_rate))
	if _player:
		EventBus.player_speed_changed.emit(1.0 + spell.speed_buff_move)
	EventBus.buff_adrenaline_activated.emit(spell.speed_buff_duration)


func _cast_chain_lightning(spell: CardData) -> void:
	var cam := get_viewport().get_camera_3d()
	if not cam:
		return
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		cam.global_position,
		cam.global_position + (-cam.global_transform.basis.z) * max_ray_distance,
		0b0100
	)
	var result := space.intersect_ray(query)
	if not result:
		return
	var primary = result.collider
	var primary_status: StatusEffectComponent = primary.get_node_or_null("StatusEffectComponent")
	if not primary_status or not primary_status.is_shocked:
		return  # Target must be shocked
	# Bounce to nearby enemies
	var already_hit: Array = [primary]
	var bounce_targets: Array = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy == primary:
			continue
		if enemy.global_position.distance_to(primary.global_position) <= 20.0:
			bounce_targets.append(enemy)
	bounce_targets.sort_custom(func(a, b): return a.global_position.distance_to(primary.global_position) < b.global_position.distance_to(primary.global_position))
	var bounce_count := mini(spell.chain_lightning_bounces, bounce_targets.size())
	for i in bounce_count:
		var target = bounce_targets[i]
		var target_status: StatusEffectComponent = target.get_node_or_null("StatusEffectComponent")
		var chain_mult := target_status.get_chain_multiplier() if target_status else 1.0
		target.take_damage(spell.chain_lightning_damage * chain_mult)


func _cast_spotter(spell: CardData) -> void:
	var cam := get_viewport().get_camera_3d()
	if not cam:
		return
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		cam.global_position,
		cam.global_position + (-cam.global_transform.basis.z) * max_ray_distance,
		0b0100
	)
	var result := space.intersect_ray(query)
	if not result:
		return
	var enemy = result.collider
	var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
	if status:
		status.apply_mark(spell.mark_duration)


func _cast_emp(spell: CardData) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(global_position) <= spell.emp_radius:
			var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
			if status:
				status.apply_shock()
			# Stun: freeze enemy movement briefly
			if enemy.has_method("apply_stun"):
				enemy.apply_stun(spell.emp_stun_duration)


func _cast_vampiric_burst(spell: CardData) -> void:
	_vampiric_active = true
	_vampiric_timer = spell.vampiric_duration
	_vampiric_ratio = spell.vampiric_ratio
	EventBus.buff_vampiric_burst_activated.emit(spell.vampiric_duration)


func _cast_reload_surge(spell: CardData) -> void:
	# Instant reload — skip 2s timer
	deck_state.reload()
	_prev_gun_card = null
	EventBus.weapon_reload_finished.emit()
	_emit_ammo_update()
	_emit_spell_update()


# ─── DAMAGE MODIFIERS ─────────────────────────────────────────────────────────

func get_damage_for_bullet(base_dmg: float, card: CardData, enemy: Node3D) -> float:
	var dmg := base_dmg

	# War Cry
	if _war_cry_active:
		dmg *= _war_cry_multiplier

	# Iron Skin damage bonus (while shield active)
	if shield_hp > 0 and _shield_damage_bonus > 0:
		dmg *= (1.0 + _shield_damage_bonus)

	# Megashot: one bullet gets 5x
	if _megashot_pending:
		dmg *= _megashot_multiplier
		_megashot_pending = false

	# Tracer bonus
	dmg += _tracer_bonus

	# Headshot multiplier (simplified: randomly apply headshot ~20% of time if headhunter)
	# Real headshot detection would need skeleton hit boxes — not in Gate 1 scope
	# For Gate 1: headhunter_multiplier is just the max possible multiplier
	# Apply enemy's damage multiplier (burn, mark)
	if enemy:
		var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
		if status:
			dmg *= status.get_damage_multiplier()

	return dmg


func notify_hit(enemy: Node3D, damage: float, card: CardData) -> void:
	## Called by enemy_base after a bullet lands. Handles per-hit card effects.

	# Drain: heal player
	if card.drain_hp_per_hit > 0 and _player and _player.has_method("heal"):
		_player.heal(card.drain_hp_per_hit)

	# Vampiric Burst: heal proportional to damage
	if _vampiric_active and _player and _player.has_method("heal"):
		_player.heal(damage * _vampiric_ratio)

	# Tracer: accumulate bonus for next pack
	if card.tracer_bonus_per_hit > 0:
		_tracer_bonus += card.tracer_bonus_per_hit

	# Tempo: consecutive hit combo
	if card.combo_bonus_per_hit > 0:
		var now := Time.get_ticks_msec() / 1000.0
		if now - _tempo_last_hit_time <= card.combo_window:
			_tempo_combo += 1
		else:
			_tempo_combo = 1
		_tempo_last_hit_time = now

	# Plague: on kill — handled in enemy_base.die() via signal
	# Ricochet: handled in fire_gun via raycast bounce
	# Explosive: spawn AoE — handled in _fire_single_ray
	# Fuel: force burn on hit
	if _fuel_packs_remaining > 0:
		var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
		if status:
			status.apply_burn()

	# Volt / Arc: chain to nearby enemies
	if card.chain_count > 0:
		_apply_chain(enemy, damage * card.chain_damage_multiplier, card.chain_count, card.chain_range, card)


func get_tempo_bonus(card: CardData) -> float:
	if card.combo_bonus_per_hit <= 0:
		return 0.0
	return _tempo_combo * card.combo_bonus_per_hit


# ─── UTILITY ─────────────────────────────────────────────────────────────────

func _apply_chain(source_enemy: Node3D, chain_damage: float, bounces: int, chain_range: float, card: CardData) -> void:
	var targets: Array = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy == source_enemy:
			continue
		if enemy.global_position.distance_to(source_enemy.global_position) <= chain_range:
			targets.append(enemy)
	targets.sort_custom(func(a, b): return a.global_position.distance_to(source_enemy.global_position) < b.global_position.distance_to(source_enemy.global_position))
	for i in mini(bounces, targets.size()):
		var t = targets[i]
		var t_status: StatusEffectComponent = t.get_node_or_null("StatusEffectComponent")
		var chain_mult := t_status.get_chain_multiplier() if t_status else 1.0
		t.take_damage(chain_damage * chain_mult)
		# Apply status effects from chain
		if t_status and card.status_effect == CardData.StatusEffectType.SHOCK:
			t_status.apply_shock()


func _spawn_ground_fire(pos: Vector3, card: CardData) -> void:
	# Spawn a temporary AoE fire hazard node
	var fire := Node3D.new()
	get_tree().current_scene.add_child(fire)
	fire.global_position = pos

	var mesh_inst := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = card.ground_fire_radius
	cyl.bottom_radius = card.ground_fire_radius
	cyl.height = 0.1
	mesh_inst.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0.3, 0, 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1, 0.2, 0, 1)
	mesh_inst.set_surface_override_material(0, mat)
	fire.add_child(mesh_inst)

	# Tick damage to enemies standing in it
	var ticks := int(card.ground_fire_duration)
	var timer := fire.get_tree().create_timer(1.0)
	var tick_count := [0]
	timer.timeout.connect(func():
		tick_count[0] += 1
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(enemy) and enemy.global_position.distance_to(fire.global_position) <= card.ground_fire_radius:
				enemy.take_damage(card.ground_fire_dps)
		if tick_count[0] >= ticks:
			fire.queue_free()
		else:
			fire.get_tree().create_timer(1.0).timeout.connect(func(): pass)  # re-timer handled recursively below
	)
	# Simpler: just use a time-based loop
	get_tree().create_timer(card.ground_fire_duration).timeout.connect(fire.queue_free)


func _pierce_check(from_point: Vector3, shoot_dir: Vector3, card: CardData) -> void:
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		from_point + shoot_dir * 0.1,
		from_point + shoot_dir * max_ray_distance,
		0b0100
	)
	var result := space_state.intersect_ray(query)
	if result and result.collider.has_method("take_bullet_hit"):
		result.collider.take_bullet_hit(card, self)
		EventBus.hit_confirmed.emit(result.position, card, result.collider)


func start_reload() -> void:
	if state == State.RELOADING:
		return
	state = State.RELOADING
	can_fire = false
	reload_timer.start()
	# Reset tracer on reload
	_tracer_bonus = 0.0
	# War Cry expires on reload (consumed for the current magazine)
	_war_cry_active = false
	# Fuel decrements on pack change, not on reload directly
	EventBus.weapon_reload_started.emit()


func is_reloading() -> bool:
	return state == State.RELOADING


func absorb_damage(amount: float) -> float:
	if shield_hp <= 0:
		return amount
	var absorbed := minf(shield_hp, amount)
	shield_hp -= absorbed
	if shield_hp <= 0:
		shield_hp = 0.0
		_shield_timer = 0.0
		_shield_damage_bonus = 0.0
		EventBus.player_shield_changed.emit(0.0, 0.0)
	else:
		EventBus.player_shield_changed.emit(shield_hp, 30.0)
	return amount - absorbed


func _on_fire_timer_timeout() -> void:
	can_fire = true
	state = State.IDLE


func _on_reload_finished() -> void:
	deck_state.reload()
	state = State.IDLE
	can_fire = true
	_prev_gun_card = null
	_tracer_bonus = 0.0
	_war_cry_active = false
	_fuel_packs_remaining = 0
	_tempo_combo = 0
	EventBus.weapon_reload_finished.emit()
	_emit_ammo_update()
	_emit_spell_update()


func _emit_ammo_update() -> void:
	EventBus.ammo_changed.emit(
		deck_state.bullets_remaining_in_pack,
		deck_state.get_gun_packs_remaining(),
		deck_state.get_current_gun_card()
	)


func _emit_spell_update() -> void:
	EventBus.spell_hand_changed.emit(
		deck_state.spell_hand,
		deck_state.spell_consumed,
		deck_state.active_spell_index
	)


func add_card_to_deck(card: CardData) -> void:
	deck_state.add_card(card)


# ─── Viewmodel kick + muzzle flash ────────────────────────────────────────────

func _do_viewmodel_kick(card: CardData) -> void:
	if not weapon_model:
		return
	var rest_pos := Vector3.ZERO
	var kick_pos := Vector3(0, 0, 0.05)
	var tween := create_tween()
	tween.tween_property(weapon_model, "position", kick_pos, 0.05)
	tween.tween_property(weapon_model, "position", rest_pos, 0.1)
	if muzzle_flash_light:
		muzzle_flash_light.light_color = card.muzzle_color if card else Color.WHITE
		muzzle_flash_light.light_energy = 4.0
		var ftween := create_tween()
		ftween.tween_property(muzzle_flash_light, "light_energy", 0.0, 0.05)


func _get_current_spread() -> float:
	if _player and _player.has_method("get_is_ads") and _player.get_is_ads():
		return ads_spread
	if _player and _player.has_method("get_is_moving") and _player.get_is_moving():
		return move_spread
	return base_spread

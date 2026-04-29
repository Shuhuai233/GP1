## WeaponController — New weapon system per WEAPONS_AND_CARDS.md
## Player carries 2 weapons. Switch with scroll/1-2. Each weapon has own magazine.
## Spell hand: 5 function card slots. F key casts active spell. Refills on reload.
## Magazine spells: apply to remaining bullets in current mag. Cleared on reload.
extends Node3D

const MAX_WEAPONS: int = 2
const SPELL_SLOTS: int = 5
const MAX_RAY_DISTANCE: float = 100.0

@onready var fire_timer: Timer = $FireTimer
@onready var reload_timer: Timer = $ReloadTimer
@onready var weapon_models_node: Node3D = $WeaponModels
@onready var muzzle_point: Marker3D = $MuzzlePoint

enum State { IDLE, FIRING, RELOADING }
var state: State = State.IDLE
var can_fire: bool = true

# ─── Weapon slots ─────────────────────────────────────────────────────────────
var weapons: Array = [null, null]  # Array[WeaponInstance]
var active_slot: int = 0
var _switch_cooldown: float = 0.0

# ─── Spell hand ───────────────────────────────────────────────────────────────
var spell_hand: Array = []  # Array[FunctionCardData], up to 5 slots
var spell_consumed: Array[bool] = []
var active_spell_index: int = -1

# ─── Active buff state ────────────────────────────────────────────────────────
var _war_cry_active: bool = false
var _war_cry_timer: float = 0.0
var _war_cry_bonus: float = 0.0

var _vampiric_active: bool = false
var _vampiric_timer: float = 0.0
var _vampiric_ratio: float = 0.0

var _adrenaline_active: bool = false
var _adrenaline_timer: float = 0.0
var _adrenaline_fire_bonus: float = 0.0

var _time_warp_active: bool = false
var _time_warp_timer: float = 0.0

var _iron_skin_hits_remaining: int = 0
var _iron_skin_timer: float = 0.0

var _magnetize_active: bool = false
var _magnetize_timer: float = 0.0
var _magnetize_pull: float = 0.0
var _magnetize_radius: float = 0.0

# Shield Wall: a static physics body we spawn in front of player
var _shield_wall_node: StaticBody3D = null

# Dash immunity tracking
var _dash_immune: bool = false
var _dash_immune_timer: float = 0.0
var _dash_ghost_node: Node3D = null  # Visual ghost during immunity

# Double-tap Shift for Dash shortcut
var _last_shift_time: float = -1.0
const DOUBLE_TAP_WINDOW: float = 0.35

var _player: Node3D = null

# All weapon resources
var _weapon_resources: Dictionary = {}  # WeaponType int → WeaponData
# All function card resources
var _starter_spells: Array[FunctionCardData] = []


func _ready() -> void:
	# Load weapon resources
	_weapon_resources[0] = preload("res://data/weapons/revolver.tres")
	_weapon_resources[1] = preload("res://data/weapons/ar.tres")
	_weapon_resources[2] = preload("res://data/weapons/smg.tres")
	_weapon_resources[3] = preload("res://data/weapons/shotgun.tres")
	_weapon_resources[4] = preload("res://data/weapons/sniper.tres")
	_weapon_resources[5] = preload("res://data/weapons/machine_pistol.tres")

	# Starter loadout: Revolver in slot 0
	weapons[0] = WeaponInstance.new(_weapon_resources[0])
	weapons[1] = null

	# Starter spell hand: Poison Magazine, Fire Magazine, Detonator, Shield Wall, Dash
	_starter_spells = [
		preload("res://data/function_cards/poison_magazine.tres"),
		preload("res://data/function_cards/fire_magazine.tres"),
		preload("res://data/function_cards/detonator.tres"),
		preload("res://data/function_cards/shield_wall.tres"),
		preload("res://data/function_cards/dash.tres"),
	]
	_init_spell_hand(_starter_spells)

	# Timer setup
	fire_timer.one_shot = true
	reload_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_timeout)
	reload_timer.timeout.connect(_on_reload_finished)

	_player = get_tree().get_first_node_in_group("player")
	_update_fire_timer()
	_emit_weapon_state()


func _process(delta: float) -> void:
	# ── Buff timers ──
	if _war_cry_active:
		_war_cry_timer -= delta
		if _war_cry_timer <= 0: _war_cry_active = false

	if _vampiric_active:
		_vampiric_timer -= delta
		if _vampiric_timer <= 0: _vampiric_active = false

	if _adrenaline_active:
		_adrenaline_timer -= delta
		if _adrenaline_timer <= 0:
			_adrenaline_active = false
			_update_fire_timer()
			if _player: EventBus.player_speed_changed.emit(1.0)

	if _time_warp_active:
		_time_warp_timer -= delta
		if _time_warp_timer <= 0:
			_time_warp_active = false
			_set_enemy_time_warp(1.0)

	if _iron_skin_timer > 0:
		_iron_skin_timer -= delta
		if _iron_skin_timer <= 0: _iron_skin_hits_remaining = 0

	if _magnetize_active:
		_magnetize_timer -= delta
		if _magnetize_timer <= 0:
			_magnetize_active = false
		else:
			_pull_enemies_toward_player(delta)

	# ── Dash immunity timer ──
	if _dash_immune:
		_dash_immune_timer -= delta
		if _dash_immune_timer <= 0:
			_dash_immune = false
			_clear_dash_ghost()
			EventBus.dash_immunity_ended.emit()

	if _switch_cooldown > 0:
		_switch_cooldown -= delta

	if state == State.RELOADING:
		return

	var w := get_active_weapon()
	if w and w.is_empty() and state == State.IDLE:
		start_reload()
		return

	# ── Weapon switch ──
	if Input.is_action_just_pressed("weapon_slot_1"):
		switch_to_slot(0)
	elif Input.is_action_just_pressed("weapon_slot_2"):
		switch_to_slot(1)
	else:
		# Scroll: weapon_next → slot 1, weapon_prev → slot 0 (with 2-weapon system)
		if Input.is_action_just_pressed("weapon_next") and _switch_cooldown <= 0:
			var next := (active_slot + 1) % MAX_WEAPONS
			switch_to_slot(next)
			_switch_cooldown = 0.15
		elif Input.is_action_just_pressed("weapon_prev") and _switch_cooldown <= 0:
			var prev := (active_slot - 1 + MAX_WEAPONS) % MAX_WEAPONS
			switch_to_slot(prev)
			_switch_cooldown = 0.15

	# ── Q/E spell cycling ──
	if Input.is_action_just_pressed("spell_prev"):
		_cycle_spell(-1)
	elif Input.is_action_just_pressed("spell_next"):
		_cycle_spell(1)

	# ── Double-tap Shift: Dash shortcut ──
	if Input.is_action_just_pressed("sprint"):
		var now := Time.get_ticks_msec() / 1000.0
		if now - _last_shift_time <= DOUBLE_TAP_WINDOW:
			_try_dash_shortcut()
			_last_shift_time = -1.0  # reset so triple-tap doesn't trigger again
		else:
			_last_shift_time = now

	# ── Fire ──
	if Input.is_action_just_pressed("fire") and can_fire and state == State.IDLE and w:
		_fire()

	# ── Spell ──
	if Input.is_action_just_pressed("cast_spell"):
		_cast_active_spell()

	# ── Reload ──
	if Input.is_action_just_pressed("reload") and state != State.RELOADING:
		start_reload()


# ─── WEAPON SWITCHING ─────────────────────────────────────────────────────────

func switch_to_slot(slot: int) -> void:
	if slot == active_slot or slot >= MAX_WEAPONS:
		return
	if weapons[slot] == null:
		return  # Empty slot — can't switch

	# Quick Grip: i-frames on switch
	var new_w: WeaponInstance = weapons[slot]
	var has_quick_grip := false
	for att in new_w.attachments:
		if att.quick_grip:
			has_quick_grip = true
			break
	if has_quick_grip:
		var wm := get_tree().get_first_node_in_group("wave_manager")
		if wm and wm.has_method("set_temporary_grace"):
			wm.set_temporary_grace(new_w.attachments.filter(func(a): return a.quick_grip)[0].quick_grip_iframes)

	active_slot = slot
	_update_fire_timer()
	_update_weapon_model()
	_emit_weapon_state()


func give_weapon(weapon_data: WeaponData, slot: int) -> void:
	if slot >= MAX_WEAPONS:
		return
	weapons[slot] = WeaponInstance.new(weapon_data)
	_emit_weapon_state()


func get_active_weapon() -> WeaponInstance:
	return weapons[active_slot]


func active_weapon_has_holo_sight() -> bool:
	var w := get_active_weapon()
	if not w: return false
	for att in w.attachments:
		if att.holo_sight: return true
	return false


# ─── FIRING ───────────────────────────────────────────────────────────────────

func _fire() -> void:
	var w := get_active_weapon()
	if not w:
		return

	state = State.FIRING
	can_fire = false
	fire_timer.start()

	var cam := get_viewport().get_camera_3d()
	if not cam:
		return

	var pellets := w.get_pellets()
	var cam_from := cam.global_position
	var cam_forward := -cam.global_transform.basis.z

	for _p in pellets:
		var shoot_dir := _get_shoot_direction(cam_forward, cam, w)
		var hit_result := _raycast(cam_from, shoot_dir)
		_process_hit(hit_result, shoot_dir, cam_from, w)

	# Consume bullet (Double Feed: 2 per shot)
	var has_double_feed := false
	for att in w.attachments:
		if att.double_feed:
			has_double_feed = true
			break
	var bullets_to_consume := 2 if has_double_feed else 1
	w.consume_bullet(bullets_to_consume)

	# Machine Pistol speed bonus
	if w.data.move_speed_bonus_while_firing > 0 and _player:
		EventBus.player_speed_changed.emit(1.0 + w.data.move_speed_bonus_while_firing)

	_do_viewmodel_kick()
	EventBus.weapon_fired_new.emit(w)
	_emit_weapon_state()


func _get_shoot_direction(base_dir: Vector3, cam: Camera3D, w: WeaponInstance) -> Vector3:
	var is_ads: bool = _player.has_method("get_is_ads") and _player.get_is_ads()
	var spread: float = 0.0

	# Holo Sight: zero spread in ADS
	var has_holo: bool = false
	for att in w.attachments:
		if att.holo_sight: has_holo = true

	if is_ads:
		spread = 0.0 if has_holo else w.data.ads_spread
	elif _player.has_method("get_is_moving") and _player.get_is_moving():
		spread = w.data.move_spread
	else:
		spread = w.data.hip_spread

	if spread <= 0:
		return base_dir
	var rotated_dir: Vector3 = base_dir.rotated(cam.global_transform.basis.x, randf_range(-deg_to_rad(spread), deg_to_rad(spread)))
	return rotated_dir.rotated(cam.global_transform.basis.y, randf_range(-deg_to_rad(spread), deg_to_rad(spread))).normalized()


func _raycast(from: Vector3, direction: Vector3) -> Dictionary:
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, from + direction * MAX_RAY_DISTANCE, 0b0101)
	return space.intersect_ray(query)


func _process_hit(hit: Dictionary, shoot_dir: Vector3, cam_from: Vector3, w: WeaponInstance) -> void:
	var damage := _calc_damage(w)

	if not hit.is_empty() and hit.collider.has_method("take_bullet_hit_new"):
		var collider = hit.collider
		var hit_pos: Vector3 = hit.position

		# Apply magazine spell status effects
		_apply_mag_spell_on_hit(collider, damage, w)

		# Apply attachment effects
		_apply_attachment_effects(collider, hit_pos, shoot_dir, damage, w)

		# Deal damage
		collider.take_bullet_hit_new(damage, w, self)
		EventBus.hit_confirmed_new.emit(hit_pos, w, collider)

		# Vampiric Barrel
		for att in w.attachments:
			if att.vampiric_barrel and _player and _player.has_method("heal"):
				_player.heal(att.vampiric_hp_per_hit)

		# Vampiric Aura
		if _vampiric_active and _player and _player.has_method("heal"):
			_player.heal(damage * _vampiric_ratio)

		# Piercing — check via bool field, not string name
		var has_piercing: bool = false
		for att in w.attachments:
			if att.piercing:
				has_piercing = true
				break
		if has_piercing:
			_pierce_check(hit_pos, shoot_dir, damage, w)

		# Split Barrel — fire 2 extra raycasts angled outward from the 5m hit point
		for att in w.attachments:
			if att.split_bullet:
				_split_bullet_check(cam_from, shoot_dir, hit_pos, damage * att.split_damage_fraction, att.split_count - 1, w)
				break
	else:
		var miss_pos := cam_from + shoot_dir * MAX_RAY_DISTANCE
		# Ricochet Chamber: hit a wall (non-enemy), bounce toward nearest enemy
		if not hit.is_empty():
			for att in w.attachments:
				if att.ricochet:
					_ricochet_check(hit.position, shoot_dir, damage, w, att.ricochet_range)
					break
			miss_pos = hit.position
		EventBus.hit_missed_new.emit(miss_pos, w)


func _calc_damage(w: WeaponInstance) -> float:
	var dmg := w.get_effective_damage()
	if _war_cry_active:
		dmg *= (1.0 + _war_cry_bonus)
	return dmg


func _apply_mag_spell_on_hit(enemy: Node3D, damage: float, w: WeaponInstance) -> void:
	# Check both weapons if elemental converter is present
	var spells_to_apply: Array[WeaponInstance] = [w]
	for slot in MAX_WEAPONS:
		if weapons[slot] and weapons[slot] != w:
			for att in weapons[slot].attachments:
				if att.elemental_converter:
					spells_to_apply.append(weapons[slot])
					break

	for wi in spells_to_apply:
		if not wi.active_mag_spell:
			continue

		# Chaos Engine overrides
		var spell_to_use := wi.active_mag_spell
		for att in wi.attachments:
			if att.chaos_engine and randf() < att.chaos_chance:
				spell_to_use = _get_random_mag_spell()
				break

		if not spell_to_use:
			continue

		var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
		if not status:
			continue

		if spell_to_use.mag_poison_stacks_per_hit > 0:
			status.apply_poison(spell_to_use.mag_poison_stacks_per_hit)
		if spell_to_use.mag_apply_burn:
			status.apply_burn()
		if spell_to_use.mag_apply_shock:
			status.apply_shock()
			# Shock Magazine: chain 40% damage to 1 nearby enemy within 6m
			_apply_shock_chain(enemy, damage * 0.4, 6.0, w)
		if spell_to_use.mag_apply_slow:
			status.apply_slow()
		if spell_to_use.mag_explosive:
			_spawn_mag_explosion(enemy.global_position, damage * spell_to_use.mag_explosive_damage_fraction, spell_to_use.mag_explosive_radius, wi.active_mag_spell)


func _apply_attachment_effects(enemy: Node3D, hit_pos: Vector3, shoot_dir: Vector3, damage: float, w: WeaponInstance) -> void:
	for att in w.attachments:
		if att.explosive_tips:
			_spawn_explosion(hit_pos, damage * att.explosive_damage_fraction, att.explosive_radius, w)
		if att.chain_link:
			_apply_chain(enemy, damage * att.chain_damage_fraction, att.chain_range, w)
		if att.chaos_engine:
			pass  # Handled in _apply_mag_spell_on_hit


func _ricochet_check(origin: Vector3, shoot_dir: Vector3, damage: float, w: WeaponInstance, ricochet_range: float) -> void:
	## After hitting a wall, find the nearest enemy within ricochet_range and fire a secondary ray
	var nearest_enemy: Node3D = null
	var nearest_dist := ricochet_range
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var d: float = enemy.global_position.distance_to(origin)
		if d < nearest_dist:
			nearest_dist = d
			nearest_enemy = enemy
	if not nearest_enemy:
		return
	# Raycast from ricochet point toward nearest enemy
	var ricochet_dir := (nearest_enemy.global_position - origin).normalized()
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(origin + ricochet_dir * 0.1, origin + ricochet_dir * ricochet_range, 0b0100)
	var r := space.intersect_ray(q)
	if r and r.collider.has_method("take_bullet_hit_new"):
		r.collider.take_bullet_hit_new(damage, w, self)
		_apply_mag_spell_on_hit(r.collider, damage, w)
		EventBus.hit_confirmed_new.emit(r.position, w, r.collider)


func _pierce_check(from: Vector3, dir: Vector3, damage: float, w: WeaponInstance) -> void:
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from + dir * 0.1, from + dir * MAX_RAY_DISTANCE, 0b0100)
	var result := space.intersect_ray(query)
	if result and result.collider.has_method("take_bullet_hit_new"):
		result.collider.take_bullet_hit_new(damage, w, self)
		_apply_mag_spell_on_hit(result.collider, damage, w)
		EventBus.hit_confirmed_new.emit(result.position, w, result.collider)


func _split_bullet_check(cam_from: Vector3, original_dir: Vector3, split_origin: Vector3, split_damage: float, extra_count: int, w: WeaponInstance) -> void:
	## After 5m of travel, bullet splits into extra_count+1 total projectiles (fan out)
	var cam := get_viewport().get_camera_3d()
	if not cam:
		return
	var right := cam.global_transform.basis.x
	var spread_angles: Array[float] = []
	for i in extra_count:
		var angle := deg_to_rad(5.0 + i * 5.0)
		spread_angles.append(angle)
		spread_angles.append(-angle)
	for angle in spread_angles:
		var split_dir := original_dir.rotated(right, angle).normalized()
		var result := _raycast(split_origin + split_dir * 0.1, split_dir)
		if not result.is_empty() and result.collider.has_method("take_bullet_hit_new"):
			result.collider.take_bullet_hit_new(split_damage, w, self)
			_apply_mag_spell_on_hit(result.collider, split_damage, w)
			EventBus.hit_confirmed_new.emit(result.position, w, result.collider)


func _apply_chain(source: Node3D, chain_damage: float, chain_range: float, w: WeaponInstance) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy == source:
			continue
		if enemy.global_position.distance_to(source.global_position) <= chain_range:
			if enemy.has_method("take_bullet_hit_new"):
				enemy.take_bullet_hit_new(chain_damage, w, self)
				_apply_mag_spell_on_hit(enemy, chain_damage, w)
			break  # chain to 1 closest


func _apply_shock_chain(source: Node3D, chain_damage: float, chain_range: float, w: WeaponInstance) -> void:
	## Shock Magazine: chain to nearest enemy for 40% damage, apply mag spell to chain target too
	_apply_chain(source, chain_damage, chain_range, w)


func _spawn_explosion(pos: Vector3, damage: float, radius: float, w: WeaponInstance) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(pos) <= radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
			_apply_mag_spell_on_hit(enemy, damage, w)


func _spawn_mag_explosion(pos: Vector3, damage: float, radius: float, spell: FunctionCardData) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.global_position.distance_to(pos) > radius:
			continue
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)


func _has_attachment(w: WeaponInstance, name: StringName) -> bool:
	for att in w.attachments:
		if att.attachment_name == name:
			return true
	return false


func _get_random_mag_spell() -> FunctionCardData:
	var pool: Array[FunctionCardData] = [
		preload("res://data/function_cards/poison_magazine.tres"),
		preload("res://data/function_cards/fire_magazine.tres"),
		preload("res://data/function_cards/shock_magazine.tres"),
		preload("res://data/function_cards/frost_magazine.tres"),
		preload("res://data/function_cards/explosive_magazine.tres"),
	]
	return pool[randi() % pool.size()]


# ─── SPELL HAND ───────────────────────────────────────────────────────────────

func _init_spell_hand(spells: Array[FunctionCardData]) -> void:
	spell_hand.clear()
	spell_consumed.clear()
	for sp in spells:
		spell_hand.append(sp)
		spell_consumed.append(false)
	while spell_hand.size() < SPELL_SLOTS:
		spell_hand.append(null)
		spell_consumed.append(true)
	active_spell_index = _find_next_spell(0)
	_emit_spell_state()


func _find_next_spell(from: int) -> int:
	for i in range(from, spell_hand.size()):
		if not spell_consumed[i] and spell_hand[i] != null:
			return i
	return -1


func _cast_active_spell() -> void:
	if active_spell_index < 0:
		return
	var spell: FunctionCardData = spell_hand[active_spell_index]
	if not spell:
		return

	spell_consumed[active_spell_index] = true
	active_spell_index = _find_next_spell(active_spell_index + 1)
	_emit_spell_state()

	EventBus.spell_cast_new.emit(spell)
	_execute_spell(spell)


func _execute_spell(spell: FunctionCardData) -> void:
	# ── Magazine Spells ──
	if spell.is_magazine_spell:
		_cast_magazine_spell(spell)
		return

	# ── Character Spells ──
	if spell.is_dash: _cast_dash(spell)
	elif spell.is_blink: _cast_blink(spell)
	elif spell.is_shield_wall: _cast_shield_wall(spell)
	elif spell.is_iron_skin: _cast_iron_skin(spell)
	elif spell.is_adrenaline: _cast_adrenaline(spell)
	elif spell.is_vampiric_aura: _cast_vampiric_aura(spell)
	elif spell.is_war_cry: _cast_war_cry(spell)
	elif spell.is_time_warp: _cast_time_warp(spell)

	# ── Execute Spells ──
	elif spell.is_detonator: _cast_detonator(spell)
	elif spell.is_chain_detonation: _cast_chain_detonation(spell)
	elif spell.is_purge: _cast_purge(spell)
	elif spell.is_shatter: _cast_shatter(spell)

	# ── Tactical Spells ──
	elif spell.is_spotter: _cast_spotter(spell)
	elif spell.is_reload_surge: _cast_reload_surge()
	elif spell.is_magnetize: _cast_magnetize(spell)


func _cycle_spell(direction: int) -> void:
	## Q cycles left (-1), E cycles right (+1)
	if spell_hand.is_empty():
		return
	var start := active_spell_index if active_spell_index >= 0 else 0
	var idx := start
	for _i in spell_hand.size():
		idx = (idx + direction + spell_hand.size()) % spell_hand.size()
		if spell_hand[idx] != null and not spell_consumed[idx]:
			active_spell_index = idx
			_emit_spell_state()
			return
	# All consumed — still move the visual cursor
	idx = (start + direction + spell_hand.size()) % spell_hand.size()
	active_spell_index = idx
	_emit_spell_state()


func _try_dash_shortcut() -> void:
	## Double-tap Shift fires Dash from anywhere in the spell hand without selecting it
	for i in spell_hand.size():
		if spell_hand[i] != null and not spell_consumed[i] and spell_hand[i].is_dash:
			spell_consumed[i] = true
			# Don't change active_spell_index — keep current selection
			# But do advance if i was the active index
			if active_spell_index == i:
				active_spell_index = _find_next_spell(i + 1)
			_emit_spell_state()
			EventBus.spell_cast_new.emit(spell_hand[i])
			_execute_spell(spell_hand[i])
			return


func add_spell_to_hand(spell: FunctionCardData) -> void:
	## Add new spell; if full and all unconsumed, request swap from UI.
	for i in spell_hand.size():
		if spell_hand[i] == null or spell_consumed[i]:
			spell_hand[i] = spell
			spell_consumed[i] = false
			if active_spell_index < 0:
				active_spell_index = i
			_emit_spell_state()
			return
	# All 5 occupied and unconsumed — request UI swap
	EventBus.spell_hand_full_swap_requested.emit(spell, spell_hand.duplicate())


# ─── MAGAZINE SPELL IMPLEMENTATIONS ──────────────────────────────────────────

func _cast_magazine_spell(spell: FunctionCardData) -> void:
	var w := get_active_weapon()
	if not w:
		return

	# Elemental Converter: apply to both weapons
	var targets: Array[WeaponInstance] = [w]
	for wi in weapons:
		if wi and wi != w:
			for att in wi.attachments:
				if att.elemental_converter:
					targets.append(wi)
					break

	for wi in targets:
		wi.active_mag_spell = spell

	EventBus.mag_spell_activated.emit(spell, w)


# ─── CHARACTER SPELL IMPLEMENTATIONS ─────────────────────────────────────────

func _cast_dash(spell: FunctionCardData) -> void:
	if not _player: return

	# Direction: WASD input direction, not look direction. If no input: forward.
	var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move_dir: Vector3
	if input_2d.length() > 0.1:
		move_dir = (_player.global_transform.basis * Vector3(input_2d.x, 0, input_2d.y)).normalized()
	else:
		move_dir = -_player.global_transform.basis.z

	var dash_dist := spell.dash_distance  # 3m per spec
	var target_pos := _player.global_position + move_dir * dash_dist

	# Collision check: stop at wall using motion cast
	var space := get_world_3d().direct_space_state
	var query := PhysicsShapeQueryParameters3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.28
	capsule.height = 1.6
	query.shape = capsule
	query.motion = move_dir * dash_dist
	query.transform = Transform3D(Basis.IDENTITY, _player.global_position + Vector3.UP * 0.9)
	query.collision_mask = 0b0001  # environment only
	var motion_result := space.cast_motion(query)
	if motion_result.size() >= 1 and motion_result[0] < 1.0:
		target_pos = _player.global_position + move_dir * dash_dist * motion_result[0]

	_player.global_position = target_pos

	# 2s immunity window — track in this controller, not wave manager
	_dash_immune = true
	_dash_immune_timer = spell.dash_iframes  # 2.0 per spec
	EventBus.dash_immunity_started.emit()
	_spawn_dash_ghost()


func _cast_blink(spell: FunctionCardData) -> void:
	if not _player: return
	var cam := get_viewport().get_camera_3d()
	if not cam: return
	var space := get_world_3d().direct_space_state
	var from := cam.global_position
	var blink_dir: Vector3 = -cam.global_transform.basis.z
	var q := PhysicsRayQueryParameters3D.create(from, from + blink_dir * spell.blink_range, 0b0001)
	var r := space.intersect_ray(q)
	_player.global_position = r.position + r.normal * 0.5 if r else from + blink_dir * spell.blink_range


func _cast_shield_wall(spell: FunctionCardData) -> void:
	if not _player: return
	if _shield_wall_node and is_instance_valid(_shield_wall_node):
		_shield_wall_node.queue_free()
	# Spawn a static wall 2m in front of player
	# Layer 8 = shield_wall (does NOT intersect player raycast mask 0b0101=env+enemy)
	# Enemy projectiles must be on layer that hits layer 8 to be blocked
	var wall := StaticBody3D.new()
	wall.collision_layer = 0b10000000  # layer 8
	wall.collision_mask = 0
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.5, 2.0, 0.2)
	col.shape = shape
	wall.add_child(col)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.5, 2.0, 0.2)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0, 0.9, 0.9, 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0, 0.9, 0.9)
	mesh.set_surface_override_material(0, mat)
	wall.add_child(mesh)
	var wall_pos := _player.global_position - _player.global_transform.basis.z * 2.0
	wall_pos.y = _player.global_position.y + 0.5
	wall.global_position = wall_pos
	wall.global_rotation.y = _player.global_rotation.y
	get_tree().current_scene.add_child(wall)
	_shield_wall_node = wall
	get_tree().create_timer(spell.shield_wall_duration).timeout.connect(func():
		if is_instance_valid(wall): wall.queue_free()
	)


func _cast_iron_skin(spell: FunctionCardData) -> void:
	_iron_skin_hits_remaining = spell.iron_skin_hits
	_iron_skin_timer = spell.iron_skin_duration
	EventBus.iron_skin_activated.emit(spell.iron_skin_hits)


func _cast_adrenaline(spell: FunctionCardData) -> void:
	_adrenaline_active = true
	_adrenaline_timer = spell.adrenaline_duration
	_adrenaline_fire_bonus = spell.adrenaline_fire_rate_bonus
	_update_fire_timer()
	if _player: EventBus.player_speed_changed.emit(1.0 + spell.adrenaline_move_bonus)


func _cast_vampiric_aura(spell: FunctionCardData) -> void:
	_vampiric_active = true
	_vampiric_timer = spell.vampiric_duration
	_vampiric_ratio = spell.vampiric_ratio


func _cast_war_cry(spell: FunctionCardData) -> void:
	_war_cry_active = true
	_war_cry_timer = spell.war_cry_duration
	_war_cry_bonus = spell.war_cry_damage_bonus


func _cast_time_warp(spell: FunctionCardData) -> void:
	_time_warp_active = true
	_time_warp_timer = spell.time_warp_duration
	_set_enemy_time_warp(spell.time_warp_speed_fraction)
	# Cleanup is handled solely in _process when _time_warp_timer reaches 0
	# No duplicate create_timer here


func _set_enemy_time_warp(speed_scale: float) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			enemy.process_mode = Node.PROCESS_MODE_INHERIT
			# Scale enemy process via time scale on their node
			if enemy.has_method("set_time_scale"):
				enemy.set_time_scale(speed_scale)
			else:
				# fallback: modify speed directly
				if enemy.has_method("set_speed_scale"):
					enemy.set_speed_scale(speed_scale)


# ─── EXECUTE SPELL IMPLEMENTATIONS ───────────────────────────────────────────

func _hitscan_enemy() -> Node3D:
	var cam := get_viewport().get_camera_3d()
	if not cam: return null
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(cam.global_position, cam.global_position + (-cam.global_transform.basis.z) * MAX_RAY_DISTANCE, 0b0100)
	var r := space.intersect_ray(q)
	return r.collider if r and r.collider.has_method("take_damage") else null


func _cast_detonator(spell: FunctionCardData) -> void:
	var enemy := _hitscan_enemy()
	if not enemy: return
	var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
	if not status or status.poison_stacks <= 0:
		EventBus.spell_detonator_hit.emit(enemy, 0.0, false)
		return
	var has_burn := status.is_burning
	var multiplier := spell.detonator_base_multiplier * 2.0 if has_burn else spell.detonator_base_multiplier
	var stacks := status.poison_stacks
	status.detonate_poison()
	var bonus := stacks * multiplier
	enemy.take_damage(bonus)
	EventBus.enemy_poison_detonated.emit(enemy, stacks, bonus, has_burn)
	EventBus.spell_detonator_hit.emit(enemy, bonus, has_burn)
	# Toxic Fire combo popup
	if has_burn:
		EventBus.combo_triggered.emit("TOXIC FIRE", enemy.global_position)


func _cast_chain_detonation(spell: FunctionCardData) -> void:
	var primary := _hitscan_enemy()
	if not primary: return
	var status: StatusEffectComponent = primary.get_node_or_null("StatusEffectComponent")
	if not status or status.poison_stacks <= 0: return
	var has_burn := status.is_burning
	var stacks := status.poison_stacks
	# Contagion combo: Poison + Shock = 100% spread instead of 50%
	var spread_frac := spell.chain_det_spread_fraction
	var primary_status := primary.get_node_or_null("StatusEffectComponent") as StatusEffectComponent
	if primary_status and primary_status.is_shocked:
		spread_frac = 1.0  # Contagion
		EventBus.combo_triggered.emit("CONTAGION", primary.global_position)

	var multiplier := spell.detonator_base_multiplier * 2.0 if has_burn else spell.detonator_base_multiplier
	status.detonate_poison()
	var bonus := stacks * multiplier
	primary.take_damage(bonus)
	EventBus.enemy_poison_detonated.emit(primary, stacks, bonus, has_burn)
	# Spread stacks to nearby enemies
	var spread_stacks := int(stacks * spread_frac)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy == primary: continue
		if enemy.global_position.distance_to(primary.global_position) <= spell.chain_det_spread_radius:
			var es: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
			if es: es.apply_poison(spread_stacks)


func _cast_purge(spell: FunctionCardData) -> void:
	var enemy := _hitscan_enemy()
	if not enemy: return
	var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
	if not status: return
	var type_count := 0
	var total_stacks := status.poison_stacks
	if status.poison_stacks > 0: type_count += 1
	if status.is_burning: type_count += 1
	if status.is_shocked: type_count += 1
	if status.is_slowed: type_count += 1
	if status.is_marked: type_count += 1
	if status.is_frozen: type_count += 1
	var damage := type_count * spell.purge_damage_per_type + total_stacks * spell.purge_damage_per_stack
	# Consume all statuses
	status.clear_all()
	enemy.take_damage(damage)


func _cast_shatter(spell: FunctionCardData) -> void:
	var enemy := _hitscan_enemy()
	if not enemy: return
	var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
	if not status or not status.is_slowed:
		return  # Wasted — target not slowed
	# Brittle combo: if already frozen... not applicable (shatter creates freeze)
	status.apply_freeze(spell.shatter_freeze_duration)
	enemy.take_damage(spell.shatter_damage)
	EventBus.combo_triggered.emit("SHATTER", enemy.global_position)


# ─── TACTICAL SPELL IMPLEMENTATIONS ──────────────────────────────────────────

func _cast_spotter(spell: FunctionCardData) -> void:
	var enemy := _hitscan_enemy()
	if not enemy: return
	var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
	if status: status.apply_mark(spell.mark_duration)


func _cast_reload_surge() -> void:
	## Instant reload that PRESERVES the active magazine spell
	var w := get_active_weapon()
	if not w: return
	var saved_spell := w.active_mag_spell  # preserve
	w.reload_surge()
	w.active_mag_spell = saved_spell  # restore
	_emit_weapon_state()
	EventBus.weapon_reload_finished.emit()


func _cast_magnetize(spell: FunctionCardData) -> void:
	_magnetize_active = true
	_magnetize_timer = spell.magnetize_duration
	_magnetize_pull = spell.magnetize_pull_per_sec
	_magnetize_radius = spell.magnetize_radius


func _pull_enemies_toward_player(delta: float) -> void:
	if not _player: return
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy): continue
		var dist: float = enemy.global_position.distance_to(_player.global_position)
		if dist <= _magnetize_radius and dist > 1.0:
			var pull_dir: Vector3 = (_player.global_position - enemy.global_position).normalized()
			enemy.global_position += pull_dir * _magnetize_pull * delta


# ─── RELOAD ───────────────────────────────────────────────────────────────────

func start_reload() -> void:
	if state == State.RELOADING: return
	var w := get_active_weapon()
	if not w: return
	state = State.RELOADING
	can_fire = false
	reload_timer.wait_time = w.get_reload_time()
	reload_timer.start()
	EventBus.weapon_reload_started.emit()


func _on_reload_finished() -> void:
	var w := get_active_weapon()
	if w: w.reload()  # clears mag spell
	state = State.IDLE
	can_fire = true
	# Refill spell hand
	_refill_spell_hand()
	_update_fire_timer()
	_emit_weapon_state()
	_emit_spell_state()
	EventBus.weapon_reload_finished.emit()


func _refill_spell_hand() -> void:
	## On reload, consumed spells become available again (represents "drawing new cards")
	for i in spell_hand.size():
		if spell_consumed[i] and spell_hand[i] != null:
			spell_consumed[i] = false
	active_spell_index = _find_next_spell(0)


func is_reloading() -> bool:
	return state == State.RELOADING


func absorb_damage(amount: float) -> float:
	## Dash 2s immunity: negate all damage
	if _dash_immune:
		return 0.0
	## Iron Skin: absorb next 3 hits
	if _iron_skin_hits_remaining > 0:
		_iron_skin_hits_remaining -= 1
		if _iron_skin_hits_remaining <= 0:
			_iron_skin_timer = 0.0
			EventBus.iron_skin_depleted.emit()
		return 0.0
	return amount


func _spawn_dash_ghost() -> void:
	EventBus.dash_ghost_start.emit()


func _clear_dash_ghost() -> void:
	EventBus.dash_ghost_end.emit()


# ─── ATTACHMENT MANAGEMENT ────────────────────────────────────────────────────

func add_attachment_to_slot(att: AttachmentData, slot: int) -> void:
	if slot >= MAX_WEAPONS or not weapons[slot]: return
	weapons[slot].add_attachment(att)
	_update_fire_timer()
	_emit_weapon_state()


func replace_spell_at_index(index: int, new_spell: FunctionCardData) -> void:
	## Drop the spell at index and insert new_spell there
	if index < 0 or index >= spell_hand.size():
		return
	spell_hand[index] = new_spell
	spell_consumed[index] = false
	if active_spell_index < 0 or spell_consumed[active_spell_index]:
		active_spell_index = _find_next_spell(0)
	_emit_spell_state()


# ─── TIMER / MODEL HELPERS ────────────────────────────────────────────────────

func _update_fire_timer() -> void:
	var w := get_active_weapon()
	if not w: return
	var rate := w.get_fire_rate()
	if _adrenaline_active:
		rate *= (1.0 + _adrenaline_fire_bonus)
	fire_timer.wait_time = 1.0 / rate


func _on_fire_timeout() -> void:
	can_fire = true
	state = State.IDLE
	# Stop Machine Pistol speed bonus when not firing
	var w := get_active_weapon()
	if w and w.data.move_speed_bonus_while_firing > 0 and _player:
		EventBus.player_speed_changed.emit(1.0)


func _do_viewmodel_kick() -> void:
	var model := weapon_models_node.get_child(active_slot) if weapon_models_node.get_child_count() > active_slot else null
	if not model: return
	var rest := Vector3.ZERO
	var kick := Vector3(0, 0, 0.05)
	var tween := create_tween()
	tween.tween_property(model, "position", kick, 0.05)
	tween.tween_property(model, "position", rest, 0.1)


func _update_weapon_model() -> void:
	# Show only active weapon model
	for i in weapon_models_node.get_child_count():
		weapon_models_node.get_child(i).visible = (i == active_slot)


func _emit_weapon_state() -> void:
	EventBus.weapon_state_changed.emit(weapons, active_slot)


func _emit_spell_state() -> void:
	EventBus.spell_hand_state_changed.emit(spell_hand, spell_consumed, active_spell_index)


# ─── ENEMY TIME SCALE ────────────────────────────────────────────────────────

func _check_combo_brittle(enemy: Node3D) -> void:
	var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
	if status and status.is_frozen:
		# Brittle: frozen enemies take 2x damage
		pass  # multiplier applied in enemy_base.take_bullet_hit_new

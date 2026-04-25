## Weapon — Two-hand system per GDD §2
## Right hand: revolver, fires card-packs (FIRING cards), semi-auto
## Left hand: spell hand, holds 3 FUNCTION cards, cast with F key
## Reload reshuffles both hands
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

var state: State = State.IDLE
var deck_state: DeckState
var can_fire: bool = true
var _fired_this_click: bool = false

# Shield state (from Barrier spell)
var shield_hp: float = 0.0
var _shield_timer: float = 0.0

# Card resources
var standard_round: CardData
var venom_round: CardData
var incendiary_round: CardData
var piercing_round: CardData
var detonator: CardData
var barrier: CardData
var flashfire: CardData

var _prev_gun_card: CardData = null
var _player: Node3D = null


func _ready() -> void:
	standard_round  = preload("res://data/cards/standard_round.tres")
	venom_round     = preload("res://data/cards/venom_round.tres")
	incendiary_round= preload("res://data/cards/incendiary_round.tres")
	piercing_round  = preload("res://data/cards/piercing_round.tres")
	detonator       = preload("res://data/cards/detonator_round.tres")
	barrier         = preload("res://data/cards/barrier.tres")
	flashfire       = preload("res://data/cards/flashfire.tres")

	# Starter deck: 3xStandard + 1xVenom + 1xIncendiary + 1xPiercing + 1xDetonator + 1xBarrier + 1xFlashfire
	deck_state = DeckState.new()
	var starter: Array[CardData] = []
	for i in 3:
		starter.append(standard_round.duplicate())
	starter.append(venom_round.duplicate())
	starter.append(incendiary_round.duplicate())
	starter.append(piercing_round.duplicate())
	starter.append(detonator.duplicate())
	starter.append(barrier.duplicate())
	starter.append(flashfire.duplicate())
	deck_state.initialize(starter)

	fire_timer.wait_time = 1.0 / fire_rate
	fire_timer.one_shot = true
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	reload_timer.timeout.connect(_on_reload_finished)

	# Find player (WeaponHolder → Head → Player)
	_player = get_parent().get_parent().get_parent()

	_emit_ammo_update()
	_emit_spell_update()


func _process(delta: float) -> void:
	# Shield timer
	if shield_hp > 0 and _shield_timer > 0:
		_shield_timer -= delta
		if _shield_timer <= 0:
			shield_hp = 0.0
			EventBus.player_shield_changed.emit(0.0, 0.0)

	if state == State.RELOADING:
		return

	# Track gun card changes
	var current_gun := deck_state.get_current_gun_card()
	if current_gun != _prev_gun_card:
		_prev_gun_card = current_gun
		if current_gun:
			EventBus.card_pack_changed.emit(current_gun)

	# Auto-reload when gun is empty
	if deck_state.is_gun_empty() and state != State.RELOADING:
		start_reload()
		return

	# --- Gun input (semi-auto: one shot per click) ---
	if Input.is_action_just_pressed("fire") and can_fire and state == State.IDLE:
		fire_gun()

	# --- Spell input (F key) ---
	if Input.is_action_just_pressed("cast_spell"):
		cast_spell()

	# --- Reload ---
	if Input.is_action_just_pressed("reload") and state != State.RELOADING:
		start_reload()


func fire_gun() -> void:
	var card := deck_state.fire_gun()
	if card == null:
		start_reload()
		return

	state = State.FIRING
	can_fire = false
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

	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(cam_from, cam_from + shoot_dir * max_ray_distance, 0b0101)
	var result := space.intersect_ray(query)

	if result:
		var collider = result.collider
		var hit_point: Vector3 = result.position

		if collider.has_method("take_bullet_hit"):
			collider.take_bullet_hit(card)
			EventBus.hit_confirmed.emit(hit_point, card, collider)
		else:
			EventBus.hit_missed.emit(hit_point, card)

		if card.piercing and collider.has_method("take_bullet_hit"):
			_pierce_check(hit_point, shoot_dir, card)
	else:
		EventBus.hit_missed.emit(cam_from + shoot_dir * max_ray_distance, card)

	EventBus.weapon_fired.emit(card)
	_emit_ammo_update()


func cast_spell() -> void:
	var spell := deck_state.get_active_spell()
	if spell == null:
		return

	# Consume the spell from hand
	deck_state.cast_spell()
	EventBus.spell_cast.emit(spell)
	_emit_spell_update()

	# Execute spell effect
	if spell.consumes_poison:
		_cast_detonator(spell)
	elif spell.grants_shield:
		_cast_barrier(spell)
	elif spell.area_burn:
		_cast_flashfire(spell)


func _cast_detonator(spell: CardData) -> void:
	# Hitscan raycast from camera center — must aim and hit
	var cam := get_viewport().get_camera_3d()
	if not cam:
		return

	var cam_from := cam.global_position
	var shoot_dir := -cam.global_transform.basis.z
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(cam_from, cam_from + shoot_dir * max_ray_distance, 0b0100)
	var result := space.intersect_ray(query)

	if not result or not result.collider.has_method("take_bullet_hit"):
		# Miss — spell wasted
		return

	var enemy = result.collider
	var status: StatusEffectComponent = enemy.get_node_or_null("StatusEffectComponent")
	if not status or status.poison_stacks <= 0:
		# No poison — base damage only (0 per GDD)
		EventBus.spell_detonator_hit.emit(enemy, 0.0, false)
		return

	# Toxic Fire: enemy has both Poison AND Burn → 6x multiplier instead of 3x
	var has_burn := status.is_burning
	var multiplier := 6.0 if has_burn else spell.poison_consume_multiplier
	var stacks := status.poison_stacks  # read before consuming
	status.detonate_poison()            # clears stacks, we don't use its return value
	var bonus_damage := stacks * multiplier

	enemy.take_damage(bonus_damage)
	EventBus.enemy_poison_detonated.emit(enemy, stacks, bonus_damage, has_burn)
	EventBus.spell_detonator_hit.emit(enemy, bonus_damage, has_burn)

	if has_burn:
		EventBus.hit_confirmed.emit(result.position, spell, enemy)


func _cast_barrier(spell: CardData) -> void:
	shield_hp = spell.shield_amount
	_shield_timer = spell.shield_duration
	EventBus.player_shield_changed.emit(shield_hp, spell.shield_amount)
	EventBus.spell_barrier_activated.emit(spell.shield_amount, spell.shield_duration)


func _cast_flashfire(spell: CardData) -> void:
	# Apply Burn to all enemies within area_burn_radius
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


func _pierce_check(from_point: Vector3, shoot_dir: Vector3, card: CardData) -> void:
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		from_point + shoot_dir * 0.1,
		from_point + shoot_dir * max_ray_distance,
		0b0100
	)
	var result := space_state.intersect_ray(query)
	if result and result.collider.has_method("take_bullet_hit"):
		result.collider.take_bullet_hit(card)
		EventBus.hit_confirmed.emit(result.position, card, result.collider)


func start_reload() -> void:
	if state == State.RELOADING:
		return
	state = State.RELOADING
	can_fire = false
	reload_timer.start()
	EventBus.weapon_reload_started.emit()


func is_reloading() -> bool:
	return state == State.RELOADING


func absorb_damage(amount: float) -> float:
	## Returns remaining damage after shield absorption
	if shield_hp <= 0:
		return amount
	var absorbed := minf(shield_hp, amount)
	shield_hp -= absorbed
	if shield_hp <= 0:
		shield_hp = 0.0
		_shield_timer = 0.0
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


func _get_current_spread() -> float:
	if _player and _player.has_method("get_is_ads") and _player.get_is_ads():
		return ads_spread
	if _player and _player.has_method("get_is_moving") and _player.get_is_moving():
		return move_spread
	return base_spread

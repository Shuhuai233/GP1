## Weapon — Revolver state machine per 3C document
## Semi-auto fire (click per shot), ADS spread, reload locks, dry-fire feedback
extends Node3D

enum State { IDLE, FIRING, RELOADING }

@export var fire_rate: float = 2.0  # shots per second
@export var reload_time: float = 2.0
@export var max_ray_distance: float = 100.0

@export_group("Spread")
@export var base_spread: float = 0.0  # degrees, standing still
@export var move_spread: float = 1.0  # degrees, while moving
@export var ads_spread: float = 0.0   # degrees, while ADS (perfect accuracy)

@onready var raycast: RayCast3D = $RayCast3D
@onready var muzzle_point: Marker3D = $MuzzlePoint
@onready var fire_timer: Timer = $FireTimer
@onready var reload_timer: Timer = $ReloadTimer

var state: State = State.IDLE
var deck_state: DeckState
var can_fire: bool = true
var _fired_this_click: bool = false  # Semi-auto: one shot per click

# Card resources — loaded on ready
var standard_round: CardData
var venom_round: CardData
var incendiary_round: CardData
var piercing_round: CardData
var detonator_round: CardData

var _prev_card: CardData = null

# Player reference for ADS/movement queries
var _player: Node3D = null


func _ready() -> void:
	# Load card resources
	standard_round = preload("res://data/cards/standard_round.tres")
	venom_round = preload("res://data/cards/venom_round.tres")
	incendiary_round = preload("res://data/cards/incendiary_round.tres")
	piercing_round = preload("res://data/cards/piercing_round.tres")
	detonator_round = preload("res://data/cards/detonator_round.tres")

	# Build starter deck: 3x Standard + 1x Venom + 1x Incendiary + 1x Piercing
	deck_state = DeckState.new()
	var starter: Array[CardData] = []
	for i in 3:
		starter.append(standard_round.duplicate())
	starter.append(venom_round.duplicate())
	starter.append(incendiary_round.duplicate())
	starter.append(piercing_round.duplicate())
	deck_state.initialize(starter)

	fire_timer.wait_time = 1.0 / fire_rate
	fire_timer.one_shot = true
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true

	fire_timer.timeout.connect(_on_fire_timer_timeout)
	reload_timer.timeout.connect(_on_reload_finished)

	raycast.target_position = Vector3(0, 0, -max_ray_distance)
	raycast.collision_mask = 0b0101  # layers 1 (environment) + 3 (enemies)

	# Find player
	_player = get_parent().get_parent().get_parent()  # WeaponHolder -> Head -> Player

	_emit_ammo_update()


func _process(_delta: float) -> void:
	if state == State.RELOADING:
		return

	# Check for card pack change
	var current := deck_state.get_current_card()
	if current != _prev_card:
		_prev_card = current
		if current:
			EventBus.card_pack_changed.emit(current)

	# Auto-reload when magazine is empty
	if deck_state.is_magazine_empty() and state != State.RELOADING:
		start_reload()
		return

	# Semi-auto: fire on press only, not hold
	if Input.is_action_just_pressed("fire"):
		_fired_this_click = false

	if Input.is_action_just_pressed("fire") and can_fire and state == State.IDLE:
		if not _fired_this_click:
			fire()
			_fired_this_click = true
	elif Input.is_action_just_pressed("fire") and (state == State.RELOADING or deck_state.is_magazine_empty()):
		# Dry-fire click — tried to fire with no ammo or during reload
		# TODO: Play dry-fire audio
		pass

	if Input.is_action_just_pressed("reload") and state != State.RELOADING:
		start_reload()


func fire() -> void:
	var card := deck_state.fire()
	if card == null:
		start_reload()
		return

	state = State.FIRING
	can_fire = false
	fire_timer.start()

	# Calculate spread
	var spread_degrees := _get_current_spread()
	var spread_rad := deg_to_rad(spread_degrees)

	# Apply spread to raycast direction
	if spread_rad > 0:
		var spread_offset := Vector3(
			randf_range(-spread_rad, spread_rad),
			randf_range(-spread_rad, spread_rad),
			0
		)
		raycast.target_position = (Vector3(0, 0, -max_ray_distance) + spread_offset * max_ray_distance).normalized() * max_ray_distance
	else:
		raycast.target_position = Vector3(0, 0, -max_ray_distance)

	# Raycast hit detection
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider := raycast.get_collider()
		var hit_point := raycast.get_collision_point()
		var hit_normal := raycast.get_collision_normal()

		if collider.has_method("take_bullet_hit"):
			collider.take_bullet_hit(card)
			EventBus.hit_confirmed.emit(hit_point, card, collider)
		else:
			EventBus.hit_missed.emit(hit_point, card)

		# Piercing: continue through first target
		if card.piercing and collider.has_method("take_bullet_hit"):
			_pierce_check(hit_point, hit_normal, card)
	else:
		# Total miss
		var miss_point := raycast.global_position + raycast.global_transform.basis * raycast.target_position
		EventBus.hit_missed.emit(miss_point, card)

	EventBus.weapon_fired.emit(card)
	_emit_ammo_update()


func _get_current_spread() -> float:
	if _player and _player.has_method("get_is_ads") and _player.get_is_ads():
		return ads_spread
	if _player and _player.has_method("get_is_moving") and _player.get_is_moving():
		return move_spread
	return base_spread


func _pierce_check(from_point: Vector3, _normal: Vector3, card: CardData) -> void:
	var space_state := get_world_3d().direct_space_state
	var forward := -global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(
		from_point + forward * 0.1,
		from_point + forward * max_ray_distance,
		0b0100  # Only enemies layer
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


func _on_fire_timer_timeout() -> void:
	can_fire = true
	state = State.IDLE


func _on_reload_finished() -> void:
	deck_state.reload()
	state = State.IDLE
	can_fire = true
	_prev_card = null
	_fired_this_click = false
	EventBus.weapon_reload_finished.emit()
	_emit_ammo_update()


func _emit_ammo_update() -> void:
	EventBus.ammo_changed.emit(
		deck_state.bullets_remaining_in_pack,
		deck_state.get_packs_remaining(),
		deck_state.get_current_card()
	)


func add_card_to_deck(card: CardData) -> void:
	deck_state.add_card(card)

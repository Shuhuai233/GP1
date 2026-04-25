## WaveManager — Spawns enemies in waves, detects wave clear, triggers card selection
## Between-wave flow per GDD §8: cleared text → breathing room → card pick → 25 HP heal → countdown
extends Node

@export var grunt_scene: PackedScene
@export var rusher_scene: PackedScene
@export var big_eye_scene: PackedScene

const BETWEEN_WAVE_HEAL: float = 25.0

var spawn_points: Array[Marker3D] = []
var player: Node3D = null
var enemy_container: Node3D = null

var current_wave: int = 0
var total_waves: int = 3
var enemies_alive: int = 0
var is_active: bool = false

var wave_defs: Array[Array] = [
	[["grunt", 3]],
	[["grunt", 2], ["big_eye", 1]],
	[["big_eye", 1], ["rusher", 4], ["grunt", 2]],
]

# Card pool for between-wave offers — no Standard Round per GDD §8
var _offer_pool: Array[CardData]


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.card_selected.connect(_on_card_selected)

	_offer_pool = [
		preload("res://data/cards/venom_round.tres"),
		preload("res://data/cards/incendiary_round.tres"),
		preload("res://data/cards/piercing_round.tres"),
		preload("res://data/cards/detonator_round.tres"),
		preload("res://data/cards/barrier.tres"),
		preload("res://data/cards/flashfire.tres"),
	]


func initialize(p_player: Node3D, p_spawn_points: Array[Marker3D], p_enemy_container: Node3D) -> void:
	player = p_player
	spawn_points = p_spawn_points
	enemy_container = p_enemy_container


func start_game() -> void:
	current_wave = 0
	is_active = true
	start_next_wave()


func start_next_wave() -> void:
	if current_wave >= total_waves:
		EventBus.all_waves_cleared.emit()
		return

	var wave_def := wave_defs[current_wave]
	enemies_alive = 0

	var spawn_index := 0
	for group in wave_def:
		var enemy_type: String = group[0]
		var count: int = group[1]
		for i in count:
			var enemy := _spawn_enemy(enemy_type, spawn_points[spawn_index % spawn_points.size()])
			if enemy:
				enemies_alive += 1
			spawn_index += 1

	current_wave += 1
	EventBus.wave_started.emit(current_wave)


func _spawn_enemy(type: String, spawn: Marker3D) -> EnemyBase:
	var scene: PackedScene
	match type:
		"grunt":   scene = grunt_scene
		"rusher":  scene = rusher_scene
		"big_eye": scene = big_eye_scene
		_:
			push_error("Unknown enemy type: " + type)
			return null

	if not scene:
		push_error("Scene not loaded for enemy type: " + type)
		return null

	var enemy: EnemyBase = scene.instantiate()
	enemy.global_position = spawn.global_position
	enemy.set_player_target(player)
	enemy_container.add_child(enemy)
	return enemy


func _on_enemy_died(_enemy: Node3D) -> void:
	enemies_alive -= 1
	if enemies_alive <= 0 and is_active:
		_wave_cleared()


func _wave_cleared() -> void:
	EventBus.wave_cleared.emit(current_wave)
	if current_wave >= total_waves:
		EventBus.all_waves_cleared.emit()
	else:
		_begin_between_wave_flow()


func _begin_between_wave_flow() -> void:
	# Step 1: WAVE CLEARED text shown (handled by main.gd via signal)
	# Step 2: 3s breathing room
	await get_tree().create_timer(3.0).timeout

	# Step 3: Card selection (never offer Standard Round)
	_offer_card_selection()


func _offer_card_selection() -> void:
	var pool := _offer_pool.duplicate()
	pool.shuffle()
	var offered: Array = []
	for card in pool:
		offered.append(card)
		if offered.size() >= 3:
			break
	EventBus.card_selection_started.emit(offered)


func _on_card_selected(_card: Resource) -> void:
	# Step 4: Heal 25 HP
	if player and player.has_method("heal"):
		player.heal(BETWEEN_WAVE_HEAL)
	EventBus.between_wave_heal.emit(BETWEEN_WAVE_HEAL)

	# Step 5: 3s countdown then next wave
	await get_tree().create_timer(3.0).timeout
	start_next_wave()

## WaveManager — Endless wave loop per GDD §8
## Waves 1-3 fixed. Wave 4+: scaling (+1-2 enemies, +10% HP per wave).
## Between every wave: cleared(3s) → rest(3s) → card pick → 25HP heal → countdown(3s) → 0.5s grace
extends Node

@export var grunt_scene: PackedScene
@export var rusher_scene: PackedScene
@export var big_eye_scene: PackedScene

const BETWEEN_WAVE_HEAL: float = 25.0
const HP_SCALE_PER_WAVE: float = 0.10   # +10% enemy HP per wave after wave 3
const ENEMY_ADD_PER_WAVE: int = 1        # +1 enemy every wave after wave 3 (sometimes 2)

# Stats for death recap
var total_enemies_killed: int = 0
var total_cards_collected: int = 0
var waves_survived: int = 0
var highest_combo_damage: float = 0.0  # GDD §8: track highest combo

var spawn_points: Array[Marker3D] = []
var player: Node3D = null
var enemy_container: Node3D = null
var current_wave: int = 0
var enemies_alive: int = 0
var is_active: bool = false
var _grace_active: bool = false

# Fixed wave defs for waves 1-3
var wave_defs: Array[Array] = [
	[["grunt", 3]],
	[["grunt", 2], ["big_eye", 1]],
	[["big_eye", 1], ["rusher", 4], ["grunt", 2]],
]

# Card pool: never Standard Round
var _offer_pool: Array[CardData]


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.card_selected.connect(_on_card_selected)
	EventBus.enemy_poison_detonated.connect(_on_detonator_hit)

	_offer_pool = [
		# NEUTRAL firing
		preload("res://data/cards/piercing_round.tres"),
		preload("res://data/cards/ricochet_round.tres"),
		preload("res://data/cards/drain_round.tres"),
		# NEUTRAL function
		preload("res://data/cards/barrier.tres"),
		preload("res://data/cards/vampiric_burst.tres"),
		preload("res://data/cards/reload_surge.tres"),
		# POWER firing
		preload("res://data/cards/heavy_round.tres"),
		preload("res://data/cards/armor_piercer.tres"),
		preload("res://data/cards/headhunter_round.tres"),
		preload("res://data/cards/explosive_round.tres"),
		# POWER function
		preload("res://data/cards/war_cry.tres"),
		preload("res://data/cards/iron_skin.tres"),
		preload("res://data/cards/megashot.tres"),
		preload("res://data/cards/executioner.tres"),
		# VENOM firing
		preload("res://data/cards/venom_round.tres"),
		preload("res://data/cards/toxic_needle.tres"),
		preload("res://data/cards/plague_round.tres"),
		# VENOM function
		preload("res://data/cards/detonator_round.tres"),
		preload("res://data/cards/toxin_bomb.tres"),
		preload("res://data/cards/pandemic.tres"),
		# BLAZE firing
		preload("res://data/cards/incendiary_round.tres"),
		preload("res://data/cards/ember_round.tres"),
		preload("res://data/cards/magma_round.tres"),
		# BLAZE function
		preload("res://data/cards/flashfire.tres"),
		preload("res://data/cards/inferno.tres"),
		preload("res://data/cards/fuel.tres"),
		# FLUX firing
		preload("res://data/cards/quicksilver_round.tres"),
		preload("res://data/cards/tempo_round.tres"),
		preload("res://data/cards/tracer_round.tres"),
		# FLUX function
		preload("res://data/cards/phase_dash.tres"),
		preload("res://data/cards/overclock.tres"),
		preload("res://data/cards/adrenaline.tres"),
		preload("res://data/cards/blink.tres"),
		# SHOCK firing
		preload("res://data/cards/volt_round.tres"),
		preload("res://data/cards/arc_round.tres"),
		preload("res://data/cards/static_round.tres"),
		# SHOCK function
		preload("res://data/cards/chain_lightning.tres"),
		preload("res://data/cards/spotter.tres"),
		preload("res://data/cards/emp_blast.tres"),
	]


func initialize(p_player: Node3D, p_spawn_points: Array[Marker3D], p_enemy_container: Node3D) -> void:
	player = p_player
	spawn_points = p_spawn_points
	enemy_container = p_enemy_container
	add_to_group("wave_manager")


func start_game() -> void:
	current_wave = 0
	total_enemies_killed = 0
	total_cards_collected = 0
	waves_survived = 0
	is_active = true
	start_next_wave()


func start_next_wave() -> void:
	current_wave += 1
	enemies_alive = 0

	var wave_enemies := _get_wave_enemies(current_wave)
	var hp_scale := _get_hp_scale(current_wave)

	var spawn_index := 0
	for entry in wave_enemies:
		var enemy_type: String = entry[0]
		var count: int = entry[1]
		for i in count:
			var enemy := _spawn_enemy(enemy_type, spawn_points[spawn_index % spawn_points.size()], hp_scale)
			if enemy:
				enemies_alive += 1
			spawn_index += 1

	EventBus.wave_started.emit(current_wave)


func _get_wave_enemies(wave: int) -> Array:
	if wave <= wave_defs.size():
		return wave_defs[wave - 1]

	# Wave 4+: +1-2 enemies per wave (GDD §8: "+1-2 per wave")
	var extra_waves := wave - wave_defs.size()
	var added := extra_waves + randi_range(0, 1)  # +1 or +2 per wave randomly
	var total_enemies := 7 + added
	# Randomize composition from all 3 types
	var enemies := []
	var remaining := total_enemies
	var big_eyes := mini(1 + extra_waves / 3, remaining / 3)
	var rushers := mini(2 + extra_waves / 2, remaining - big_eyes)
	var grunts := remaining - big_eyes - rushers
	if big_eyes > 0: enemies.append(["big_eye", big_eyes])
	if rushers > 0:  enemies.append(["rusher", rushers])
	if grunts > 0:   enemies.append(["grunt", grunts])
	return enemies


func _get_hp_scale(wave: int) -> float:
	if wave <= 3:
		return 1.0
	return 1.0 + (wave - 3) * HP_SCALE_PER_WAVE


func _spawn_enemy(type: String, spawn: Marker3D, hp_scale: float = 1.0) -> EnemyBase:
	var scene: PackedScene
	match type:
		"grunt":   scene = grunt_scene
		"rusher":  scene = rusher_scene
		"big_eye": scene = big_eye_scene
		_:
			push_error("Unknown enemy type: " + type)
			return null

	if not scene:
		push_error("Scene not loaded for: " + type)
		return null

	var enemy: EnemyBase = scene.instantiate()
	enemy.global_position = spawn.global_position
	enemy.set_player_target(player)
	enemy_container.add_child(enemy)

	# Apply HP scaling after _ready runs
	if hp_scale != 1.0:
		enemy.max_hp = enemy.max_hp * hp_scale
		enemy.current_hp = enemy.max_hp

	return enemy


func _on_enemy_died(_enemy: Node3D) -> void:
	total_enemies_killed += 1
	enemies_alive -= 1
	if enemies_alive <= 0 and is_active:
		_wave_cleared()


func _wave_cleared() -> void:
	waves_survived = current_wave
	EventBus.wave_cleared.emit(current_wave)
	_begin_between_wave_flow()


func _begin_between_wave_flow() -> void:
	# GDD §8 between-wave sequence:
	# Step 1: "WAVE X CLEARED" (3 sec) — signal already emitted, main.gd shows it
	await get_tree().create_timer(3.0).timeout

	# Step 2: Breathing room (3 sec) — just wait
	await get_tree().create_timer(3.0).timeout

	# Step 3: Card selection
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
	total_cards_collected += 1

	# Step 4: Heal 25 HP
	if player and player.has_method("heal"):
		player.heal(BETWEEN_WAVE_HEAL)
	EventBus.between_wave_heal.emit(BETWEEN_WAVE_HEAL)

	# Step 5: Wave countdown (3 sec)
	await get_tree().create_timer(3.0).timeout

	# Step 6: 0.5s grace period (invulnerability) — set flag, enemies won't deal damage
	_grace_active = true
	await get_tree().create_timer(0.5).timeout
	_grace_active = false

	start_next_wave()


func is_grace_period() -> bool:
	return _grace_active


func set_temporary_grace(duration: float) -> void:
	## Used by Phase Dash for brief invincibility during dash
	_grace_active = true
	get_tree().create_timer(duration).timeout.connect(func():
		# Only clear if not in a wave-transition grace period
		if not _grace_active:
			return
		_grace_active = false
	)


func _on_detonator_hit(_enemy: Node3D, _stacks: int, bonus_damage: float, _toxic_fire: bool) -> void:
	if bonus_damage > highest_combo_damage:
		highest_combo_damage = bonus_damage


func get_recap_data() -> Dictionary:
	return {
		"waves_survived": waves_survived,
		"enemies_killed": total_enemies_killed,
		"cards_collected": total_cards_collected,
		"highest_combo": highest_combo_damage,
	}

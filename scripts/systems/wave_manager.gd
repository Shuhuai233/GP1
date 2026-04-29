## WaveManager — Endless wave loop per GDD §8
## New loot system per WEAPONS_AND_CARDS.md §6: function card / attachment / weapon / free attachment
extends Node

@export var grunt_scene: PackedScene
@export var rusher_scene: PackedScene
@export var big_eye_scene: PackedScene

const BETWEEN_WAVE_HEAL: float = 25.0
const HP_SCALE_PER_WAVE: float = 0.10

# Stats for death recap
var total_enemies_killed: int = 0
var total_items_collected: int = 0
var waves_survived: int = 0
var highest_combo_damage: float = 0.0

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

# Loot pools
var _function_card_pool: Array[FunctionCardData] = []
var _attachment_pool: Array[AttachmentData] = []
var _weapon_pool: Array[WeaponData] = []


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.loot_item_selected.connect(_on_loot_selected)
	EventBus.enemy_poison_detonated.connect(_on_detonator_hit)
	add_to_group("wave_manager")
	_build_loot_pools()

func _build_loot_pools() -> void:
	# Function cards (all 20)
	_function_card_pool = [
		preload("res://data/function_cards/poison_magazine.tres"),
		preload("res://data/function_cards/fire_magazine.tres"),
		preload("res://data/function_cards/shock_magazine.tres"),
		preload("res://data/function_cards/frost_magazine.tres"),
		preload("res://data/function_cards/explosive_magazine.tres"),
		preload("res://data/function_cards/dash.tres"),
		preload("res://data/function_cards/blink.tres"),
		preload("res://data/function_cards/shield_wall.tres"),
		preload("res://data/function_cards/iron_skin.tres"),
		preload("res://data/function_cards/adrenaline.tres"),
		preload("res://data/function_cards/vampiric_aura.tres"),
		preload("res://data/function_cards/war_cry.tres"),
		preload("res://data/function_cards/time_warp.tres"),
		preload("res://data/function_cards/detonator.tres"),
		preload("res://data/function_cards/chain_detonation.tres"),
		preload("res://data/function_cards/purge.tres"),
		preload("res://data/function_cards/shatter.tres"),
		preload("res://data/function_cards/spotter.tres"),
		preload("res://data/function_cards/reload_surge.tres"),
		preload("res://data/function_cards/magnetize.tres"),
	]
	# Attachments (all 15)
	_attachment_pool = [
		preload("res://data/attachments/split_barrel.tres"),
		preload("res://data/attachments/explosive_tips.tres"),
		preload("res://data/attachments/ricochet_chamber.tres"),
		preload("res://data/attachments/piercing_barrel.tres"),
		preload("res://data/attachments/chain_link.tres"),
		preload("res://data/attachments/drum_magazine.tres"),
		preload("res://data/attachments/speed_loader.tres"),
		preload("res://data/attachments/double_feed.tres"),
		preload("res://data/attachments/holo_sight.tres"),
		preload("res://data/attachments/thermal_scope.tres"),
		preload("res://data/attachments/steady_grip.tres"),
		preload("res://data/attachments/quick_grip.tres"),
		preload("res://data/attachments/vampiric_barrel.tres"),
		preload("res://data/attachments/elemental_converter.tres"),
		preload("res://data/attachments/chaos_engine.tres"),
	]
	# Weapons (all 6 except Revolver which is the starter)
	_weapon_pool = [
		preload("res://data/weapons/ar.tres"),
		preload("res://data/weapons/smg.tres"),
		preload("res://data/weapons/shotgun.tres"),
		preload("res://data/weapons/sniper.tres"),
		preload("res://data/weapons/machine_pistol.tres"),
	]


func initialize(p_player: Node3D, p_spawn_points: Array[Marker3D], p_enemy_container: Node3D) -> void:
	player = p_player
	spawn_points = p_spawn_points
	enemy_container = p_enemy_container


func start_game() -> void:
	current_wave = 0
	total_enemies_killed = 0
	total_items_collected = 0
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
	# Brief pause after wave cleared banner, then straight to loot
	await get_tree().create_timer(2.0).timeout
	# Loot offering (new system)
	_offer_loot()


func _offer_loot() -> void:
	## Wave 1: weapons appear; Wave 1: no attachments yet (wave 2+)
	var items: Array = []

	# Always guarantee 1 function card
	var fc_pool := _function_card_pool.duplicate()
	fc_pool.shuffle()
	if fc_pool.size() > 0:
		items.append({"type": "function_card", "data": fc_pool[0]})

	# Fill remaining 2 slots based on rarity
	var remaining_slots := 3 - items.size()
	for _i in remaining_slots:
		var roll := randf()
		if roll < 0.4:
			# Another function card
			if fc_pool.size() > items.size():
				items.append({"type": "function_card", "data": fc_pool[items.size() % fc_pool.size()]})
			else:
				items.append(_pick_attachment())
		elif roll < 0.7 and current_wave >= 2:
			items.append(_pick_attachment())
		elif roll < 0.9 and current_wave >= 1:
			items.append(_pick_weapon())
		elif current_wave >= 2:
			# Free attachment (~10%)
			var att := _pick_attachment()
			att["type"] = "free_attachment"
			items.append(att)
		else:
			items.append({"type": "function_card", "data": fc_pool[randi() % fc_pool.size()]})

	# Ensure exactly 3 items
	while items.size() < 3:
		items.append({"type": "function_card", "data": fc_pool[randi() % fc_pool.size()]})

	EventBus.loot_offering_started.emit(items)


func _pick_attachment() -> Dictionary:
	if _attachment_pool.is_empty():
		return {"type": "function_card", "data": _function_card_pool[0]}
	var pool := _attachment_pool.duplicate()
	pool.shuffle()
	return {"type": "attachment", "data": pool[0]}


func _pick_weapon() -> Dictionary:
	if _weapon_pool.is_empty():
		return {"type": "function_card", "data": _function_card_pool[0]}
	var pool := _weapon_pool.duplicate()
	pool.shuffle()
	return {"type": "weapon", "data": pool[0]}


func _on_loot_selected(_item: Dictionary) -> void:
	total_items_collected += 1
	# Step 4: Heal 25 HP
	if player and player.has_method("heal"):
		player.heal(BETWEEN_WAVE_HEAL)
	EventBus.between_wave_heal.emit(BETWEEN_WAVE_HEAL)
	# Step 5: Wave countdown (3 sec)
	await get_tree().create_timer(3.0).timeout
	# Step 6: 0.5s grace period
	_grace_active = true
	await get_tree().create_timer(0.5).timeout
	_grace_active = false
	start_next_wave()


func is_grace_period() -> bool:
	return _grace_active


func set_temporary_grace(duration: float) -> void:
	## Wave-transition grace (called from weapon_controller for Quick Grip)
	_grace_active = true
	get_tree().create_timer(duration).timeout.connect(func():
		# Only clear if still in a temporary grace (not a wave-transition grace)
		if _grace_active:
			_grace_active = false
	)


func _on_detonator_hit(_enemy: Node3D, _stacks: int, bonus_damage: float, _toxic_fire: bool) -> void:
	if bonus_damage > highest_combo_damage:
		highest_combo_damage = bonus_damage


func get_recap_data() -> Dictionary:
	return {
		"waves_survived": waves_survived,
		"enemies_killed": total_enemies_killed,
		"items_collected": total_items_collected,
		"highest_combo": highest_combo_damage,
	}

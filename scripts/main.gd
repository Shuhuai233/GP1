## Main — Root scene, game state management
## Endless wave loop: no win state. Death shows recap. Restart resets all.
extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var arena: Node3D = $Arena
@onready var enemy_container: Node3D = $EnemyContainer
@onready var wave_manager: Node = $WaveManager
@onready var player_hud: CanvasLayer = $PlayerHUD
@onready var card_selection_ui: CanvasLayer = $CardSelectionUI
@onready var visual_feedback: Node3D = $VisualFeedback
@onready var game_over_label: Label = $GameOverUI/GameOverLabel
@onready var recap_label: Label = $GameOverUI/RecapLabel
@onready var restart_button: Button = $GameOverUI/RestartButton
@onready var wave_label: Label = $WaveUI/WaveLabel

var is_game_over: bool = false


func _ready() -> void:
	var player_spawn: Marker3D = arena.get_node("SpawnPoints/PlayerSpawn")
	if player_spawn:
		player.global_position = player_spawn.global_position

	var spawn_points: Array[Marker3D] = []
	var spawns_node := arena.get_node("SpawnPoints")
	for child in spawns_node.get_children():
		if child.name.begins_with("EnemySpawn"):
			spawn_points.append(child as Marker3D)

	wave_manager.initialize(player, spawn_points, enemy_container)

	EventBus.player_died.connect(_on_player_died)
	EventBus.wave_started.connect(_on_wave_started)
	EventBus.wave_cleared.connect(_on_wave_cleared)
	EventBus.card_selected.connect(_on_card_selected)
	restart_button.pressed.connect(_on_restart_pressed)

	$GameOverUI.visible = false
	wave_label.visible = false

	await get_tree().create_timer(1.0).timeout
	wave_manager.start_game()


func _on_player_died() -> void:
	if is_game_over:
		return
	is_game_over = true

	# Show recap per GDD §8
	var recap: Dictionary = wave_manager.get_recap_data()
	game_over_label.text = "YOU DIED"
	recap_label.text = "Waves survived: %d\nEnemies killed: %d\nCards collected: %d\nHighest combo: %.0f dmg" % [
		recap["waves_survived"],
		recap["enemies_killed"],
		recap["cards_collected"],
		recap["highest_combo"],
	]
	$GameOverUI.visible = true
	restart_button.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_wave_started(wave_number: int) -> void:
	wave_label.visible = true
	wave_label.modulate.a = 1.0
	wave_label.text = "WAVE %d" % wave_number
	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(wave_label, "modulate:a", 0.0, 0.5)


func _on_wave_cleared(wave_number: int) -> void:
	wave_label.visible = true
	wave_label.modulate.a = 1.0
	wave_label.text = "WAVE %d CLEARED" % wave_number
	var tween := create_tween()
	tween.tween_interval(3.0)  # Hold full 3s per GDD §8
	tween.tween_property(wave_label, "modulate:a", 0.0, 0.5)


func _on_card_selected(card: Resource) -> void:
	var weapon := player.get_node("Head/WeaponHolder")
	if weapon and weapon.has_method("add_card_to_deck"):
		weapon.add_card_to_deck(card.duplicate())


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

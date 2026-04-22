## PlayerHUD — Crosshair (dot+circle, color-tinted), ammo, HP, hit markers
## Per 3C doc: crosshair expands on move, tightens on ADS, fades on reload
extends CanvasLayer

@onready var crosshair: Control = $Crosshair
@onready var crosshair_dot: ColorRect = $Crosshair/CrosshairDot
@onready var crosshair_top: ColorRect = $Crosshair/CrosshairTop
@onready var crosshair_bottom: ColorRect = $Crosshair/CrosshairBottom
@onready var crosshair_left: ColorRect = $Crosshair/CrosshairLeft
@onready var crosshair_right: ColorRect = $Crosshair/CrosshairRight
@onready var ammo_label: Label = $AmmoContainer/AmmoLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var card_icon: ColorRect = $CardIcon
@onready var reload_label: Label = $ReloadLabel
@onready var pack_indicators: HBoxContainer = $PackIndicators
@onready var hit_marker: Control = $HitMarker

var base_spread_offset: float = 8.0  # pixels from center for crosshair arms
var move_spread_offset: float = 12.0
var ads_spread_offset: float = 2.0

var current_spread_offset: float = 8.0
var target_spread_offset: float = 8.0
var crosshair_color: Color = Color.WHITE

var _player: Node3D = null


func _ready() -> void:
	EventBus.ammo_changed.connect(_on_ammo_changed)
	EventBus.card_pack_changed.connect(_on_card_pack_changed)
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.weapon_reload_started.connect(_on_reload_started)
	EventBus.weapon_reload_finished.connect(_on_reload_finished)
	EventBus.hit_confirmed.connect(_on_hit_confirmed)
	EventBus.enemy_died.connect(_on_enemy_killed)
	EventBus.enemy_poison_detonated.connect(_on_poison_detonated)
	reload_label.visible = false
	if hit_marker:
		hit_marker.modulate.a = 0.0

	# Find player after scene is ready
	await get_tree().process_frame
	_player = get_tree().get_first_node_in_group("player")
	if not _player:
		var players := get_tree().get_nodes_in_group("enemies")  # fallback
		# Try to find by node name
		_player = get_node_or_null("/root/Main/Player")


func _process(delta: float) -> void:
	# Update crosshair spread based on player state
	if _player:
		if _player.has_method("get_is_ads") and _player.get_is_ads():
			target_spread_offset = ads_spread_offset
			# ADS: dot only (hide arms)
			_set_arms_visible(false)
		else:
			_set_arms_visible(true)
			if _player.has_method("get_is_moving") and _player.get_is_moving():
				target_spread_offset = move_spread_offset
			else:
				target_spread_offset = base_spread_offset

	current_spread_offset = lerp(current_spread_offset, target_spread_offset, delta * 15.0)
	_update_crosshair_positions()


func _set_arms_visible(vis: bool) -> void:
	if crosshair_top: crosshair_top.visible = vis
	if crosshair_bottom: crosshair_bottom.visible = vis
	if crosshair_left: crosshair_left.visible = vis
	if crosshair_right: crosshair_right.visible = vis


func _update_crosshair_positions() -> void:
	# Move crosshair arms based on spread offset
	var offset := current_spread_offset
	if crosshair_top:
		crosshair_top.position.y = -offset - crosshair_top.size.y
	if crosshair_bottom:
		crosshair_bottom.position.y = offset
	if crosshair_left:
		crosshair_left.position.x = -offset - crosshair_left.size.x
	if crosshair_right:
		crosshair_right.position.x = offset


func _on_ammo_changed(bullets_in_pack: int, packs_remaining: int, current_card: Resource) -> void:
	if current_card:
		ammo_label.text = "%d" % bullets_in_pack
		_update_crosshair_color(current_card.color)
		_update_pack_indicators(packs_remaining)
	else:
		ammo_label.text = "0"


func _on_card_pack_changed(card: Resource) -> void:
	_update_crosshair_color(card.color)
	card_icon.color = card.color

	# Brief flash on card change
	var tween := create_tween()
	crosshair.modulate = Color.WHITE * 2.0
	tween.tween_property(crosshair, "modulate", Color.WHITE, 0.2)


func _on_health_changed(current: float, max_hp: float) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current

	if current / max_hp < 0.3:
		hp_bar.modulate = Color(1, 0.3, 0.3)
	else:
		hp_bar.modulate = Color.WHITE


func _on_reload_started() -> void:
	reload_label.visible = true
	ammo_label.text = "--"

	# Crosshair fades to 50% per 3C doc
	var tween := create_tween()
	tween.tween_property(crosshair, "modulate:a", 0.5, 0.2)

	# Pulse reload label
	var pulse := create_tween().set_loops()
	pulse.tween_property(reload_label, "modulate:a", 0.3, 0.4)
	pulse.tween_property(reload_label, "modulate:a", 1.0, 0.4)


func _on_reload_finished() -> void:
	reload_label.visible = false
	var tween := create_tween()
	tween.tween_property(crosshair, "modulate:a", 1.0, 0.15)


func _on_hit_confirmed(_pos: Vector3, _card: Resource, _enemy: Node3D) -> void:
	# Hit marker: brief crosshair expansion + white ticks
	_show_hit_marker(Color.WHITE, 0.15)
	# Brief crosshair kick
	current_spread_offset += 4.0


func _on_enemy_killed(_enemy: Node3D) -> void:
	# Kill marker: larger X flash
	_show_hit_marker(Color(1, 0.3, 0.3), 0.3)


func _on_poison_detonated(_enemy: Node3D, _stacks: int, _bonus: float) -> void:
	# Detonator execute: large purple burst
	_show_hit_marker(Color(0.7, 0.2, 1.0), 0.5)


func _show_hit_marker(color: Color, duration: float) -> void:
	if not hit_marker:
		return
	hit_marker.modulate = Color(color.r, color.g, color.b, 1.0)
	var tween := create_tween()
	tween.tween_property(hit_marker, "modulate:a", 0.0, duration)


func _update_crosshair_color(color: Color) -> void:
	crosshair_color = color
	crosshair_dot.color = color
	if crosshair_top: crosshair_top.color = Color(color.r, color.g, color.b, 0.8)
	if crosshair_bottom: crosshair_bottom.color = Color(color.r, color.g, color.b, 0.8)
	if crosshair_left: crosshair_left.color = Color(color.r, color.g, color.b, 0.8)
	if crosshair_right: crosshair_right.color = Color(color.r, color.g, color.b, 0.8)
	ammo_label.add_theme_color_override("font_color", color)


func _update_pack_indicators(packs_remaining: int) -> void:
	for i in pack_indicators.get_child_count():
		var indicator: ColorRect = pack_indicators.get_child(i)
		indicator.modulate.a = 1.0 if i < packs_remaining else 0.2

## PlayerHUD — Crosshair (dot+arms, color-tinted), ammo, HP, hit markers
## Per 3C doc: crosshair expands on move, tightens on ADS (dot only), fades on reload
## Over-enemy detection turns dot red. Poison stack popup. Kill/detonator markers.
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
@onready var stack_popup: Label = $StackPopup

var base_spread_offset: float = 8.0
var move_spread_offset: float = 9.0  # +1px per 3C doc
var ads_spread_offset: float = 2.0

var current_spread_offset: float = 8.0
var target_spread_offset: float = 8.0
var crosshair_color: Color = Color.WHITE
var _over_enemy: bool = false

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
	EventBus.enemy_status_applied.connect(_on_enemy_status_applied)
	reload_label.visible = false
	if hit_marker:
		hit_marker.modulate.a = 0.0
	if stack_popup:
		stack_popup.modulate.a = 0.0

	# Find player
	await get_tree().process_frame
	_player = get_node_or_null("/root/Main/Player")


func _process(delta: float) -> void:
	# Update crosshair spread based on player state
	if _player:
		if _player.has_method("get_is_ads") and _player.get_is_ads():
			target_spread_offset = ads_spread_offset
			_set_arms_visible(false)
		else:
			_set_arms_visible(true)
			if _player.has_method("get_is_moving") and _player.get_is_moving():
				target_spread_offset = move_spread_offset
			else:
				target_spread_offset = base_spread_offset

	current_spread_offset = lerp(current_spread_offset, target_spread_offset, delta * 15.0)
	_update_crosshair_positions()

	# Over-enemy detection: raycast from camera center to detect enemy under crosshair
	_update_over_enemy_detection()


func _update_over_enemy_detection() -> void:
	var cam := get_viewport().get_camera_3d()
	if not cam:
		_set_dot_over_enemy(false)
		return

	var space := cam.get_world_3d().direct_space_state
	var from := cam.global_position
	var to := from + (-cam.global_transform.basis.z) * 100.0
	var query := PhysicsRayQueryParameters3D.create(from, to, 0b0100)  # enemies layer only
	var result := space.intersect_ray(query)

	_set_dot_over_enemy(result != null and not result.is_empty())


func _set_dot_over_enemy(over: bool) -> void:
	if over and not _over_enemy:
		_over_enemy = true
		crosshair_dot.color = Color.RED
	elif not over and _over_enemy:
		_over_enemy = false
		crosshair_dot.color = crosshair_color


func _set_arms_visible(vis: bool) -> void:
	if crosshair_top: crosshair_top.visible = vis
	if crosshair_bottom: crosshair_bottom.visible = vis
	if crosshair_left: crosshair_left.visible = vis
	if crosshair_right: crosshair_right.visible = vis


func _update_crosshair_positions() -> void:
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

	var tween := create_tween()
	tween.tween_property(crosshair, "modulate:a", 0.5, 0.2)

	var pulse := create_tween().set_loops()
	pulse.tween_property(reload_label, "modulate:a", 0.3, 0.4)
	pulse.tween_property(reload_label, "modulate:a", 1.0, 0.4)


func _on_reload_finished() -> void:
	reload_label.visible = false
	var tween := create_tween()
	tween.tween_property(crosshair, "modulate:a", 1.0, 0.15)


func _on_hit_confirmed(_pos: Vector3, _card: Resource, _enemy: Node3D) -> void:
	_show_hit_marker(Color.WHITE, 0.15)
	current_spread_offset += 4.0


func _on_enemy_killed(_enemy: Node3D) -> void:
	_show_hit_marker(Color(1, 0.3, 0.3), 0.3)


func _on_poison_detonated(_enemy: Node3D, _stacks: int, _bonus: float) -> void:
	_show_hit_marker(Color(0.7, 0.2, 1.0), 0.5)


func _on_enemy_status_applied(_enemy: Node3D, status_type: String, stacks: int) -> void:
	# Poison stack popup: green number near crosshair
	if status_type == "poison" and stack_popup:
		stack_popup.text = "+%d" % stacks
		stack_popup.modulate = Color(0.2, 0.9, 0.2, 1.0)
		stack_popup.position = Vector2(20, -10)  # Offset from center
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(stack_popup, "position:y", -25.0, 0.4)
		tween.tween_property(stack_popup, "modulate:a", 0.0, 0.4).set_delay(0.15)


func _show_hit_marker(color: Color, duration: float) -> void:
	if not hit_marker:
		return
	hit_marker.modulate = Color(color.r, color.g, color.b, 1.0)
	var tween := create_tween()
	tween.tween_property(hit_marker, "modulate:a", 0.0, duration)


func _update_crosshair_color(color: Color) -> void:
	crosshair_color = color
	if not _over_enemy:
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

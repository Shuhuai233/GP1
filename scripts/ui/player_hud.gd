## PlayerHUD — Updated for new weapon system signals + old compat
## Listens to weapon_state_changed (new) and ammo_changed (old compat)
## Shows: active weapon name + ammo, spell hand, crosshair, HP, shield, combo popups
extends CanvasLayer

@onready var crosshair: Control = $Crosshair
@onready var crosshair_dot: ColorRect = $Crosshair/CrosshairDot
@onready var crosshair_top: ColorRect = $Crosshair/CrosshairTop
@onready var crosshair_bottom: ColorRect = $Crosshair/CrosshairBottom
@onready var crosshair_left: ColorRect = $Crosshair/CrosshairLeft
@onready var crosshair_right: ColorRect = $Crosshair/CrosshairRight
@onready var ammo_label: Label = $AmmoContainer/AmmoLabel
@onready var weapon_name_label: Label = $AmmoContainer/WeaponNameLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var shield_bar: ProgressBar = $ShieldBar
@onready var reload_label: Label = $ReloadLabel
@onready var hit_marker: Control = $HitMarker
@onready var stack_popup: Label = $StackPopup

var base_spread_offset: float = 8.0
var move_spread_offset: float = 9.0
var ads_spread_offset: float = 2.0
var current_spread_offset: float = 8.0
var target_spread_offset: float = 8.0
var crosshair_color: Color = Color.WHITE
var _over_enemy: bool = false

var _player: Node3D = null


func _ready() -> void:
	# New weapon system signals
	EventBus.weapon_state_changed.connect(_on_weapon_state_changed)
	EventBus.spell_hand_state_changed.connect(_on_spell_hand_state_changed)
	EventBus.weapon_fired_new.connect(_on_weapon_fired_new)
	EventBus.hit_confirmed_new.connect(_on_hit_confirmed_new)
	EventBus.iron_skin_activated.connect(_on_iron_skin)
	EventBus.combo_triggered.connect(_on_combo_triggered)

	# Legacy signals (old weapon.gd fallback)
	EventBus.ammo_changed.connect(_on_ammo_changed)
	EventBus.weapon_reload_started.connect(_on_reload_started)
	EventBus.weapon_reload_finished.connect(_on_reload_finished)
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.player_shield_changed.connect(_on_shield_changed)
	EventBus.hit_confirmed.connect(_on_hit_confirmed)
	EventBus.enemy_died.connect(_on_enemy_killed)
	EventBus.enemy_poison_detonated.connect(_on_poison_detonated)
	EventBus.enemy_status_applied.connect(_on_enemy_status_applied)

	if hit_marker: hit_marker.modulate.a = 0.0
	if stack_popup: stack_popup.modulate.a = 0.0
	if shield_bar: shield_bar.visible = false

	await get_tree().process_frame
	_player = get_node_or_null("/root/Main/Player")


func _process(delta: float) -> void:
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
	_update_over_enemy_detection()


# ─── New system handlers ──────────────────────────────────────────────────────

func _on_weapon_state_changed(weapons: Array, active_slot: int) -> void:
	if active_slot >= weapons.size() or weapons[active_slot] == null:
		ammo_label.text = "--"
		weapon_name_label.text = ""
		return
	var w = weapons[active_slot]
	ammo_label.text = "%d / %d" % [w.bullets_remaining, w.effective_magazine_size]
	weapon_name_label.text = str(w.data.weapon_name)
	# Tint crosshair to magazine spell color if active
	if w.active_mag_spell:
		_update_crosshair_color(w.active_mag_spell.color)
	else:
		_update_crosshair_color(w.data.color)


func _on_spell_hand_state_changed(_spell_hand: Array, _consumed: Array, _active_index: int) -> void:
	pass  # Handled by spell_hand_ui.gd


func _on_weapon_fired_new(_wi: Object) -> void:
	current_spread_offset += 2.0


func _on_hit_confirmed_new(_pos: Vector3, _wi: Object, _enemy: Node3D) -> void:
	_show_hit_marker(Color.WHITE, 0.15)
	current_spread_offset += 4.0


func _on_iron_skin(hits: int) -> void:
	_show_combo_popup("IRON SKIN x%d" % hits, Color(0.6, 0.6, 0.6, 1))


func _on_combo_triggered(combo_name: String, _pos: Vector3) -> void:
	var color := Color.WHITE
	match combo_name:
		"TOXIC FIRE": color = Color(0.4, 1.0, 0.1, 1)
		"BRITTLE": color = Color(0.8, 0.95, 1.0, 1)
		"CONTAGION": color = Color(0.2, 0.8, 0.3, 1)
		"MARKED FOR DEATH": color = Color(1.0, 0.3, 0.3, 1)
		"PERMAFROST": color = Color(0.5, 0.9, 1.0, 1)
	_show_combo_popup(combo_name, color)


# ─── Legacy handlers ──────────────────────────────────────────────────────────

func _on_ammo_changed(bullets_in_pack: int, _packs: int, current_card: Resource) -> void:
	if current_card:
		ammo_label.text = "%d" % bullets_in_pack
		_update_crosshair_color(current_card.color)


func _on_health_changed(current: float, max_hp: float) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current
	hp_bar.modulate = Color(1, 0.3, 0.3) if current / max_hp < 0.3 else Color.WHITE


func _on_shield_changed(shield: float, max_shield: float) -> void:
	if not shield_bar: return
	if max_shield <= 0:
		shield_bar.visible = false
		return
	shield_bar.visible = shield > 0
	shield_bar.max_value = max_shield
	shield_bar.value = shield


func _on_reload_started() -> void:
	if reload_label: reload_label.visible = true
	var tween := create_tween()
	tween.tween_property(crosshair, "modulate:a", 0.5, 0.2)


func _on_reload_finished() -> void:
	if reload_label: reload_label.visible = false
	var tween := create_tween()
	tween.tween_property(crosshair, "modulate:a", 1.0, 0.15)


func _on_hit_confirmed(_pos: Vector3, _card: Resource, _enemy: Node3D) -> void:
	_show_hit_marker(Color.WHITE, 0.15)
	current_spread_offset += 4.0


func _on_enemy_killed(_enemy: Node3D) -> void:
	_show_hit_marker(Color(1, 0.3, 0.3), 0.3)


func _on_poison_detonated(_enemy: Node3D, _stacks: int, bonus: float, toxic_fire: bool) -> void:
	_show_hit_marker(Color(0.7, 0.2, 1.0), 0.5)
	var flash := ColorRect.new()
	flash.color = Color(0.4, 0.0, 0.6, 0.3)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(flash)
	var ftween := create_tween()
	ftween.tween_property(flash, "modulate:a", 0.0, 0.3)
	ftween.tween_callback(flash.queue_free)
	var popup := Label.new()
	popup.text = "TOXIC FIRE! +%.0f" % bonus if toxic_fire else "BOOM! +%.0f" % bonus
	popup.add_theme_font_size_override("font_size", 22)
	var popup_color := Color(0.4, 1.0, 0.1, 1.0) if toxic_fire else Color(0.7, 0.2, 1.0, 1.0)
	popup.add_theme_color_override("font_color", popup_color)
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.position = get_viewport().get_visible_rect().size / 2.0 + Vector2(-60, -50)
	add_child(popup)
	var tween2 := create_tween().set_parallel(true)
	tween2.tween_property(popup, "position:y", popup.position.y - 40, 0.6)
	tween2.tween_property(popup, "modulate:a", 0.0, 0.6).set_delay(0.2)
	tween2.tween_callback(popup.queue_free).set_delay(0.8)


func _on_enemy_status_applied(_enemy: Node3D, status_type: String, stacks: int) -> void:
	if status_type == "poison" and stack_popup:
		stack_popup.text = "+%d" % stacks
		stack_popup.modulate = Color(0.2, 0.9, 0.2, 1.0)
		stack_popup.position = Vector2(20, -10)
		var tween := create_tween().set_parallel(true)
		tween.tween_property(stack_popup, "position:y", -25.0, 0.4)
		tween.tween_property(stack_popup, "modulate:a", 0.0, 0.4).set_delay(0.15)


# ─── Crosshair helpers ────────────────────────────────────────────────────────

func _update_over_enemy_detection() -> void:
	var cam := get_viewport().get_camera_3d()
	if not cam:
		_set_dot_over_enemy(false)
		return
	var space := cam.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(cam.global_position, cam.global_position + (-cam.global_transform.basis.z) * 100.0, 0b0100)
	var r := space.intersect_ray(q)
	_set_dot_over_enemy(r != null and not r.is_empty())


func _set_dot_over_enemy(over: bool) -> void:
	if over and not _over_enemy:
		_over_enemy = true
		if crosshair_dot: crosshair_dot.color = Color.RED
	elif not over and _over_enemy:
		_over_enemy = false
		if crosshair_dot: crosshair_dot.color = crosshair_color


func _set_arms_visible(vis: bool) -> void:
	if crosshair_top: crosshair_top.visible = vis
	if crosshair_bottom: crosshair_bottom.visible = vis
	if crosshair_left: crosshair_left.visible = vis
	if crosshair_right: crosshair_right.visible = vis


func _update_crosshair_positions() -> void:
	var offset := current_spread_offset
	if crosshair_top: crosshair_top.position.y = -offset - crosshair_top.size.y
	if crosshair_bottom: crosshair_bottom.position.y = offset
	if crosshair_left: crosshair_left.position.x = -offset - crosshair_left.size.x
	if crosshair_right: crosshair_right.position.x = offset


func _update_crosshair_color(color: Color) -> void:
	crosshair_color = color
	if not _over_enemy and crosshair_dot: crosshair_dot.color = color
	for n in [crosshair_top, crosshair_bottom, crosshair_left, crosshair_right]:
		if n: n.color = Color(color.r, color.g, color.b, 0.8)
	if ammo_label: ammo_label.add_theme_color_override("font_color", color)


func _show_hit_marker(color: Color, duration: float) -> void:
	if not hit_marker: return
	hit_marker.modulate = Color(color.r, color.g, color.b, 1.0)
	var tween := create_tween()
	tween.tween_property(hit_marker, "modulate:a", 0.0, duration)


func _show_combo_popup(text: String, color: Color) -> void:
	var popup := Label.new()
	popup.text = text
	popup.add_theme_font_size_override("font_size", 20)
	popup.add_theme_color_override("font_color", color)
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.position = get_viewport().get_visible_rect().size / 2.0 + Vector2(-80, -80)
	add_child(popup)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(popup, "position:y", popup.position.y - 30, 0.7)
	tween.tween_property(popup, "modulate:a", 0.0, 0.7).set_delay(0.3)
	tween.tween_callback(popup.queue_free).set_delay(1.0)

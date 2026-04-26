## EnemyUI — Billboard UI above each enemy. All 6 status effects + combos.
class_name EnemyUI
extends Node3D

@onready var hp_bar_bg: MeshInstance3D = $HPBarBG
@onready var hp_bar_fill: MeshInstance3D = $HPBarFill
@onready var poison_label: Label3D = $PoisonLabel
@onready var burn_label: Label3D = $BurnLabel
@onready var combo_label: Label3D = $ComboLabel

var _has_burn: bool = false
var _has_poison: bool = false
var _has_slow: bool = false
var _has_freeze: bool = false
var _burn_pulse_time: float = 0.0


func _ready() -> void:
	hp_bar_bg.visible = false
	hp_bar_fill.visible = false
	poison_label.visible = false
	burn_label.visible = false
	combo_label.visible = false


func _process(delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam:
		var look_dir := cam.global_position - global_position
		look_dir.y = 0.0
		if look_dir.length_squared() > 0.001:
			look_at(global_position + look_dir, Vector3.UP)

	if burn_label.visible and _has_burn:
		_burn_pulse_time += delta * 4.0
		burn_label.modulate.a = lerp(0.8, 1.0, (sin(_burn_pulse_time) + 1.0) * 0.5)


func set_hp(current: float, max_val: float) -> void:
	hp_bar_bg.visible = true
	hp_bar_fill.visible = true
	var pct := clampf(current / max_val, 0.0, 1.0)
	hp_bar_fill.scale.x = pct
	hp_bar_fill.position.x = (pct - 1.0) * 0.6
	var mat: StandardMaterial3D = hp_bar_fill.get_surface_override_material(0)
	if mat:
		mat.albedo_color = Color(0.85, 0.1, 0.1, 1.0)


func set_poison(stacks: int) -> void:
	_has_poison = stacks > 0
	if stacks <= 0:
		poison_label.visible = false
	else:
		poison_label.visible = true
		poison_label.text = "☠ %d" % stacks
		var tween := create_tween()
		tween.tween_property(poison_label, "font_size", 43, 0.1)
		tween.tween_property(poison_label, "font_size", 36, 0.1)
	_update_combo()


func set_burn(burning: bool) -> void:
	_has_burn = burning
	_burn_pulse_time = 0.0
	burn_label.visible = burning
	if burning:
		burn_label.text = "🔥 BURN"
		burn_label.modulate = Color(1.0, 0.5, 0.0, 1.0)
	_update_combo()


func set_slow(slowed: bool) -> void:
	_has_slow = slowed
	if slowed:
		# Reuse burn_label row — append SLOW text
		burn_label.visible = true
		burn_label.text = (_get_status_text())
		burn_label.modulate = Color(0.5, 0.9, 1.0, 1.0)
	_update_combo()


func set_freeze(frozen: bool) -> void:
	_has_freeze = frozen
	if frozen:
		burn_label.visible = true
		burn_label.text = "❄ FROZEN"
		burn_label.modulate = Color(0.8, 0.95, 1.0, 1.0)
	_update_combo()


func _get_status_text() -> String:
	var parts: PackedStringArray = []
	if _has_burn: parts.append("🔥")
	if _has_slow: parts.append("❄SLOW")
	if _has_freeze: parts.append("❄FROZEN")
	return " ".join(parts)


func _update_combo() -> void:
	# Toxic Fire
	if _has_poison and _has_burn:
		combo_label.visible = true
		combo_label.text = "TOXIC FIRE"
		combo_label.modulate = Color(0.6, 1.0, 0.1, 1.0)
		var tween := create_tween()
		tween.tween_property(combo_label, "font_size", 54, 0.1)
		tween.tween_property(combo_label, "font_size", 36, 0.1)
		return
	# Brittle
	if _has_freeze:
		combo_label.visible = true
		combo_label.text = "BRITTLE"
		combo_label.modulate = Color(0.8, 0.95, 1.0, 1.0)
		return
	# Marked for Death
	if _has_burn:
		combo_label.visible = false  # shown by separate mark indicator
	else:
		combo_label.visible = false

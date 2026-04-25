## EnemyUI — Billboard UI above each enemy
## Displays: HP bar, poison stacks, burn indicator, status combo name
## Per GDD §7: must be readable at 20-30m. Billboard faces camera always.
class_name EnemyUI
extends Node3D

# References to sub-nodes
@onready var hp_bar_bg: MeshInstance3D = $HPBarBG
@onready var hp_bar_fill: MeshInstance3D = $HPBarFill
@onready var poison_label: Label3D = $PoisonLabel
@onready var burn_label: Label3D = $BurnLabel
@onready var combo_label: Label3D = $ComboLabel

var max_hp: float = 100.0
var current_hp: float = 100.0
var _has_taken_damage: bool = false
var _burn_pulse_time: float = 0.0


func _ready() -> void:
	# HP bar hidden at full HP
	hp_bar_bg.visible = false
	hp_bar_fill.visible = false
	poison_label.visible = false
	burn_label.visible = false
	combo_label.visible = false


func _process(delta: float) -> void:
	# Always face the camera (billboard)
	var cam := get_viewport().get_camera_3d()
	if cam:
		var look_dir := cam.global_position - global_position
		look_dir.y = 0.0  # Keep upright
		if look_dir.length_squared() > 0.001:
			look_at(global_position + look_dir, Vector3.UP)

	# Burn label pulsing
	if burn_label.visible:
		_burn_pulse_time += delta * 4.0
		burn_label.modulate.a = lerp(0.8, 1.0, (sin(_burn_pulse_time) + 1.0) * 0.5)


func set_hp(current: float, max_val: float) -> void:
	current_hp = current
	max_hp = max_val
	_has_taken_damage = true
	hp_bar_bg.visible = true
	hp_bar_fill.visible = true

	var pct := clampf(current / max_val, 0.0, 1.0)
	hp_bar_fill.scale.x = pct
	hp_bar_fill.position.x = (pct - 1.0) * 0.6

	# GDD §7: fill is RED, always
	var mat: StandardMaterial3D = hp_bar_fill.get_surface_override_material(0)
	if mat:
		mat.albedo_color = Color(0.85, 0.1, 0.1, 1.0)


func set_poison(stacks: int) -> void:
	if stacks <= 0:
		poison_label.visible = false
	else:
		poison_label.visible = true
		poison_label.text = "☠ %d" % stacks
		# Smooth pop: +20% font size over 0.1s, return over 0.1s
		var tween := create_tween()
		tween.tween_property(poison_label, "font_size", 43, 0.1)  # 36 * 1.2 ≈ 43
		tween.tween_property(poison_label, "font_size", 36, 0.1)
	_update_combo()


func set_burn(is_burning: bool) -> void:
	burn_label.visible = is_burning
	if is_burning:
		_burn_pulse_time = 0.0
		burn_label.text = "🔥 BURN"
		burn_label.modulate = Color(1.0, 0.5, 0.0, 1.0)
	_update_combo()


func _update_combo() -> void:
	# Toxic Fire: poison stacks > 0 AND burning
	var has_poison := poison_label.visible
	var has_burn := burn_label.visible
	if has_poison and has_burn:
		combo_label.visible = true
		combo_label.text = "TOXIC FIRE"
		# Flash activation: scale up then return
		var tween := create_tween()
		tween.tween_property(combo_label, "font_size", 54, 0.1)
		tween.tween_property(combo_label, "font_size", 36, 0.1)
	else:
		combo_label.visible = false

## BigEye — Slow, long-range, charged beam attack with telegraph
## HP: 100, Speed: Slow, Range: 20-30m, Damage: 20 charged beam (telegraphed)
extends EnemyBase

enum BigEyeState { IDLE, CHARGING, FIRING, COOLDOWN }

@export var charge_time: float = 2.0
@export var beam_damage: float = 20.0
@export var fire_cooldown: float = 3.0

var eye_state: BigEyeState = BigEyeState.IDLE
var charge_timer: float = 0.0
var cooldown_timer: float = 0.0
var beam_line: MeshInstance3D = null


func _ready() -> void:
	max_hp = 100.0
	move_speed = 1.0
	attack_damage = 25.0
	attack_range = 30.0
	attack_cooldown = 3.0
	super._ready()

	# Create beam telegraph visual (a thin cylinder)
	_create_beam_visual()


func _update_behavior(delta: float) -> void:
	var dist := global_position.distance_to(player.global_position)

	# Always look at player
	var look_target := player.global_position
	look_target.y = global_position.y
	look_at(look_target)

	# Slow drift toward preferred range
	if dist > attack_range:
		nav_agent.target_position = player.global_position
		if not nav_agent.is_navigation_finished():
			var next_pos := nav_agent.get_next_path_position()
			var direction := (next_pos - global_position).normalized()
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	# State machine
	match eye_state:
		BigEyeState.IDLE:
			if dist <= attack_range:
				eye_state = BigEyeState.CHARGING
				charge_timer = charge_time
				_show_telegraph(true)

		BigEyeState.CHARGING:
			charge_timer -= delta
			_update_telegraph()
			if charge_timer <= 0:
				eye_state = BigEyeState.FIRING
				_fire_beam()

		BigEyeState.FIRING:
			eye_state = BigEyeState.COOLDOWN
			cooldown_timer = fire_cooldown
			_show_telegraph(false)

		BigEyeState.COOLDOWN:
			cooldown_timer -= delta
			if cooldown_timer <= 0:
				eye_state = BigEyeState.IDLE


func _fire_beam() -> void:
	if not player or player.is_dead:
		return

	# Raycast beam
	var space := get_world_3d().direct_space_state
	var from := global_position + Vector3.UP * 1.5
	var to := player.global_position + Vector3.UP * 1.0
	var query := PhysicsRayQueryParameters3D.create(from, to, 0b0011)
	query.exclude = [get_rid()]
	var result := space.intersect_ray(query)
	if result and result.collider == player:
		player.take_damage(beam_damage)

	# Brief beam flash effect
	if beam_line:
		beam_line.visible = true
		var mat: StandardMaterial3D = beam_line.get_surface_override_material(0)
		if mat:
			mat.albedo_color = Color(1, 0.2, 0.2, 1)
		var tween := create_tween()
		tween.tween_property(beam_line, "visible", false, 0.2).set_delay(0.1)


func _create_beam_visual() -> void:
	beam_line = MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.03
	cyl.bottom_radius = 0.03
	cyl.height = 1.0
	beam_line.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0.3, 0.3, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1, 0.2, 0.2)
	mat.emission_energy_multiplier = 2.0
	beam_line.set_surface_override_material(0, mat)
	beam_line.visible = false
	add_child(beam_line)


func _show_telegraph(show: bool) -> void:
	if beam_line:
		beam_line.visible = show


func _update_telegraph() -> void:
	if not beam_line or not player:
		return

	var from := global_position + Vector3.UP * 1.5
	var to := player.global_position + Vector3.UP * 1.0
	var mid := (from + to) / 2.0
	var dist := from.distance_to(to)

	beam_line.global_position = mid
	beam_line.look_at(to, Vector3.UP)
	beam_line.rotate_object_local(Vector3.RIGHT, PI / 2.0)

	var cyl: CylinderMesh = beam_line.mesh
	cyl.height = dist

	# Pulse the telegraph as charge progresses
	var progress := 1.0 - (charge_timer / charge_time)
	var mat: StandardMaterial3D = beam_line.get_surface_override_material(0)
	if mat:
		mat.albedo_color.a = lerp(0.1, 0.6, progress)
		mat.emission_energy_multiplier = lerp(0.5, 3.0, progress)

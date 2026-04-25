## BigEye — Slow, long-range, charged beam attack with telegraph
## HP: 100, Speed: 1 m/s, Range: 20-30m, Damage: 20 via visible projectile (20 m/s)
## 1.5 sec charge-up with glowing telegraph, then fires large purple beam projectile
extends EnemyBase

enum BigEyeState { IDLE, CHARGING, FIRING, COOLDOWN }

@export var charge_time: float = 1.5
@export var beam_damage: float = 20.0
@export var fire_cooldown: float = 3.0

var eye_state: BigEyeState = BigEyeState.IDLE
var charge_timer: float = 0.0
var cooldown_timer: float = 0.0
var telegraph_mesh: MeshInstance3D = null
var eye_light: OmniLight3D = null

var _projectile_scene: PackedScene = preload("res://scenes/enemies/enemy_projectile.tscn")


func _ready() -> void:
	max_hp = 100.0
	move_speed = 1.0
	attack_damage = 20.0
	attack_range = 30.0
	attack_cooldown = 3.0
	super._ready()
	_create_telegraph_visual()


func _update_behavior(delta: float) -> void:
	var dist := global_position.distance_to(player.global_position)

	# Always face player
	var look_target := player.global_position
	look_target.y = global_position.y
	look_at(look_target)

	# Slow drift to preferred range
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

	match eye_state:
		BigEyeState.IDLE:
			if dist <= attack_range:
				eye_state = BigEyeState.CHARGING
				charge_timer = charge_time
				_set_telegraph(true)

		BigEyeState.CHARGING:
			charge_timer -= delta
			_update_telegraph_intensity(1.0 - charge_timer / charge_time)
			if charge_timer <= 0:
				eye_state = BigEyeState.FIRING
				_fire_beam_projectile()

		BigEyeState.FIRING:
			eye_state = BigEyeState.COOLDOWN
			cooldown_timer = fire_cooldown
			_set_telegraph(false)

		BigEyeState.COOLDOWN:
			cooldown_timer -= delta
			if cooldown_timer <= 0:
				eye_state = BigEyeState.IDLE


func _fire_beam_projectile() -> void:
	if not player or player.is_dead:
		return

	var from := global_position + Vector3.UP * 1.5
	var dir := (player.global_position + Vector3.UP * 1.0 - from).normalized()

	var proj: EnemyProjectile = _projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	# Large purple projectile: radius 0.25m visually, 20 m/s
	proj.init(from, dir, 20.0, beam_damage, Color(0.6, 0.1, 1.0, 1))
	# Scale up the mesh for big-eye beam feel
	proj.scale = Vector3(2.0, 2.0, 2.0)


func _create_telegraph_visual() -> void:
	# Glowing aura around BigEye that pulses during charge
	telegraph_mesh = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.55
	sphere.height = 3.1
	telegraph_mesh.mesh = sphere

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.1, 1.0, 0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.6, 0.1, 1.0)
	mat.emission_energy_multiplier = 0.0
	mat.cull_mode = BaseMaterial3D.CULL_FRONT  # Render inside-out for glow effect
	telegraph_mesh.set_surface_override_material(0, mat)
	telegraph_mesh.visible = false
	add_child(telegraph_mesh)

	# Eye light — pulses during charge
	eye_light = OmniLight3D.new()
	eye_light.light_color = Color(0.6, 0.1, 1.0)
	eye_light.light_energy = 1.0
	eye_light.omni_range = 4.0
	add_child(eye_light)


func _set_telegraph(show: bool) -> void:
	if telegraph_mesh:
		telegraph_mesh.visible = show


func _update_telegraph_intensity(progress: float) -> void:
	if not telegraph_mesh:
		return
	var mat: StandardMaterial3D = telegraph_mesh.get_surface_override_material(0)
	if mat:
		mat.emission_energy_multiplier = lerp(0.0, 6.0, progress)
		mat.albedo_color.a = lerp(0.1, 0.6, progress)
	if eye_light:
		eye_light.light_energy = lerp(1.0, 8.0, progress)

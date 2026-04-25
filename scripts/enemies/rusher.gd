## Rusher — Fast melee, sprints at player with visible 0.5s wind-up before hitting
## HP: 20, Speed: 9 m/s, Range: 0-5m, Damage: 10 melee
extends EnemyBase

const MELEE_RANGE: float = 2.5
const WINDUP_TIME: float = 0.5

enum RusherState { CHASING, WINDING_UP, STRIKING, RECOVERING }

var rusher_state: RusherState = RusherState.CHASING
var windup_timer: float = 0.0
var windup_mesh: MeshInstance3D = null  # Visual indicator during windup


func _ready() -> void:
	max_hp = 20.0
	move_speed = 9.0
	attack_damage = 10.0
	attack_range = 5.0
	attack_cooldown = 1.0
	super._ready()
	_create_windup_indicator()


func _update_behavior(delta: float) -> void:
	var dist := global_position.distance_to(player.global_position)

	var look_target := player.global_position
	look_target.y = global_position.y
	look_at(look_target)

	match rusher_state:
		RusherState.CHASING:
			if dist > MELEE_RANGE:
				_move_toward_player()
			else:
				velocity.x = 0.0
				velocity.z = 0.0
				if attack_timer <= 0:
					rusher_state = RusherState.WINDING_UP
					windup_timer = WINDUP_TIME
					_show_windup(true)

		RusherState.WINDING_UP:
			velocity.x = 0.0
			velocity.z = 0.0
			windup_timer -= delta
			# Visual intensity ramps up
			_update_windup_intensity(1.0 - windup_timer / WINDUP_TIME)
			if windup_timer <= 0:
				rusher_state = RusherState.STRIKING
				_melee_strike()

		RusherState.STRIKING:
			rusher_state = RusherState.RECOVERING
			_show_windup(false)
			attack_timer = attack_cooldown

		RusherState.RECOVERING:
			velocity.x = 0.0
			velocity.z = 0.0
			if attack_timer <= 0:
				rusher_state = RusherState.CHASING


func _move_toward_player() -> void:
	nav_agent.target_position = player.global_position
	if not nav_agent.is_navigation_finished():
		var next_pos := nav_agent.get_next_path_position()
		var direction := (next_pos - global_position).normalized()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed


func _melee_strike() -> void:
	if player and not player.is_dead and not _is_grace_period():
		var dist := global_position.distance_to(player.global_position)
		if dist <= MELEE_RANGE * 1.5:
			player.take_damage(attack_damage)


func _create_windup_indicator() -> void:
	windup_mesh = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.55
	sphere.height = 1.1
	windup_mesh.mesh = sphere

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.4, 0.0, 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.4, 0.0)
	mat.emission_energy_multiplier = 0.0
	mat.cull_mode = BaseMaterial3D.CULL_FRONT
	windup_mesh.set_surface_override_material(0, mat)
	windup_mesh.visible = false
	add_child(windup_mesh)


func _show_windup(show: bool) -> void:
	if windup_mesh:
		windup_mesh.visible = show


func _update_windup_intensity(progress: float) -> void:
	if not windup_mesh:
		return
	var mat: StandardMaterial3D = windup_mesh.get_surface_override_material(0)
	if mat:
		mat.emission_energy_multiplier = lerp(0.0, 5.0, progress)
		mat.albedo_color.a = lerp(0.1, 0.6, progress)

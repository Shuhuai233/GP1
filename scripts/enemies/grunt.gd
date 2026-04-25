## Grunt — Medium speed, ranged attack, walks toward player and shoots
## HP: 30, Speed: 3.5 m/s, Range: 10-15m, Damage: 3/shot via visible projectile (15 m/s)
extends EnemyBase

const PREFERRED_RANGE_MIN: float = 10.0
const PREFERRED_RANGE_MAX: float = 15.0

var _projectile_scene: PackedScene = preload("res://scenes/enemies/enemy_projectile.tscn")


func _ready() -> void:
	max_hp = 30.0
	move_speed = 3.5
	attack_damage = 3.0
	attack_range = 15.0
	attack_cooldown = 1.0
	super._ready()


func _update_behavior(_delta: float) -> void:
	var dist := global_position.distance_to(player.global_position)

	# Face player (horizontal only)
	var look_target := player.global_position
	look_target.y = global_position.y
	look_at(look_target)

	# Maintain preferred range
	if dist > PREFERRED_RANGE_MAX:
		_move_toward_player()
	elif dist < PREFERRED_RANGE_MIN:
		var away_dir := (global_position - player.global_position).normalized()
		velocity.x = away_dir.x * move_speed * 0.5
		velocity.z = away_dir.z * move_speed * 0.5
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	# Shoot
	if dist <= attack_range and attack_timer <= 0:
		_shoot()
		attack_timer = attack_cooldown


func _move_toward_player() -> void:
	nav_agent.target_position = player.global_position
	if not nav_agent.is_navigation_finished():
		var next_pos := nav_agent.get_next_path_position()
		var direction := (next_pos - global_position).normalized()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed


func _shoot() -> void:
	if not player or player.is_dead or _is_grace_period():
		return
	var from := global_position + Vector3.UP * 1.0
	var to := player.global_position + Vector3.UP * 1.0
	var dir := (to - from).normalized()

	var proj: EnemyProjectile = _projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.init(from, dir, 15.0, attack_damage, Color(0.9, 0.1, 0.1, 1))

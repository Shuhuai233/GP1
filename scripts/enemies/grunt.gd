## Grunt — Medium speed, ranged attack, walks toward player and shoots
## HP: 30, Speed: Medium, Range: 10-15m, Damage: 3/shot at ~1/sec
extends EnemyBase

const PREFERRED_RANGE_MIN: float = 10.0
const PREFERRED_RANGE_MAX: float = 15.0

var _bullet_scene: PackedScene  # placeholder for future projectile


func _ready() -> void:
	max_hp = 30.0
	move_speed = 3.5
	attack_damage = 3.0
	attack_range = 15.0
	attack_cooldown = 1.0
	super._ready()


func _update_behavior(delta: float) -> void:
	var dist := global_position.distance_to(player.global_position)

	# Look at player (horizontal only)
	var look_target := player.global_position
	look_target.y = global_position.y
	look_at(look_target)

	# Move toward player if too far, back up if too close
	if dist > PREFERRED_RANGE_MAX:
		_move_toward_player()
	elif dist < PREFERRED_RANGE_MIN:
		# Back away slowly
		var away_dir := (global_position - player.global_position).normalized()
		velocity.x = away_dir.x * move_speed * 0.5
		velocity.z = away_dir.z * move_speed * 0.5
	else:
		# In range — stop and shoot
		velocity.x = 0.0
		velocity.z = 0.0

	# Attack
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
	if player and not player.is_dead:
		# Simple hitscan for now — check line of sight
		var space := get_world_3d().direct_space_state
		var from := global_position + Vector3.UP * 1.0
		var to := player.global_position + Vector3.UP * 1.0
		var query := PhysicsRayQueryParameters3D.create(from, to, 0b0011)  # env + player
		query.exclude = [get_rid()]
		var result := space.intersect_ray(query)
		if result and result.collider == player:
			player.take_damage(attack_damage)

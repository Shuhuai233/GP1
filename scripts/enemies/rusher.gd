## Rusher — Fast, melee, sprints at player
## HP: 20, Speed: Fast, Range: 0-5m, Damage: 15 melee at ~1/sec
extends EnemyBase

const MELEE_RANGE: float = 2.5


func _ready() -> void:
	max_hp = 20.0
	move_speed = 7.0
	attack_damage = 15.0
	attack_range = 5.0
	attack_cooldown = 1.0
	super._ready()


func _update_behavior(delta: float) -> void:
	var dist := global_position.distance_to(player.global_position)

	# Look at player
	var look_target := player.global_position
	look_target.y = global_position.y
	look_at(look_target)

	# Always sprint toward player
	if dist > MELEE_RANGE:
		_move_toward_player()
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	# Melee attack when close
	if dist <= MELEE_RANGE and attack_timer <= 0:
		_melee_attack()
		attack_timer = attack_cooldown


func _move_toward_player() -> void:
	nav_agent.target_position = player.global_position
	if not nav_agent.is_navigation_finished():
		var next_pos := nav_agent.get_next_path_position()
		var direction := (next_pos - global_position).normalized()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed


func _melee_attack() -> void:
	if player and not player.is_dead:
		player.take_damage(attack_damage)

## EnemyBase — Shared enemy logic: health, damage, hit handling, death
## All enemy types extend this.
class_name EnemyBase
extends CharacterBody3D

@export var max_hp: float = 30.0
@export var move_speed: float = 3.0
@export var attack_damage: float = 5.0
@export var attack_range: float = 15.0
@export var attack_cooldown: float = 1.0

@onready var status: StatusEffectComponent = $StatusEffectComponent
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

var current_hp: float
var is_dead: bool = false
var player: Node3D = null
var attack_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	collision_layer = 4  # enemy layer
	collision_mask = 5   # environment + enemy


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Attack cooldown
	if attack_timer > 0:
		attack_timer -= delta

	if player and not player.is_dead:
		_update_behavior(delta)

	move_and_slide()


func _update_behavior(_delta: float) -> void:
	# Override in subclasses
	pass


func take_bullet_hit(card: CardData) -> void:
	if is_dead:
		return

	var damage := card.damage_per_bullet

	# Apply burn damage multiplier
	damage *= status.get_damage_multiplier()

	# Status effects
	match card.status_effect:
		CardData.StatusEffectType.POISON:
			status.apply_poison(card.status_stacks_per_hit)
		CardData.StatusEffectType.BURN:
			status.apply_burn()

	# Detonator: consume poison stacks
	if card.consumes_poison and status.poison_stacks > 0:
		var bonus := status.detonate_poison()
		damage += bonus

	take_damage(damage)

	# Flash white on hit
	_flash_hit()


func take_damage(amount: float) -> void:
	if is_dead:
		return

	current_hp -= amount
	EventBus.enemy_damaged.emit(self, amount)

	if current_hp <= 0:
		die()


func die() -> void:
	is_dead = true
	EventBus.enemy_died.emit(self)
	# Simple death: scale down and remove
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.3)
	tween.tween_callback(queue_free)


func _flash_hit() -> void:
	if mesh and mesh.get_surface_override_material(0):
		var mat: StandardMaterial3D = mesh.get_surface_override_material(0)
		var original_emission := mat.emission
		mat.emission_enabled = true
		mat.emission = Color.WHITE
		var tween := create_tween()
		tween.tween_property(mat, "emission", original_emission, 0.15)
		tween.tween_callback(func(): mat.emission_enabled = false)


func set_player_target(p: Node3D) -> void:
	player = p

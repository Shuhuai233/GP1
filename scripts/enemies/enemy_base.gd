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
@onready var enemy_ui: EnemyUI = $EnemyUI

var current_hp: float
var is_dead: bool = false
var player: Node3D = null
var attack_timer: float = 0.0
var gravity: float = 20.0  # GDD §6: 20 m/s²


func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 5

	# Connect status signals to UI
	if status:
		status.poison_changed.connect(_on_poison_changed)
		status.burn_changed.connect(_on_burn_changed)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	if attack_timer > 0:
		attack_timer -= delta

	if player and not player.is_dead:
		_update_behavior(delta)

	move_and_slide()


func _update_behavior(_delta: float) -> void:
	pass


func take_bullet_hit(card: CardData) -> void:
	if is_dead:
		return

	var damage := card.damage_per_bullet
	damage *= status.get_damage_multiplier()

	match card.status_effect:
		CardData.StatusEffectType.POISON:
			status.apply_poison(card.status_stacks_per_hit)
		CardData.StatusEffectType.BURN:
			status.apply_burn()

	# Legacy: firing-card detonator path (unused now, function cards handle this)
	if card.consumes_poison and status.poison_stacks > 0:
		damage += status.detonate_poison() * card.poison_consume_multiplier

	take_damage(damage)
	_flash_hit()


func take_damage(amount: float) -> void:
	if is_dead:
		return

	current_hp -= amount
	EventBus.enemy_damaged.emit(self, amount)

	if enemy_ui:
		enemy_ui.set_hp(maxf(current_hp, 0.0), max_hp)

	if current_hp <= 0:
		die()


func die() -> void:
	is_dead = true
	EventBus.enemy_died.emit(self)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.3)
	tween.tween_callback(queue_free)


func _flash_hit() -> void:
	if mesh:
		var mat := mesh.get_surface_override_material(0) as StandardMaterial3D
		if mat:
			var orig := mat.emission
			mat.emission_enabled = true
			mat.emission = Color.WHITE
			var tween := create_tween()
			tween.tween_property(mat, "emission", orig, 0.12)
			tween.tween_callback(func(): mat.emission_enabled = false)


func _on_poison_changed(stacks: int) -> void:
	if enemy_ui:
		enemy_ui.set_poison(stacks)


func _on_burn_changed(is_burning: bool) -> void:
	if enemy_ui:
		enemy_ui.set_burn(is_burning)


func set_player_target(p: Node3D) -> void:
	player = p


func _is_grace_period() -> bool:
	## Check if the wave manager's grace period is active
	var wm := get_tree().get_first_node_in_group("wave_manager")
	if wm and wm.has_method("is_grace_period"):
		return wm.is_grace_period()
	return false

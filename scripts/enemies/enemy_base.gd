## EnemyBase — Shared enemy logic for all enemy types.
## Now supports both old take_bullet_hit(CardData) and new take_bullet_hit_new(damage, WeaponInstance, controller)
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
var stun_timer: float = 0.0
var gravity: float = 20.0
var _time_scale: float = 1.0  # Time Warp spell


func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 5
	if status:
		status.poison_changed.connect(_on_poison_changed)
		status.burn_changed.connect(_on_burn_changed)
		status.slow_changed.connect(_on_slow_changed)
		status.freeze_changed.connect(_on_freeze_changed)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	var scaled_delta := delta * _time_scale

	if stun_timer > 0:
		stun_timer -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y -= gravity * scaled_delta

	if attack_timer > 0:
		attack_timer -= delta

	if player and not player.is_dead:
		_update_behavior(scaled_delta)

	move_and_slide()


func _update_behavior(_delta: float) -> void:
	pass


func set_time_scale(scale: float) -> void:
	_time_scale = scale


func get_effective_speed() -> float:
	var spd := move_speed * _time_scale
	if status:
		spd *= status.get_slow_fraction()
	return spd


# ─── OLD system hit (CardData) ────────────────────────────────────────────────

func take_bullet_hit(card: CardData, weapon: Node3D = null) -> void:
	if is_dead:
		return

	var damage := card.damage_per_bullet

	if weapon and weapon.has_method("get_damage_for_bullet"):
		damage = weapon.get_damage_for_bullet(damage, card, self)
	else:
		damage *= status.get_damage_multiplier()

	match card.status_effect:
		CardData.StatusEffectType.POISON:
			status.apply_poison(card.status_stacks_per_hit)
		CardData.StatusEffectType.BURN:
			status.apply_burn()
		CardData.StatusEffectType.SHOCK:
			status.apply_shock()

	take_damage(damage)
	_flash_hit()

	if weapon and weapon.has_method("notify_hit"):
		weapon.notify_hit(self, damage, card)


# ─── NEW system hit (WeaponInstance) ─────────────────────────────────────────

func take_bullet_hit_new(damage: float, weapon_instance: Object, controller: Node3D) -> void:
	if is_dead:
		return

	# Apply status multipliers (Burn, Mark, Brittle)
	damage *= status.get_damage_multiplier()

	take_damage(damage)
	_flash_hit()


# ─── Shared ───────────────────────────────────────────────────────────────────

func take_damage(amount: float) -> void:
	if is_dead:
		return

	current_hp -= amount
	EventBus.enemy_damaged.emit(self, amount)

	if enemy_ui:
		enemy_ui.set_hp(maxf(current_hp, 0.0), max_hp)

	if current_hp <= 0:
		die()


func apply_stun(duration: float) -> void:
	stun_timer = maxf(stun_timer, duration)
	velocity = Vector3.ZERO


func get_hp_percent() -> float:
	return current_hp / max_hp


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
	if enemy_ui: enemy_ui.set_poison(stacks)


func _on_burn_changed(burning: bool) -> void:
	if enemy_ui: enemy_ui.set_burn(burning)


func _on_slow_changed(slowed: bool) -> void:
	if enemy_ui: enemy_ui.set_slow(slowed)


func _on_freeze_changed(frozen: bool) -> void:
	if enemy_ui: enemy_ui.set_freeze(frozen)


func set_player_target(p: Node3D) -> void:
	player = p


func _is_grace_period() -> bool:
	var wm := get_tree().get_first_node_in_group("wave_manager")
	if wm and wm.has_method("is_grace_period"):
		return wm.is_grace_period()
	return false

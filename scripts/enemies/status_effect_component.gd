## StatusEffectComponent — Lives on each enemy, tracks poison stacks and burn timer
## Poison: +2 stacks/hit, no decay, consumed by Detonator at 3x multiplier
## Burn: +20% damage from all sources, 5s duration, refreshes on hit
class_name StatusEffectComponent
extends Node3D

signal poison_changed(stacks: int)
signal burn_changed(is_burning: bool)
signal poison_detonated(stacks: int, bonus_damage: float)

@onready var stack_label: Label3D = $StackLabel
@onready var burn_particles: GPUParticles3D = $BurnParticles
@onready var poison_glow: OmniLight3D = $PoisonGlow

var poison_stacks: int = 0
var burn_timer: float = 0.0
var is_burning: bool = false

const BURN_DURATION: float = 5.0
const BURN_DAMAGE_MULTIPLIER: float = 1.2  # +20% damage


func _ready() -> void:
	stack_label.visible = false
	burn_particles.emitting = false
	poison_glow.visible = false


func _process(delta: float) -> void:
	# Burn countdown
	if is_burning:
		burn_timer -= delta
		if burn_timer <= 0.0:
			is_burning = false
			burn_particles.emitting = false
			burn_changed.emit(false)

	# Billboard the stack label toward camera
	if stack_label.visible:
		var cam := get_viewport().get_camera_3d()
		if cam:
			stack_label.global_transform = stack_label.global_transform.looking_at(
				cam.global_position, Vector3.UP
			)


func apply_poison(stacks: int) -> void:
	poison_stacks += stacks
	_update_poison_visual()
	poison_changed.emit(poison_stacks)
	EventBus.enemy_status_applied.emit(get_parent(), "poison", poison_stacks)


func apply_burn() -> void:
	burn_timer = BURN_DURATION
	if not is_burning:
		is_burning = true
		burn_particles.emitting = true
		burn_changed.emit(true)


func detonate_poison() -> float:
	if poison_stacks <= 0:
		return 0.0

	var stacks := poison_stacks
	var bonus := stacks * 3.0  # 3x multiplier per spec
	poison_stacks = 0
	_update_poison_visual()
	poison_changed.emit(0)
	poison_detonated.emit(stacks, bonus)
	EventBus.enemy_poison_detonated.emit(get_parent(), stacks, bonus)
	return bonus


func get_damage_multiplier() -> float:
	return BURN_DAMAGE_MULTIPLIER if is_burning else 1.0


func _update_poison_visual() -> void:
	if poison_stacks > 0:
		stack_label.visible = true
		stack_label.text = str(poison_stacks)
		poison_glow.visible = true
		# Scale glow intensity with stacks (capped at 20 for visual sanity)
		poison_glow.light_energy = clampf(float(poison_stacks) / 10.0, 0.2, 2.0)
	else:
		stack_label.visible = false
		poison_glow.visible = false

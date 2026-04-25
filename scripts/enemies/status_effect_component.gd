## StatusEffectComponent — Lives on each enemy, tracks poison stacks and burn timer
## Poison: +2 stacks/hit, no decay, consumed by Detonator at 3x multiplier
## Burn: +20% damage from all sources, 5s duration, refreshes on hit
class_name StatusEffectComponent
extends Node3D

signal poison_changed(stacks: int)
signal burn_changed(is_burning: bool)
signal poison_detonated(stacks: int, bonus_damage: float)

@onready var burn_particles: GPUParticles3D = $BurnParticles
@onready var poison_glow: OmniLight3D = $PoisonGlow

var poison_stacks: int = 0
var burn_timer: float = 0.0
var is_burning: bool = false

const BURN_DURATION: float = 5.0
const BURN_DAMAGE_MULTIPLIER: float = 1.2  # +20% damage


func _ready() -> void:
	burn_particles.emitting = false
	poison_glow.visible = false


func _process(delta: float) -> void:
	if is_burning:
		burn_timer -= delta
		if burn_timer <= 0.0:
			is_burning = false
			burn_particles.emitting = false
			burn_changed.emit(false)


func apply_poison(stacks: int) -> void:
	poison_stacks += stacks
	_update_poison_glow()
	poison_changed.emit(poison_stacks)
	EventBus.enemy_status_applied.emit(get_parent(), "poison", poison_stacks)


func apply_burn() -> void:
	burn_timer = BURN_DURATION
	if not is_burning:
		is_burning = true
		burn_particles.emitting = true
	# Always emit signal so UI/audio can react to refresh
	burn_changed.emit(true)


func detonate_poison() -> int:
	## Returns raw stack count consumed. Caller handles damage + EventBus.
	if poison_stacks <= 0:
		return 0

	var stacks := poison_stacks
	poison_stacks = 0
	_update_poison_glow()
	poison_changed.emit(0)
	poison_detonated.emit(stacks, 0.0)
	return stacks


func get_damage_multiplier() -> float:
	return BURN_DAMAGE_MULTIPLIER if is_burning else 1.0


func _update_poison_glow() -> void:
	if poison_stacks > 0:
		poison_glow.visible = true
		poison_glow.light_energy = clampf(float(poison_stacks) * 0.3, 0.5, 4.0)
		poison_glow.omni_range = clampf(float(poison_stacks) * 0.4, 3.0, 7.0)
	else:
		poison_glow.visible = false

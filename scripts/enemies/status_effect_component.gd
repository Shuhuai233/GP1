## StatusEffectComponent — Lives on each enemy, tracks poison stacks, burn, shock, and mark
## Poison: stacks, no decay, consumed by Detonator at 3x (6x with Toxic Fire)
## Burn: +20% damage from all sources, 5s duration, refreshes on hit
## Shock: +15% chain damage bonus, 3s duration, enables Chain Lightning
## Mark: +30% damage from ALL sources, 6s, no refresh
class_name StatusEffectComponent
extends Node3D

signal poison_changed(stacks: int)
signal burn_changed(is_burning: bool)
signal shock_changed(is_shocked: bool)
signal mark_changed(is_marked: bool)
signal poison_detonated(stacks: int, bonus_damage: float)

@onready var burn_particles: GPUParticles3D = $BurnParticles
@onready var poison_glow: OmniLight3D = $PoisonGlow

var poison_stacks: int = 0
var burn_timer: float = 0.0
var is_burning: bool = false
var shock_timer: float = 0.0
var is_shocked: bool = false
var mark_timer: float = 0.0
var is_marked: bool = false

const BURN_DURATION: float = 5.0
const BURN_DAMAGE_MULTIPLIER: float = 1.2   # +20%
const SHOCK_DURATION: float = 3.0
const SHOCK_CHAIN_BONUS: float = 0.15       # +15% chain damage
const MARK_DURATION: float = 6.0
const MARK_DAMAGE_BONUS: float = 0.30       # +30%


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

	if is_shocked:
		shock_timer -= delta
		if shock_timer <= 0.0:
			is_shocked = false
			shock_changed.emit(false)

	if is_marked:
		mark_timer -= delta
		if mark_timer <= 0.0:
			is_marked = false
			mark_changed.emit(false)


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
	burn_changed.emit(true)


func apply_shock() -> void:
	shock_timer = SHOCK_DURATION
	if not is_shocked:
		is_shocked = true
		shock_changed.emit(true)
	EventBus.enemy_status_applied.emit(get_parent(), "shock", 1)


func apply_mark(duration: float = MARK_DURATION) -> void:
	if not is_marked:
		is_marked = true
		mark_timer = duration
		mark_changed.emit(true)
	EventBus.enemy_status_applied.emit(get_parent(), "mark", 1)


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
	## Returns combined damage multiplier from all active statuses
	var mult := 1.0
	if is_burning:
		mult *= BURN_DAMAGE_MULTIPLIER
	if is_marked:
		mult *= (1.0 + MARK_DAMAGE_BONUS)
	return mult


func get_chain_multiplier() -> float:
	return 1.0 + SHOCK_CHAIN_BONUS if is_shocked else 1.0


func _update_poison_glow() -> void:
	if poison_stacks > 0:
		poison_glow.visible = true
		poison_glow.light_energy = clampf(float(poison_stacks) * 0.3, 0.5, 4.0)
		poison_glow.omni_range = clampf(float(poison_stacks) * 0.4, 3.0, 7.0)
	else:
		poison_glow.visible = false

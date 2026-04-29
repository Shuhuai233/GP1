## StatusEffectComponent — All 6 status effects + 5 combo tracking
## Poison: stacks, no decay, consumed by Detonator at 3x (6x Toxic Fire)
## Burn: +20% dmg from all sources, 5s, refreshes
## Shock: chains 40% dmg to nearby enemy, 3s
## Slow: -50% move speed, 4s, refreshes
## Mark: +30% dmg, 6s, no refresh
## Freeze: stun 3s (from Shatter or Permafrost), 2x dmg while frozen (Brittle)
class_name StatusEffectComponent
extends Node3D

signal poison_changed(stacks: int)
signal burn_changed(is_burning: bool)
signal shock_changed(is_shocked: bool)
signal slow_changed(is_slowed: bool)
signal mark_changed(is_marked: bool)
signal freeze_changed(is_frozen: bool)
signal poison_detonated(stacks: int, bonus_damage: float)
signal combo_activated(combo_name: String)

@onready var burn_particles: GPUParticles3D = $BurnParticles
@onready var poison_glow: OmniLight3D = $PoisonGlow

var poison_stacks: int = 0

var burn_timer: float = 0.0
var is_burning: bool = false

var shock_timer: float = 0.0
var is_shocked: bool = false

var slow_timer: float = 0.0
var is_slowed: bool = false
var _frost_hit_count: int = 0  # Permafrost: auto-freeze after 5 frost hits while slowed

var mark_timer: float = 0.0
var is_marked: bool = false

var freeze_timer: float = 0.0
var is_frozen: bool = false

const BURN_DURATION: float = 5.0
const SHOCK_DURATION: float = 3.0
const SLOW_DURATION: float = 4.0
const MARK_DURATION: float = 6.0
const PERMAFROST_HITS: int = 5

# Multipliers
const BURN_DMG_MULT: float = 1.2     # +20%
const MARK_DMG_BONUS: float = 0.30   # +30%  (becomes +50% with Marked for Death combo)
const BRITTLE_DMG_MULT: float = 2.0  # 2x while frozen
const MARKED_FOR_DEATH_BONUS: float = 0.50  # +50% when Mark + Burn active


func _ready() -> void:
	if burn_particles:
		burn_particles.emitting = false
	if poison_glow:
		poison_glow.visible = false


func _process(delta: float) -> void:
	if is_burning:
		burn_timer -= delta
		if burn_timer <= 0.0:
			is_burning = false
			if burn_particles:
				burn_particles.emitting = false
			burn_changed.emit(false)

	if is_shocked:
		shock_timer -= delta
		if shock_timer <= 0.0:
			is_shocked = false
			shock_changed.emit(false)

	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0.0:
			is_slowed = false
			_frost_hit_count = 0
			slow_changed.emit(false)

	if is_marked:
		mark_timer -= delta
		if mark_timer <= 0.0:
			is_marked = false
			mark_changed.emit(false)

	if is_frozen:
		freeze_timer -= delta
		if freeze_timer <= 0.0:
			is_frozen = false
			freeze_changed.emit(false)


# ─── Apply ────────────────────────────────────────────────────────────────────

func apply_poison(stacks: int) -> void:
	poison_stacks += stacks
	_update_poison_glow()
	poison_changed.emit(poison_stacks)
	EventBus.enemy_status_applied.emit(get_parent(), "poison", poison_stacks)
	# Contagion combo check handled by weapon_controller at detonation time


func apply_burn() -> void:
	burn_timer = BURN_DURATION
	if not is_burning:
		is_burning = true
		if burn_particles:
			burn_particles.emitting = true
	burn_changed.emit(true)
	# Marked for Death: Mark + Burn → +50%
	if is_marked:
		combo_activated.emit("MARKED FOR DEATH")
		EventBus.combo_triggered.emit("MARKED FOR DEATH", get_parent().global_position)


func apply_shock() -> void:
	shock_timer = SHOCK_DURATION
	if not is_shocked:
		is_shocked = true
		shock_changed.emit(true)
	EventBus.enemy_status_applied.emit(get_parent(), "shock", 1)


func apply_slow() -> void:
	var was_slowed := is_slowed
	slow_timer = SLOW_DURATION
	if not is_slowed:
		is_slowed = true
		slow_changed.emit(true)
	# Permafrost: 5 frost hits on slowed target = auto-freeze
	if was_slowed:
		_frost_hit_count += 1
		if _frost_hit_count >= PERMAFROST_HITS:
			_frost_hit_count = 0
			apply_freeze(2.0)  # auto-freeze 2s
			combo_activated.emit("PERMAFROST")
			EventBus.combo_triggered.emit("PERMAFROST", get_parent().global_position)
	EventBus.enemy_status_applied.emit(get_parent(), "slow", 1)


func apply_mark(duration: float = MARK_DURATION) -> void:
	if not is_marked:
		is_marked = true
		mark_timer = duration
		mark_changed.emit(true)
	EventBus.enemy_status_applied.emit(get_parent(), "mark", 1)
	# Marked for Death: Mark + Burn → +50%
	if is_burning:
		combo_activated.emit("MARKED FOR DEATH")
		EventBus.combo_triggered.emit("MARKED FOR DEATH", get_parent().global_position)


func apply_freeze(duration: float = 3.0) -> void:
	is_frozen = true
	freeze_timer = duration
	freeze_changed.emit(true)
	var parent := get_parent()
	if parent and parent.has_method("apply_stun"):
		parent.apply_stun(duration)
	# Brittle combo announcement happens on the NEXT hit while frozen, not here.
	# See get_damage_multiplier() — 2x applied per damage call.
	# We do emit a "now_brittle" signal so the enemy UI can show BRITTLE label.
	combo_activated.emit("NOW_BRITTLE")


func detonate_poison() -> int:
	if poison_stacks <= 0:
		return 0
	var stacks := poison_stacks
	poison_stacks = 0
	_update_poison_glow()
	poison_changed.emit(0)
	poison_detonated.emit(stacks, 0.0)
	return stacks


func clear_all() -> void:
	## Purge spell: consume all statuses
	poison_stacks = 0
	_update_poison_glow()
	poison_changed.emit(0)
	if is_burning:
		is_burning = false
		if burn_particles:
			burn_particles.emitting = false
		burn_changed.emit(false)
	if is_shocked:
		is_shocked = false
		shock_changed.emit(false)
	if is_slowed:
		is_slowed = false
		slow_changed.emit(false)
	if is_marked:
		is_marked = false
		mark_changed.emit(false)
	if is_frozen:
		is_frozen = false
		freeze_changed.emit(false)
	_frost_hit_count = 0


func count_active_types() -> int:
	var count := 0
	if poison_stacks > 0: count += 1
	if is_burning: count += 1
	if is_shocked: count += 1
	if is_slowed: count += 1
	if is_marked: count += 1
	if is_frozen: count += 1
	return count


# ─── Damage multiplier ────────────────────────────────────────────────────────

func get_damage_multiplier() -> float:
	var mult := 1.0
	if is_burning:
		mult *= BURN_DMG_MULT
	# Mark: +30% base, +50% if also burning (Marked for Death combo)
	if is_marked:
		if is_burning:
			mult *= (1.0 + MARKED_FOR_DEATH_BONUS)
		else:
			mult *= (1.0 + MARK_DMG_BONUS)
	# Brittle: frozen enemies take 2x
	if is_frozen:
		mult *= BRITTLE_DMG_MULT
	return mult


func get_chain_multiplier() -> float:
	return 1.15 if is_shocked else 1.0


func get_slow_fraction() -> float:
	return 0.5 if is_slowed else 1.0


func _update_poison_glow() -> void:
	if not poison_glow:
		return
	if poison_stacks > 0:
		poison_glow.visible = true
		poison_glow.light_energy = clampf(float(poison_stacks) * 0.3, 0.5, 4.0)
		poison_glow.omni_range = clampf(float(poison_stacks) * 0.4, 3.0, 7.0)
	else:
		poison_glow.visible = false

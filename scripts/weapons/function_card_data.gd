## FunctionCardData — A spell in the player's spell hand (5 slots).
## Found between waves. Cast with F key. Consumed on use. Spell hand refills on reload.
## WEAPONS_AND_CARDS.md Part 3 — 20 cards total.
class_name FunctionCardData
extends Resource

enum Category { MAGAZINE_SPELL, CHARACTER_SPELL, EXECUTE_SPELL, TACTICAL_SPELL }

@export var card_name: StringName = &"Poison Magazine"
@export var category: Category = Category.MAGAZINE_SPELL
@export_multiline var description: String = ""
@export var color: Color = Color(0.2, 0.9, 0.2, 1)

# ─── Category A: Magazine Spells ────────────────────────────────────────────
## These apply to remaining bullets in the CURRENT magazine. Reload clears effect.

@export_group("Magazine Spell")
@export var is_magazine_spell: bool = false
@export var mag_poison_stacks_per_hit: int = 0   # Poison Magazine
@export var mag_apply_burn: bool = false           # Fire Magazine
@export var mag_apply_shock: bool = false          # Shock Magazine (chains 40% dmg)
@export var mag_apply_slow: bool = false           # Frost Magazine
@export var mag_explosive: bool = false            # Explosive Magazine
@export var mag_explosive_radius: float = 2.0
@export var mag_explosive_damage_fraction: float = 0.3

# ─── Category B: Character Spells ───────────────────────────────────────────

@export_group("Character Spell")
## Dash
@export var is_dash: bool = false
@export var dash_distance: float = 5.0
@export var dash_iframes: float = 0.2

## Blink
@export var is_blink: bool = false
@export var blink_range: float = 15.0

## Shield Wall
@export var is_shield_wall: bool = false
@export var shield_wall_duration: float = 4.0

## Iron Skin
@export var is_iron_skin: bool = false
@export var iron_skin_hits: int = 3
@export var iron_skin_duration: float = 8.0

## Adrenaline
@export var is_adrenaline: bool = false
@export var adrenaline_duration: float = 6.0
@export var adrenaline_move_bonus: float = 0.5    # +50%
@export var adrenaline_fire_rate_bonus: float = 0.3  # +30%

## Vampiric Aura
@export var is_vampiric_aura: bool = false
@export var vampiric_duration: float = 5.0
@export var vampiric_ratio: float = 0.4            # 40% of damage dealt

## War Cry
@export var is_war_cry: bool = false
@export var war_cry_duration: float = 8.0
@export var war_cry_damage_bonus: float = 0.5      # +50%

## Time Warp
@export var is_time_warp: bool = false
@export var time_warp_duration: float = 4.0
@export var time_warp_speed_fraction: float = 0.3  # enemies at 30% speed

# ─── Category C: Execute Spells ─────────────────────────────────────────────

@export_group("Execute Spell")
## Detonator
@export var is_detonator: bool = false
@export var detonator_base_multiplier: float = 3.0  # 3x stacks, 6x if also burning

## Chain Detonation
@export var is_chain_detonation: bool = false
@export var chain_det_spread_radius: float = 6.0
@export var chain_det_spread_fraction: float = 0.5  # normal, 1.0 if Contagion combo

## Purge
@export var is_purge: bool = false
@export var purge_damage_per_type: float = 15.0
@export var purge_damage_per_stack: float = 2.0

## Shatter
@export var is_shatter: bool = false
@export var shatter_damage: float = 50.0
@export var shatter_freeze_duration: float = 3.0

# ─── Category D: Tactical Spells ────────────────────────────────────────────

@export_group("Tactical Spell")
## Spotter
@export var is_spotter: bool = false
@export var mark_duration: float = 6.0

## Reload Surge
@export var is_reload_surge: bool = false
# (Instant reload that PRESERVES magazine spell — see weapon.gd)

## Magnetize
@export var is_magnetize: bool = false
@export var magnetize_radius: float = 15.0
@export var magnetize_duration: float = 5.0
@export var magnetize_pull_per_sec: float = 3.0

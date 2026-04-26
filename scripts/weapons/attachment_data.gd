## AttachmentData — Permanent weapon modification found between waves.
## Applied to one of the player's 2 weapons. Unlimited slots per weapon.
## Design rule: every effect must be VISIBLE and IMMEDIATELY noticeable.
class_name AttachmentData
extends Resource

enum AttachmentCategory { BARREL, MAGAZINE, OPTICS, GRIP, SPECIAL }

@export var attachment_name: StringName = &"Split Barrel"
@export var category: AttachmentCategory = AttachmentCategory.BARREL
@export_multiline var description: String = ""
@export var color: Color = Color.WHITE

@export_group("Barrel Effects")
## Split Barrel: bullets split into 3 after 5m, each at this fraction of damage
@export var split_bullet: bool = false
@export var split_count: int = 3
@export var split_damage_fraction: float = 0.5
@export var split_travel_distance: float = 5.0

## Explosive Tips: AoE on hit
@export var explosive_tips: bool = false
@export var explosive_radius: float = 2.0
@export var explosive_damage_fraction: float = 0.4

## Ricochet Chamber: bounce off walls
@export var ricochet: bool = false
@export var ricochet_range: float = 10.0

## Piercing Barrel: pass through enemies
@export var piercing: bool = false

## Chain Link: damage chains to nearby enemy
@export var chain_link: bool = false
@export var chain_range: float = 6.0
@export var chain_damage_fraction: float = 0.4

@export_group("Magazine Effects")
## Drum Magazine: double mag size, +50% reload time
@export var drum_magazine: bool = false

## Speed Loader: halve reload time
@export var speed_loader: bool = false

## Double Feed: fire 2 bullets per shot, drain at 2x speed
@export var double_feed: bool = false

@export_group("Optics Effects")
## Holo Sight: instant ADS transition
@export var holo_sight: bool = false

## Thermal Scope: see enemies through walls in ADS
@export var thermal_scope: bool = false
@export var thermal_range: float = 30.0

@export_group("Grip Effects")
## Steady Grip: zero camera recoil
@export var steady_grip: bool = false

## Quick Grip: instant weapon switch + 0.3s i-frames on switch
@export var quick_grip: bool = false
@export var quick_grip_iframes: float = 0.3

@export_group("Special Effects")
## Vampiric Barrel: heal 1 HP per bullet hit
@export var vampiric_barrel: bool = false
@export var vampiric_hp_per_hit: float = 1.0

## Elemental Converter: magazine spells apply to BOTH weapons
@export var elemental_converter: bool = false

## Chaos Engine: 20% chance each bullet fires as random magazine spell type
@export var chaos_engine: bool = false
@export var chaos_chance: float = 0.2

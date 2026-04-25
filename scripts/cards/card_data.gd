## CardData — Resource definition for a single card
## card_type determines which hand it loads into on reload:
##   FIRING → gun (right hand, 6-pack magazine)
##   FUNCTION → spell hand (left hand, up to 3 slots)
class_name CardData
extends Resource

enum CardType { FIRING, FUNCTION }
enum StatusEffectType { NONE, POISON, BURN }

# --- Identity ---
@export var card_name: StringName = &"Standard Round"
@export var card_type: CardType = CardType.FIRING

# --- Firing card stats (only relevant when card_type == FIRING) ---
@export_group("Firing")
@export var bullets_per_pack: int = 6
@export var damage_per_bullet: float = 8.0
@export var status_effect: StatusEffectType = StatusEffectType.NONE
@export var status_stacks_per_hit: int = 0
@export var piercing: bool = false

# --- Function card stats (only relevant when card_type == FUNCTION) ---
@export_group("Function")
@export var consumes_poison: bool = false
@export var poison_consume_multiplier: float = 0.0  # base: 3x; Toxic Fire: 6x
@export var grants_shield: bool = false
@export var shield_amount: float = 0.0
@export var shield_duration: float = 0.0
@export var area_burn: bool = false
@export var area_burn_radius: float = 0.0

# --- Visual ---
@export_group("Visual")
@export var color: Color = Color.WHITE
@export var trail_color: Color = Color.WHITE
@export var muzzle_color: Color = Color.WHITE

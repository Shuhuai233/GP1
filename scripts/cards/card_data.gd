## CardData — Resource definition for a single card
## card_type determines which hand it loads into on reload:
##   FIRING → gun (right hand, 6-pack magazine)
##   FUNCTION → spell hand (left hand, up to 3 slots)
class_name CardData
extends Resource

enum CardType { FIRING, FUNCTION }
enum StatusEffectType { NONE, POISON, BURN, SLOW, SHOCK, MARK }
enum Playstyle { NEUTRAL, POWER, VENOM, BLAZE, FLUX, SHOCK_STYLE }

# --- Identity ---
@export var card_name: StringName = &"Standard Round"
@export var card_type: CardType = CardType.FIRING
@export var playstyle: Playstyle = Playstyle.NEUTRAL
@export_multiline var description: String = ""

# --- Firing card stats (only relevant when card_type == FIRING) ---
@export_group("Firing")
@export var bullets_per_pack: int = 6
@export var damage_per_bullet: float = 8.0
@export var status_effect: StatusEffectType = StatusEffectType.NONE
@export var status_stacks_per_hit: int = 0
@export var piercing: bool = false
## Explosive: bullet creates AoE on impact
@export var explosive: bool = false
@export var explosive_radius: float = 0.0
## Headshot multiplier override (default gun headshot is 1.5x)
@export var headshot_multiplier: float = 1.5
## Ignores damage resistance
@export var armor_piercing: bool = false
## Chain: hit chains to nearby enemies
@export var chain_count: int = 0
@export var chain_range: float = 0.0
@export var chain_damage_multiplier: float = 0.0
## Ricochet: bounces off walls
@export var ricochet: bool = false
@export var ricochet_count: int = 0
## Drain: heals player per hit
@export var drain_hp_per_hit: float = 0.0
## Move speed modifier while firing this pack
@export var move_speed_bonus: float = 0.0
## Combo: consecutive hits within window add bonus damage
@export var combo_bonus_per_hit: float = 0.0
@export var combo_window: float = 0.0
## Tracer: each hit increases NEXT card pack's damage
@export var tracer_bonus_per_hit: float = 0.0
## Ground fire: leaves fire patch on impact
@export var ground_fire: bool = false
@export var ground_fire_radius: float = 0.0
@export var ground_fire_duration: float = 0.0
@export var ground_fire_dps: float = 0.0
## Scatter: fires multiple pellets per shot
@export var scatter_count: int = 1
## Plague: on kill, spread stacks to nearest enemy
@export var spread_stacks_on_kill: bool = false
@export var spread_stacks_range: float = 0.0

# --- Function card stats (only relevant when card_type == FUNCTION) ---
@export_group("Function")
## Detonator: consume poison stacks
@export var consumes_poison: bool = false
@export var poison_consume_multiplier: float = 0.0
## Shield
@export var grants_shield: bool = false
@export var shield_amount: float = 0.0
@export var shield_duration: float = 0.0
## Area burn
@export var area_burn: bool = false
@export var area_burn_radius: float = 0.0
## Area poison
@export var area_poison: bool = false
@export var area_poison_radius: float = 0.0
@export var area_poison_stacks: int = 0
## Pandemic: spread highest poison stacks to area
@export var pandemic: bool = false
@export var pandemic_radius: float = 0.0
@export var pandemic_ratio: float = 0.0
## Damage buff for next magazine
@export var damage_buff: bool = false
@export var damage_buff_multiplier: float = 0.0
## Shield + damage combo (Iron Skin)
@export var shield_damage_bonus: float = 0.0
## Megashot: next single bullet deals multiplied damage
@export var megashot: bool = false
@export var megashot_multiplier: float = 0.0
## Executioner: instant kill below HP threshold
@export var executioner: bool = false
@export var executioner_threshold: float = 0.0
## Inferno: burst damage to all burning enemies
@export var inferno: bool = false
@export var inferno_damage: float = 0.0
## Fuel: next N packs also apply burn
@export var fuel: bool = false
@export var fuel_pack_count: int = 0
## Dash
@export var dash: bool = false
@export var dash_distance: float = 0.0
## Teleport (Blink)
@export var blink: bool = false
@export var blink_range: float = 0.0
## Fire rate buff
@export var fire_rate_buff: bool = false
@export var fire_rate_multiplier: float = 0.0
@export var fire_rate_duration: float = 0.0
## Speed buff (Adrenaline)
@export var speed_buff: bool = false
@export var speed_buff_move: float = 0.0
@export var speed_buff_fire_rate: float = 0.0
@export var speed_buff_reload: float = 0.0
@export var speed_buff_duration: float = 0.0
## Chain Lightning
@export var chain_lightning: bool = false
@export var chain_lightning_bounces: int = 0
@export var chain_lightning_damage: float = 0.0
## Spotter: apply Mark
@export var apply_mark: bool = false
@export var mark_damage_bonus: float = 0.0
@export var mark_duration: float = 0.0
## EMP: area shock + stun
@export var emp: bool = false
@export var emp_radius: float = 0.0
@export var emp_stun_duration: float = 0.0
## Vampiric Burst: lifesteal for duration
@export var vampiric_burst: bool = false
@export var vampiric_ratio: float = 0.0
@export var vampiric_duration: float = 0.0
## Instant reload
@export var instant_reload: bool = false
## War Cry: damage buff for next magazine
@export var war_cry: bool = false
@export var war_cry_multiplier: float = 0.0

# --- Visual ---
@export_group("Visual")
@export var color: Color = Color.WHITE
@export var trail_color: Color = Color.WHITE
@export var muzzle_color: Color = Color.WHITE

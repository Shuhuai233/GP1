## CardData — Resource definition for a single card type
class_name CardData
extends Resource

enum StatusEffectType { NONE, POISON, BURN }

@export var card_name: StringName = &"Standard Round"
@export var bullets_per_pack: int = 6
@export var damage_per_bullet: float = 8.0
@export var color: Color = Color.WHITE
@export var status_effect: StatusEffectType = StatusEffectType.NONE
@export var status_stacks_per_hit: int = 0
@export var piercing: bool = false
@export var consumes_poison: bool = false
@export var poison_consume_multiplier: float = 0.0

@export_group("Visual")
@export var trail_color: Color = Color.WHITE
@export var muzzle_color: Color = Color.WHITE

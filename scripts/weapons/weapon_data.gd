## WeaponData — Static resource defining a weapon type's base stats.
## Weapons found as loot between waves. Player carries 2 weapons.
class_name WeaponData
extends Resource

enum WeaponType { REVOLVER, AR, SMG, SHOTGUN, SNIPER, MACHINE_PISTOL }

# --- Identity ---
@export var weapon_name: StringName = &"Revolver"
@export var weapon_type: WeaponType = WeaponType.REVOLVER
@export_multiline var description: String = ""

# --- Stats ---
@export_group("Stats")
@export var fire_rate: float = 3.0         # shots per second
@export var magazine_size: int = 18        # rounds in magazine
@export var damage_per_bullet: float = 12.0
@export var reload_time: float = 2.0       # seconds
@export var pellets_per_shot: int = 1      # Shotgun = 6
@export var ads_fov: float = 75.0          # Sniper = 36
@export var headshot_multiplier: float = 2.0  # Sniper = 3.0

# --- ADS spread ---
@export var hip_spread: float = 0.0        # degrees when stationary
@export var move_spread: float = 1.0       # degrees when moving
@export var ads_spread: float = 0.0        # degrees when ADS (Sniper has huge hip spread)
@export var sniper_hip_spread: float = 0.0 # special: massive hip spread for sniper

# --- Intrinsic ability ---
@export_group("Intrinsic")
## Machine Pistol: +15% move speed while firing this weapon
@export var move_speed_bonus_while_firing: float = 0.0

# --- Visual ---
@export_group("Visual")
@export var color: Color = Color.WHITE
## Path to the weapon's scene (CSG model)
@export var model_scene_path: String = ""

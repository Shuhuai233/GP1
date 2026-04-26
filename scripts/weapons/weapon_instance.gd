## WeaponInstance — Runtime state for a carried weapon.
## Wraps WeaponData with current magazine count, attached mods, and active magazine spell.
## Pure data — no Node dependencies. Lives inside the weapon controller.
class_name WeaponInstance
extends RefCounted

var data: WeaponData
var attachments: Array[AttachmentData] = []

# Magazine state
var bullets_remaining: int = 0
var effective_magazine_size: int = 0  # base + drum magazine

# Active magazine spell (cleared on reload)
var active_mag_spell: FunctionCardData = null

# Tracer/combo counters (transient)
var chaos_engine_active: bool = false


func _init(weapon_data: WeaponData) -> void:
	data = weapon_data
	_recalculate_magazine()
	bullets_remaining = effective_magazine_size


func _recalculate_magazine() -> void:
	effective_magazine_size = data.magazine_size
	for att in attachments:
		if att.drum_magazine:
			effective_magazine_size = data.magazine_size * 2
			break


func get_reload_time() -> float:
	var t := data.reload_time
	for att in attachments:
		if att.speed_loader:
			t *= 0.5
		if att.drum_magazine:
			t *= 1.5
	return t


func get_fire_rate() -> float:
	return data.fire_rate


func is_empty() -> bool:
	return bullets_remaining <= 0


func consume_bullet(count: int = 1) -> void:
	bullets_remaining = maxi(bullets_remaining - count, 0)


func reload() -> void:
	_recalculate_magazine()
	bullets_remaining = effective_magazine_size
	active_mag_spell = null  # reload clears magazine spell


func reload_surge() -> void:
	## Reload Surge: instant reload but PRESERVES active magazine spell
	_recalculate_magazine()
	bullets_remaining = effective_magazine_size
	# active_mag_spell intentionally NOT cleared


func add_attachment(att: AttachmentData) -> void:
	attachments.append(att)
	_recalculate_magazine()


func has_attachment(check: StringName) -> bool:
	for att in attachments:
		if att.attachment_name == check:
			return true
	return false


func get_effective_damage() -> float:
	return data.damage_per_bullet


func get_pellets() -> int:
	var p := data.pellets_per_shot
	for att in attachments:
		if att.double_feed:
			p *= 2
	return p


func get_split_count() -> int:
	for att in attachments:
		if att.split_bullet:
			return att.split_count
	return 1

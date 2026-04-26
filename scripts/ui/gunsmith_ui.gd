## GunsmithUI — Shows weapon loadout with attached mods listed
## Currently embedded in LootOfferingUI for attachment targeting
## Standalone display available via Tab (deck inspector shows this too)
## This is a lightweight display, not a standalone screen
extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var weapon1_label: Label = $Panel/VBox/Weapon1Label
@onready var weapon2_label: Label = $Panel/VBox/Weapon2Label


func _ready() -> void:
	EventBus.weapon_state_changed.connect(_on_weapon_state_changed)
	panel.visible = false


func _on_weapon_state_changed(weapons: Array, active_slot: int) -> void:
	# Update weapon name displays in HUD (compact mode)
	_refresh_display(weapons, active_slot)


func _refresh_display(weapons: Array, active_slot: int) -> void:
	for slot in 2:
		var label: Label = weapon1_label if slot == 0 else weapon2_label
		if not label:
			continue
		if slot >= weapons.size() or weapons[slot] == null:
			label.text = "Slot %d: (empty)" % (slot + 1)
			label.modulate = Color(0.5, 0.5, 0.5, 1)
			continue
		var w = weapons[slot]
		var att_names: PackedStringArray = []
		for att in w.attachments:
			att_names.append(str(att.attachment_name))
		var att_str := " + ".join(att_names) if att_names.size() > 0 else "(no mods)"
		label.text = "Slot %d: %s [%d/%d] %s" % [
			slot + 1,
			str(w.data.weapon_name),
			w.bullets_remaining,
			w.effective_magazine_size,
			att_str
		]
		label.modulate = Color.WHITE if slot == active_slot else Color(0.7, 0.7, 0.7, 1)

## DeckInspector — Tab pauses game, shows weapons + attachments + spell hand
## Full detail on each item. Tab or Esc closes.
extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var weapons_section: VBoxContainer = $Panel/HBox/WeaponsSection
@onready var spells_section: VBoxContainer = $Panel/HBox/SpellsSection
@onready var close_hint: Label = $Panel/CloseHint

var _weapon_controller: Node3D = null
var _is_open: bool = false


func _ready() -> void:
	panel.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.weapon_state_changed.connect(_on_weapon_state_changed)
	EventBus.spell_hand_state_changed.connect(_on_spell_hand_state_changed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inspect_loadout"):
		if _is_open:
			_close()
		else:
			_open()
	elif event.is_action_pressed("ui_cancel") and _is_open:
		_close()


func _open() -> void:
	_weapon_controller = get_node_or_null("/root/Main/Player/Head/WeaponHolder")
	_refresh()
	panel.visible = true
	_is_open = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.process_mode = Node.PROCESS_MODE_ALWAYS


func _close() -> void:
	panel.visible = false
	_is_open = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT


func _on_weapon_state_changed(_weapons: Array, _active: int) -> void:
	if _is_open:
		_refresh()


func _on_spell_hand_state_changed(_hand: Array, _consumed: Array, _active: int) -> void:
	if _is_open:
		_refresh()


func _refresh() -> void:
	if not _weapon_controller:
		_weapon_controller = get_node_or_null("/root/Main/Player/Head/WeaponHolder")
	if not _weapon_controller:
		return

	# Clear sections
	for child in weapons_section.get_children():
		if child != weapons_section.get_child(0):
			child.queue_free()
	for child in spells_section.get_children():
		if child != spells_section.get_child(0):
			child.queue_free()

	# Weapons
	var weapons: Array = _weapon_controller.weapons
	var active_slot: int = _weapon_controller.active_slot
	for slot in 2:
		var lbl := Label.new()
		if slot >= weapons.size() or weapons[slot] == null:
			lbl.text = "Slot %d: EMPTY" % (slot + 1)
			lbl.modulate = Color(0.5, 0.5, 0.5, 1)
		else:
			var w = weapons[slot]
			var lines: PackedStringArray = []
			lines.append("SLOT %d: %s%s" % [slot + 1, str(w.data.weapon_name), " ◄ ACTIVE" if slot == active_slot else ""])
			lines.append("  %d/%d rounds  |  %.0f dmg  |  %.1f/sec" % [w.bullets_remaining, w.effective_magazine_size, w.data.damage_per_bullet, w.data.fire_rate])
			if w.active_mag_spell:
				lines.append("  ✨ MAG SPELL: %s" % str(w.active_mag_spell.card_name))
			if w.attachments.size() > 0:
				lines.append("  MODS:")
				for att in w.attachments:
					lines.append("    🔧 %s" % str(att.attachment_name))
			lbl.text = "\n".join(lines)
			lbl.modulate = Color.WHITE if slot == active_slot else Color(0.75, 0.75, 0.75, 1)
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		weapons_section.add_child(lbl)

	# Spell hand
	var spell_hand: Array = _weapon_controller.spell_hand
	var consumed: Array[bool] = _weapon_controller.spell_consumed
	var active_idx: int = _weapon_controller.active_spell_index
	for i in spell_hand.size():
		var lbl := Label.new()
		if spell_hand[i] == null:
			lbl.text = "Slot %d: empty" % (i + 1)
			lbl.modulate = Color(0.3, 0.3, 0.3, 1)
		else:
			var card: FunctionCardData = spell_hand[i]
			var is_consumed: bool = consumed[i] if i < consumed.size() else false
			var prefix := "◄ " if i == active_idx and not is_consumed else ""
			var state := " [CONSUMED]" if is_consumed else ""
			lbl.text = "%sSlot %d: %s%s\n  %s" % [prefix, i + 1, str(card.card_name), state, card.description.left(80)]
			lbl.modulate = Color.WHITE if not is_consumed else Color(0.4, 0.4, 0.4, 1)
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		spells_section.add_child(lbl)

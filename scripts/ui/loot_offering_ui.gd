## LootOfferingUI — Between-wave loot picker per WEAPONS_AND_CARDS.md §6
## Shows 3 items: function card (~40%), attachment (~30%), weapon (~20%), free attachment (~10%)
## At least 1 function card always offered.
## Handles: new weapon selection (which slot?), attachment targeting (which weapon?)
extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var item_container: HBoxContainer = $Panel/VBoxContainer/ItemContainer

var _offered_items: Array = []  # Array of {type: String, data: Resource}
var _pending_attachment: Resource = null  # waiting for player to pick target weapon
var _weapon_controller: Node3D = null


func _ready() -> void:
	EventBus.loot_offering_started.connect(_on_offering_started)
	panel.visible = false


func _on_offering_started(items: Array) -> void:
	_offered_items = items
	_weapon_controller = get_node_or_null("/root/Main/Player/Head/WeaponHolder")
	_build_item_buttons()
	panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.process_mode = Node.PROCESS_MODE_ALWAYS


func _build_item_buttons() -> void:
	for child in item_container.get_children():
		child.queue_free()

	for i in _offered_items.size():
		var item: Dictionary = _offered_items[i]
		var btn := _make_item_card(item)
		item_container.add_child(btn)


func _make_item_card(item: Dictionary) -> PanelContainer:
	var type: String = item.get("type", "unknown")
	var data: Resource = item.get("data")

	var panel_card := PanelContainer.new()
	panel_card.custom_minimum_size = Vector2(200, 280)

	var color := _get_item_color(type, data)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.15, 0.95)
	style.border_color = color
	style.set_border_width_all(3)
	style.set_corner_radius_all(6)
	panel_card.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 8)
	panel_card.add_child(vbox)

	# Type icon
	var type_label := Label.new()
	type_label.text = _get_type_icon(type)
	type_label.add_theme_font_size_override("font_size", 28)
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(type_label)

	# Color swatch
	var swatch := ColorRect.new()
	swatch.custom_minimum_size = Vector2(50, 50)
	swatch.color = color
	swatch.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(swatch)

	# Name
	var name_label := Label.new()
	name_label.text = _get_item_name(type, data)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_label)

	# Description
	var desc_label := Label.new()
	desc_label.text = _get_item_desc(type, data)
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	# Select button
	var btn := Button.new()
	btn.text = "SELECT"
	btn.pressed.connect(_on_item_selected.bind(item))
	vbox.add_child(btn)

	return panel_card


func _on_item_selected(item: Dictionary) -> void:
	var type: String = item.get("type", "")
	var data: Resource = item.get("data")

	match type:
		"function_card":
			if _weapon_controller and _weapon_controller.has_method("add_spell_to_hand"):
				_weapon_controller.add_spell_to_hand(data)
		"weapon":
			_show_weapon_slot_picker(data)
			return
		"attachment", "free_attachment":
			_show_attachment_target_picker(data)
			return

	_close()
	EventBus.loot_item_selected.emit(item)


func _show_weapon_slot_picker(weapon_data: Resource) -> void:
	## Ask player: replace slot 1 or slot 2?
	for child in item_container.get_children():
		child.queue_free()

	title_label.text = "WHICH SLOT?"
	for slot in 2:
		var existing = null
		if _weapon_controller:
			var weapons: Array = _weapon_controller.weapons
			if slot < weapons.size() and weapons[slot]:
				existing = weapons[slot].data

		var btn := Button.new()
		btn.text = "Slot %d\n%s" % [slot + 1, str(existing.weapon_name) if existing else "(empty)"]
		btn.custom_minimum_size = Vector2(180, 80)
		btn.pressed.connect(func():
			if _weapon_controller and _weapon_controller.has_method("give_weapon"):
				_weapon_controller.give_weapon(weapon_data, slot)
			_close()
			EventBus.loot_item_selected.emit({"type": "weapon", "data": weapon_data})
		)
		item_container.add_child(btn)


func _show_attachment_target_picker(att_data: Resource) -> void:
	## Ask player: apply to weapon 1 or weapon 2?
	for child in item_container.get_children():
		child.queue_free()

	title_label.text = "APPLY TO WHICH WEAPON?"
	for slot in 2:
		var existing = null
		if _weapon_controller:
			var weapons: Array = _weapon_controller.weapons
			if slot < weapons.size() and weapons[slot]:
				existing = weapons[slot].data

		if existing == null:
			continue

		var btn := Button.new()
		btn.text = "Weapon %d\n%s" % [slot + 1, str(existing.weapon_name)]
		btn.custom_minimum_size = Vector2(180, 80)
		btn.pressed.connect(func():
			if _weapon_controller and _weapon_controller.has_method("add_attachment_to_slot"):
				_weapon_controller.add_attachment_to_slot(att_data, slot)
			_close()
			EventBus.loot_item_selected.emit({"type": "attachment", "data": att_data})
		)
		item_container.add_child(btn)


func _close() -> void:
	panel.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT


func _get_item_color(type: String, data: Resource) -> Color:
	if not data:
		return Color.WHITE
	if data.get("color"):
		return data.color
	match type:
		"weapon": return Color(0.8, 0.6, 0.2, 1)
		"attachment": return Color(0.5, 0.5, 0.8, 1)
		_: return Color.WHITE


func _get_item_name(type: String, data: Resource) -> String:
	if data and data.get("weapon_name"): return str(data.weapon_name)
	if data and data.get("attachment_name"): return str(data.attachment_name)
	if data and data.get("card_name"): return str(data.card_name)
	return type


func _get_item_desc(type: String, data: Resource) -> String:
	if data and data.get("description"): return data.description
	return ""


func _get_type_icon(type: String) -> String:
	match type:
		"weapon": return "🔫"
		"attachment": return "🔧"
		"free_attachment": return "🔧★"
		"function_card": return "✨"
		_: return "?"

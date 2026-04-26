## SpellHandUI — 5 spell slots on left side of screen
## Listens to spell_hand_state_changed (new system) and spell_hand_changed (legacy)
## Shows: active spell highlighted, consumed spells grayed, mag spell color, combo indicators
extends CanvasLayer

@onready var slots: Array = []  # built dynamically
@onready var slot_container: VBoxContainer = $SlotContainer
@onready var toxic_fire_label: Label = $ToxicFireLabel

const SLOT_COUNT: int = 5


func _ready() -> void:
	EventBus.spell_hand_state_changed.connect(_on_spell_hand_state_changed)
	EventBus.spell_hand_changed.connect(_on_spell_hand_changed_legacy)
	EventBus.mag_spell_activated.connect(_on_mag_spell_activated)
	EventBus.combo_triggered.connect(_on_combo_triggered)
	EventBus.spell_cast_new.connect(_on_spell_cast)

	if toxic_fire_label:
		toxic_fire_label.modulate.a = 0.0

	_build_slots()


func _build_slots() -> void:
	for child in slot_container.get_children():
		child.queue_free()
	slots.clear()

	for i in SLOT_COUNT:
		var slot := _make_slot(Color(0.3, 0.3, 0.3, 0.5), "")
		slot_container.add_child(slot)
		slots.append(slot)


func _make_slot(color: Color, label_text: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(52, 52)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.15, 0.9)
	style.border_color = color
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vbox)

	var icon := ColorRect.new()
	icon.custom_minimum_size = Vector2(34, 34)
	icon.color = color
	icon.name = "Icon"
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(icon)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.name = "Label"
	vbox.add_child(lbl)

	return panel


func _update_slot(index: int, color: Color, label_text: String, is_active: bool, is_consumed: bool) -> void:
	if index >= slots.size():
		return
	var panel: PanelContainer = slots[index]
	var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		var final_color := color
		if is_consumed:
			final_color = Color(color.r * 0.25, color.g * 0.25, color.b * 0.25, 0.4)
		style.border_color = final_color
		style.bg_color = Color(final_color.r * 0.1, final_color.g * 0.1, final_color.b * 0.1, 0.9)

	var icon: ColorRect = panel.get_node_or_null("PanelContainer/VBoxContainer/Icon")
	if not icon:
		icon = _find_child_by_name(panel, "Icon")
	if icon:
		icon.color = color if not is_consumed else Color(color.r * 0.25, color.g * 0.25, color.b * 0.25, 0.4)

	var lbl: Label = _find_child_by_name(panel, "Label")
	if lbl:
		lbl.text = label_text
		lbl.modulate.a = 1.0 if not is_consumed else 0.3

	panel.scale = Vector2(1.15, 1.15) if is_active and not is_consumed else Vector2.ONE


func _find_child_by_name(node: Node, name: String) -> Node:
	for child in node.get_children():
		if child.name == name:
			return child
		var found := _find_child_by_name(child, name)
		if found:
			return found
	return null


# ─── New system ───────────────────────────────────────────────────────────────

func _on_spell_hand_state_changed(spell_hand: Array, consumed: Array, active_index: int) -> void:
	for i in SLOT_COUNT:
		if i >= spell_hand.size() or spell_hand[i] == null:
			_update_slot(i, Color(0.2, 0.2, 0.2, 0.4), "", false, true)
			continue
		var card: FunctionCardData = spell_hand[i]
		var is_consumed: bool = consumed[i] if i < consumed.size() else true
		var is_active: bool = (i == active_index)
		_update_slot(i, card.color, _short_name(card.card_name), is_active, is_consumed)


func _on_spell_cast(card: Object) -> void:
	pass  # visual update comes via spell_hand_state_changed


func _on_mag_spell_activated(spell: Object, _weapon: Object) -> void:
	# Flash the active weapon slot area briefly with spell color
	pass


func _on_combo_triggered(combo_name: String, _pos: Vector3) -> void:
	if combo_name == "TOXIC FIRE":
		_show_toxic_fire()


# ─── Legacy system ────────────────────────────────────────────────────────────

func _on_spell_hand_changed_legacy(spell_hand: Array, consumed: Array, active_index: int) -> void:
	for i in SLOT_COUNT:
		if i >= spell_hand.size() or spell_hand[i] == null:
			_update_slot(i, Color(0.2, 0.2, 0.2, 0.4), "", false, true)
			continue
		var card = spell_hand[i]
		var is_consumed: bool = consumed[i] if i < consumed.size() else true
		var is_active: bool = (i == active_index)
		var card_color: Color = card.color if card.get("color") else Color.WHITE
		var name_str: String = _short_name(card.card_name) if card.get("card_name") else ""
		_update_slot(i, card_color, name_str, is_active, is_consumed)


func _show_toxic_fire() -> void:
	if not toxic_fire_label:
		return
	toxic_fire_label.text = "TOXIC FIRE!"
	toxic_fire_label.modulate = Color(0.4, 1.0, 0, 1.0)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(toxic_fire_label, "position:y", toxic_fire_label.position.y - 30, 0.6)
	tween.tween_property(toxic_fire_label, "modulate:a", 0.0, 0.6).set_delay(0.2)


func _short_name(full: StringName) -> String:
	var s := str(full)
	if s.length() <= 4:
		return s.to_upper()
	return s.left(4).to_upper()

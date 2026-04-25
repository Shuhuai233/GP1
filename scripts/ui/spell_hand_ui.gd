## SpellHandUI — Left side of screen, 3 card icons (active/consumed/empty)
## Per GDD §9: active spell highlighted/enlarged, consumed grayed out
extends CanvasLayer

@onready var slots: Array[Control] = []
@onready var slot1: Control = $SlotContainer/Slot1
@onready var slot2: Control = $SlotContainer/Slot2
@onready var slot3: Control = $SlotContainer/Slot3
@onready var shield_bar: ProgressBar = $ShieldBar
@onready var toxic_fire_label: Label = $ToxicFireLabel


func _ready() -> void:
	slots = [slot1, slot2, slot3]
	EventBus.spell_hand_changed.connect(_on_spell_hand_changed)
	EventBus.player_shield_changed.connect(_on_shield_changed)
	EventBus.spell_detonator_hit.connect(_on_detonator_hit)
	EventBus.spell_barrier_activated.connect(_on_barrier_activated)
	EventBus.spell_flashfire_activated.connect(_on_flashfire_activated)
	shield_bar.visible = false
	toxic_fire_label.modulate.a = 0.0


func _on_spell_hand_changed(spell_hand: Array, consumed: Array, active_index: int) -> void:
	for i in 3:
		var slot := slots[i]
		var icon: ColorRect = slot.get_node("Icon")
		var label: Label = slot.get_node("CardLabel")
		var frame: Panel = slot.get_node("Frame")

		if i >= spell_hand.size() or spell_hand[i] == null:
			# Empty slot
			icon.color = Color(0.2, 0.2, 0.2, 0.4)
			label.text = ""
			slot.scale = Vector2.ONE
			frame.modulate = Color(0.5, 0.5, 0.5, 0.4)
			continue

		var card: CardData = spell_hand[i]
		var is_consumed: bool = consumed[i]
		var is_active: bool = (i == active_index)

		icon.color = card.color if not is_consumed else Color(card.color.r * 0.3, card.color.g * 0.3, card.color.b * 0.3, 0.5)
		label.text = _get_short_name(card.card_name)
		label.modulate.a = 1.0 if not is_consumed else 0.4

		# Active: enlarged + bright border
		if is_active and not is_consumed:
			slot.scale = Vector2(1.2, 1.2)
			frame.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			slot.scale = Vector2.ONE
			frame.modulate = Color(0.6, 0.6, 0.6, 0.7)


func _on_shield_changed(shield: float, max_shield: float) -> void:
	if max_shield <= 0:
		shield_bar.visible = false
		return
	shield_bar.visible = shield > 0
	shield_bar.max_value = max_shield
	shield_bar.value = shield


func _on_detonator_hit(_enemy: Node3D, _bonus: float, toxic_fire: bool) -> void:
	if toxic_fire:
		_show_toxic_fire_popup()


func _on_barrier_activated(_shield: float, _duration: float) -> void:
	# Brief cyan flash on the active slot
	var slot := slots[0]  # slot shown just after cast
	var tween := create_tween()
	tween.tween_property(slot, "modulate", Color(0, 0.9, 0.9, 1.5), 0.1)
	tween.tween_property(slot, "modulate", Color.WHITE, 0.3)


func _on_flashfire_activated(_count: int) -> void:
	# Brief orange flash
	for slot in slots:
		var tween := create_tween()
		tween.tween_property(slot, "modulate", Color(1, 0.4, 0, 1.5), 0.1)
		tween.tween_property(slot, "modulate", Color.WHITE, 0.3)


func _show_toxic_fire_popup() -> void:
	toxic_fire_label.text = "TOXIC FIRE!"
	toxic_fire_label.modulate = Color(0.4, 1.0, 0, 1.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(toxic_fire_label, "position:y", toxic_fire_label.position.y - 30, 0.6)
	tween.tween_property(toxic_fire_label, "modulate:a", 0.0, 0.6).set_delay(0.2)


func _get_short_name(full_name: StringName) -> String:
	match full_name:
		&"Detonator":   return "DET"
		&"Barrier":     return "BAR"
		&"Flashfire":   return "FLR"
		_:              return str(full_name).left(3).to_upper()

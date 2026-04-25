## CardSelectionUI — Between-wave screen: pick 1 of 3 random cards
## Shows card name, color, stats. Picking adds card to deck and resumes game.
extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var card_container: HBoxContainer = $Panel/VBoxContainer/CardContainer
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel

var card_button_scene: PackedScene = null
var offered_cards: Array = []


func _ready() -> void:
	EventBus.card_selection_started.connect(_on_selection_started)
	panel.visible = false


func _on_selection_started(cards: Array) -> void:
	offered_cards = cards
	_build_card_buttons()
	panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# GDD §11: player CAN still look around but CANNOT fire or move.
	# Set tree paused but give the player node PROCESS_MODE_ALWAYS so _input still runs.
	get_tree().paused = true
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.process_mode = Node.PROCESS_MODE_ALWAYS


func _build_card_buttons() -> void:
	# Clear existing
	for child in card_container.get_children():
		child.queue_free()

	for i in offered_cards.size():
		var card: CardData = offered_cards[i]
		var btn := _create_card_button(card, i)
		card_container.add_child(btn)


func _create_card_button(card: CardData, index: int) -> PanelContainer:
	var container := PanelContainer.new()
	container.custom_minimum_size = Vector2(200, 280)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.18, 0.95)
	style.border_color = card.color
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	container.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	container.add_child(vbox)

	# Color swatch
	var swatch := ColorRect.new()
	swatch.custom_minimum_size = Vector2(60, 60)
	swatch.color = card.color
	swatch.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(swatch)

	# Card name
	var name_label := Label.new()
	name_label.text = str(card.card_name)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)

	# Stats
	var stats_label := Label.new()
	stats_label.text = _get_card_description(card)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 12)
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(stats_label)

	# Select button
	var select_btn := Button.new()
	select_btn.text = "SELECT"
	select_btn.pressed.connect(_on_card_picked.bind(card))
	vbox.add_child(select_btn)

	return container


func _get_card_description(card: CardData) -> String:
	var desc := "%d bullets\n%d dmg" % [card.bullets_per_pack, int(card.damage_per_bullet)]
	if card.status_effect == CardData.StatusEffectType.POISON:
		desc += "\n+%d poison/hit" % card.status_stacks_per_hit
	elif card.status_effect == CardData.StatusEffectType.BURN:
		desc += "\n+20%% dmg burn"
	if card.piercing:
		desc += "\nPiercing"
	if card.consumes_poison:
		desc += "\nDetonates poison\nx%.0f stacks" % card.poison_consume_multiplier
	return desc


func _on_card_picked(card: CardData) -> void:
	panel.visible = false
	get_tree().paused = false
	# Restore player to default process mode
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventBus.card_selected.emit(card)

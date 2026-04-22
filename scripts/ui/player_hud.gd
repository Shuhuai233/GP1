## PlayerHUD — Crosshair, ammo counter, HP bar, card icon
## Design rule: player SEES info through color, never READS it off a HUD panel
extends CanvasLayer

@onready var crosshair: TextureRect = $Crosshair
@onready var ammo_label: Label = $AmmoContainer/AmmoLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var card_icon: ColorRect = $CardIcon
@onready var reload_label: Label = $ReloadLabel
@onready var pack_indicators: HBoxContainer = $PackIndicators

var crosshair_base_color: Color = Color.WHITE


func _ready() -> void:
	EventBus.ammo_changed.connect(_on_ammo_changed)
	EventBus.card_pack_changed.connect(_on_card_pack_changed)
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.weapon_reload_started.connect(_on_reload_started)
	EventBus.weapon_reload_finished.connect(_on_reload_finished)
	reload_label.visible = false


func _on_ammo_changed(bullets_in_pack: int, packs_remaining: int, current_card: Resource) -> void:
	if current_card:
		ammo_label.text = "%d" % bullets_in_pack
		_update_crosshair_color(current_card.color)
		_update_pack_indicators(packs_remaining)
	else:
		ammo_label.text = "0"


func _on_card_pack_changed(card: Resource) -> void:
	_update_crosshair_color(card.color)
	card_icon.color = card.color

	# Brief flash effect on card change
	var tween := create_tween()
	crosshair.modulate = Color.WHITE * 2.0
	tween.tween_property(crosshair, "modulate", Color.WHITE, 0.2)


func _on_health_changed(current: float, max_hp: float) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current

	# Tint HP bar red when low
	if current / max_hp < 0.3:
		hp_bar.modulate = Color(1, 0.3, 0.3)
	else:
		hp_bar.modulate = Color.WHITE


func _on_reload_started() -> void:
	reload_label.visible = true
	ammo_label.text = "--"

	# Pulse animation
	var tween := create_tween().set_loops()
	tween.tween_property(reload_label, "modulate:a", 0.3, 0.4)
	tween.tween_property(reload_label, "modulate:a", 1.0, 0.4)


func _on_reload_finished() -> void:
	reload_label.visible = false


func _update_crosshair_color(color: Color) -> void:
	crosshair.modulate = color
	ammo_label.add_theme_color_override("font_color", color)


func _update_pack_indicators(packs_remaining: int) -> void:
	for i in pack_indicators.get_child_count():
		var indicator: ColorRect = pack_indicators.get_child(i)
		indicator.modulate.a = 1.0 if i < packs_remaining else 0.2

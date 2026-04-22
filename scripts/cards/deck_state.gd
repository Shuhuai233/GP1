## DeckState — Pure data class for deck/magazine management
## No node dependencies. Testable standalone.
class_name DeckState
extends RefCounted

var deck: Array[CardData] = []
var magazine: Array[CardData] = []
var current_pack_index: int = 0
var bullets_remaining_in_pack: int = 0

const MAGAZINE_SIZE: int = 6


func initialize(starter_deck: Array[CardData]) -> void:
	deck = starter_deck.duplicate()
	reload()


func reload() -> void:
	deck.shuffle()
	magazine.clear()
	for i in mini(deck.size(), MAGAZINE_SIZE):
		magazine.append(deck[i])
	current_pack_index = 0
	if magazine.size() > 0:
		bullets_remaining_in_pack = magazine[0].bullets_per_pack


func fire() -> CardData:
	if magazine.is_empty():
		return null
	if bullets_remaining_in_pack <= 0:
		return null

	var card := get_current_card()
	bullets_remaining_in_pack -= 1

	# If pack is empty, advance to next pack
	if bullets_remaining_in_pack <= 0:
		current_pack_index += 1
		if current_pack_index < magazine.size():
			bullets_remaining_in_pack = magazine[current_pack_index].bullets_per_pack

	return card


func get_current_card() -> CardData:
	if current_pack_index < magazine.size():
		return magazine[current_pack_index]
	return null


func is_magazine_empty() -> bool:
	return current_pack_index >= magazine.size() or get_current_card() == null


func get_packs_remaining() -> int:
	return magazine.size() - current_pack_index


func add_card(card: CardData) -> void:
	deck.append(card)

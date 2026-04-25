## DeckState — Two-hand deck management
## On reload: shuffle deck → top 6 FIRING cards → gun magazine
##                        → top 3 FUNCTION cards → spell hand
## Pure data class, no node dependencies.
class_name DeckState
extends RefCounted

var deck: Array[CardData] = []

# Gun (right hand)
var magazine: Array[CardData] = []         # up to 6 firing cards
var current_pack_index: int = 0
var bullets_remaining_in_pack: int = 0

# Spell hand (left hand)
var spell_hand: Array[CardData] = []       # up to 3 function cards
var spell_consumed: Array[bool] = []       # parallel array: consumed flags
var active_spell_index: int = 0

const GUN_SLOTS: int = 6
const SPELL_SLOTS: int = 3


func initialize(starter_deck: Array[CardData]) -> void:
	deck = starter_deck.duplicate()
	reload()


func reload() -> void:
	deck.shuffle()

	# Separate by type
	var firing: Array[CardData] = []
	var function_cards: Array[CardData] = []
	for card in deck:
		if card.card_type == CardData.CardType.FIRING:
			firing.append(card)
		else:
			function_cards.append(card)

	# Load gun: top GUN_SLOTS firing cards
	magazine.clear()
	for i in mini(firing.size(), GUN_SLOTS):
		magazine.append(firing[i])
	current_pack_index = 0
	if magazine.size() > 0:
		bullets_remaining_in_pack = magazine[0].bullets_per_pack

	# Load spell hand: top SPELL_SLOTS function cards
	spell_hand.clear()
	spell_consumed.clear()
	for i in mini(function_cards.size(), SPELL_SLOTS):
		spell_hand.append(function_cards[i])
		spell_consumed.append(false)
	# Pad empty slots
	while spell_hand.size() < SPELL_SLOTS:
		spell_hand.append(null)
		spell_consumed.append(true)  # treat empty as consumed

	# Find first unconsumed spell
	active_spell_index = _find_next_spell(0)


# --- Gun methods ---

func fire_gun() -> CardData:
	if magazine.is_empty() or bullets_remaining_in_pack <= 0:
		return null

	var card := get_current_gun_card()
	bullets_remaining_in_pack -= 1

	if bullets_remaining_in_pack <= 0:
		current_pack_index += 1
		if current_pack_index < magazine.size():
			bullets_remaining_in_pack = magazine[current_pack_index].bullets_per_pack

	return card


func get_current_gun_card() -> CardData:
	if current_pack_index < magazine.size():
		return magazine[current_pack_index]
	return null


func is_gun_empty() -> bool:
	return current_pack_index >= magazine.size() or get_current_gun_card() == null


func get_gun_packs_remaining() -> int:
	return magazine.size() - current_pack_index


# --- Spell hand methods ---

func get_active_spell() -> CardData:
	if active_spell_index < 0 or active_spell_index >= spell_hand.size():
		return null
	return spell_hand[active_spell_index]


func is_spell_hand_empty() -> bool:
	return active_spell_index < 0


func cast_spell() -> CardData:
	var spell := get_active_spell()
	if spell == null:
		return null

	spell_consumed[active_spell_index] = true
	active_spell_index = _find_next_spell(active_spell_index + 1)
	return spell


func _find_next_spell(from_index: int) -> int:
	for i in range(from_index, spell_hand.size()):
		if not spell_consumed[i] and spell_hand[i] != null:
			return i
	return -1  # all consumed


# --- Deck management ---

func add_card(card: CardData) -> void:
	deck.append(card)

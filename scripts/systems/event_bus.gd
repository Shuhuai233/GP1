## EventBus — Global signal relay for decoupled communication
extends Node

# Player signals
signal player_damaged(amount: float)
signal player_died()
signal player_health_changed(current: float, max_hp: float)

# Weapon signals
signal weapon_fired(card: Resource)
signal weapon_reload_started()
signal weapon_reload_finished()
signal ammo_changed(bullets_in_pack: int, packs_in_magazine: int, current_card: Resource)
signal card_pack_changed(card: Resource)

# Enemy signals
signal enemy_damaged(enemy: Node3D, amount: float)
signal enemy_died(enemy: Node3D)
signal enemy_status_applied(enemy: Node3D, status_type: String, stacks: int)
signal enemy_poison_detonated(enemy: Node3D, stacks_consumed: int, bonus_damage: float)

# Wave signals
signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal all_waves_cleared()

# Card selection signals
signal card_selection_started(cards: Array)
signal card_selected(card: Resource)

# Hit feedback
signal hit_confirmed(position: Vector3, card: Resource, enemy: Node3D)
signal hit_missed(position: Vector3, card: Resource)

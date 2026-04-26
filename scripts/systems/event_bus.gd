## EventBus — Global signal relay for decoupled communication
extends Node

# ─── Player ──────────────────────────────────────────────────────────────────
signal player_damaged(amount: float)
signal player_died()
signal player_health_changed(current: float, max_hp: float)
signal player_shield_changed(shield: float, max_shield: float)
signal player_healed(amount: float)
signal player_speed_changed(multiplier: float)

# ─── Weapon (legacy — old weapon.gd, kept for compat) ────────────────────────
signal weapon_fired(card: Resource)
signal weapon_reload_started()
signal weapon_reload_finished()
signal ammo_changed(bullets_in_pack: int, packs_in_magazine: int, current_card: Resource)
signal card_pack_changed(card: Resource)
signal spell_cast(card: Resource)
signal spell_hand_changed(spell_hand: Array, consumed: Array, active_index: int)
signal spell_detonator_hit(enemy: Node3D, bonus_damage: float, toxic_fire: bool)
signal spell_barrier_activated(shield_amount: float, duration: float)
signal spell_flashfire_activated(enemies_hit: int)

# ─── Weapon (new system — weapon_controller.gd) ───────────────────────────────
## Emitted every time weapon state changes (ammo, slot, active weapon)
signal weapon_state_changed(weapons: Array, active_slot: int)
## Emitted every time spell hand changes (consumed, active index)
signal spell_hand_state_changed(spell_hand: Array, consumed: Array, active_index: int)
## Fired when a bullet hits something
signal weapon_fired_new(weapon_instance: Object)
signal hit_confirmed_new(position: Vector3, weapon_instance: Object, enemy: Node3D)
signal hit_missed_new(position: Vector3, weapon_instance: Object)
## Fired when a function card spell is cast
signal spell_cast_new(card: Object)
## Fired when a magazine spell is activated on a weapon
signal mag_spell_activated(spell: Object, weapon_instance: Object)
## Iron Skin
signal iron_skin_activated(hits_remaining: int)
signal iron_skin_depleted()
## Status combo triggers (for UI popups)
signal combo_triggered(combo_name: String, position: Vector3)

# ─── Buff signals (old system compat) ────────────────────────────────────────
signal buff_war_cry_activated(multiplier: float)
signal buff_overclock_activated(duration: float)
signal buff_adrenaline_activated(duration: float)
signal buff_fuel_activated(packs_remaining: int)
signal buff_vampiric_burst_activated(duration: float)
signal buff_megashot_ready()

# ─── Enemy ───────────────────────────────────────────────────────────────────
signal enemy_damaged(enemy: Node3D, amount: float)
signal enemy_died(enemy: Node3D)
signal enemy_status_applied(enemy: Node3D, status_type: String, stacks: int)
signal enemy_poison_detonated(enemy: Node3D, stacks_consumed: int, bonus_damage: float, toxic_fire: bool)

# ─── Wave ─────────────────────────────────────────────────────────────────────
signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal all_waves_cleared()
signal between_wave_heal(amount: float)

# ─── Loot offering (new system) ───────────────────────────────────────────────
signal loot_offering_started(items: Array)  # Array of {type, data} dicts
signal loot_item_selected(item: Dictionary)

# ─── Legacy card selection ────────────────────────────────────────────────────
signal card_selection_started(cards: Array)
signal card_selected(card: Resource)

# ─── Hit feedback ────────────────────────────────────────────────────────────
signal hit_confirmed(position: Vector3, card: Resource, enemy: Node3D)
signal hit_missed(position: Vector3, card: Resource)

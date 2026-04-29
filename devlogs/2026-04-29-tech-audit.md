# Tech Director Audit: 2026-04-29

## Overall Status

The new weapon system is architecturally complete:
- 6/6 weapons with .tres resources ✅
- 15/15 attachments (14 functional, Thermal Scope data-only) ✅
- 20/20 function cards with spell handlers ✅
- 6/6 status effects ✅
- 5/5 status combos ✅
- All 3C values applied to player.gd ✅
- All input actions present ✅

What remains: 2 blockers, 3 major bugs, presentation (models, audio, crosshair), and dead code cleanup.

## BLOCKERS (must fix)

### 1. All weapons are semi-auto — SMG/AR/Machine Pistol unplayable
File: weapon_controller.gd:193
Problem: uses is_action_just_pressed("fire") — requires click per shot
Fix: change to is_action_pressed("fire"). fire_timer already gates rate.

### 2. Reload does NOT end Dash immunity
File: weapon_controller.gd:946-956
Problem: design says immunity ends on reload. Code doesn't clear it.
Fix: add dash immunity clear in _on_reload_finished()

## MAJOR BUGS (should fix)

### 3. Sniper ADS FOV ignores weapon data
File: player.gd:283
Problem: uses fixed ads_fov=75 for all weapons. Sniper.tres has ads_fov=36.
Fix: read per-weapon ads_fov from weapon_controller

### 4. Elemental Converter logic backwards
File: weapon_controller.gd:656-663
Problem: only checks non-active weapon for converter. Should check EITHER weapon.
Fix: loop all weapons for converter attachment

### 5. Dash default values wrong in function_card_data.gd
File: function_card_data.gd:32-33
Problem: dash_distance=5.0 (should be 3.0), dash_iframes=0.2 (should be 2.0)
Fix: change defaults. .tres overrides are correct so runtime is fine, but defaults are traps.

## HALF-BUILT

### 6. Weapon models not displayed
Six weapon scenes exist, weapon_data has model_scene_path, but weapon_controller never loads them. Player sees no gun.
Fix: add model loading in _ready() and give_weapon(). ~30 lines.

### 7. Machine Pistol speed bonus flickers
Speed bonus applied per-shot, reset on fire_timeout. At 8/sec it flickers on/off.
Fix: add grace timer (0.25s) before resetting speed.

### 8. Split Barrel ignores travel distance
Splits immediately on hit regardless of distance. Should only split after 5m.
Fix: check distance before calling _split_bullet_check()

### 9. Quick Grip i-frames only block projectiles, not melee
Rusher melee bypasses grace period check.
Fix: route through absorb_damage with timer, similar to Dash.

### 10. Loot offering can offer duplicate attachments
No tracking of owned attachments. Design says unique per run.
Fix: track owned attachment names, filter from pool.

## DELETE (old system, dead code)

| File | Reason |
|---|---|
| scripts/weapons/weapon.gd (808 lines) | Old 40-card system. Not instanced. |
| scenes/player/weapon.tscn | Old weapon scene. Not referenced. |
| scripts/cards/card_data.gd (138 lines) | Old CardData class. |
| scripts/cards/deck_state.gd (127 lines) | Old deck state. SPELL_SLOTS=3. |
| scripts/ui/card_selection_ui.gd (116 lines) | Old card picker. Replaced by loot_offering_ui. |
| data/cards/*.tres (40 files) | Old card resources. |

Plus cleanup stale references in: player.gd, enemy_base.gd, event_bus.gd, spell_hand_ui.gd, weapon_data.gd

## MISSING ENTIRELY

| Feature | Effort |
|---|---|
| Crosshair UI (dot + circle, color tint) | Small |
| Hit markers (expansion, kill X) | Small |
| Audio (any — zero sounds exist) | Medium |
| Muzzle flash on new weapon system | Small |
| Headshot detection system | Large |
| Thermal Scope implementation | Large |
| Wave countdown UI | Small |

## RECOMMENDED BUILD ORDER

Phase 0: Delete dead code (30 min)
Phase 1: Fix 2 blockers + 3 major bugs (1-2 hours)
Phase 2: Weapon models + crosshair + muzzle flash + hit markers (half day)
Phase 3: Audio placeholders (half day)
Phase 4: Polish bugs — Machine Pistol speed, Split Barrel distance, Quick Grip melee, attachment dedup, wave countdown UI (1 day)
Phase 5: Deferred — headshot hitbox, Thermal Scope, per-weapon audio, attachment visuals on models

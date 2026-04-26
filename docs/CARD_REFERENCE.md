# GP1 — Card Reference (40 Cards)

*Complete list of all cards with stats. Generated from .tres resource files.*

---

## NEUTRAL (7 cards)

### Firing Cards

| Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|
| Standard Round | 6 | 8 | White | None. Baseline. |
| Piercing Round | 6 | 8 | Blue | Passes through first target. |
| Ricochet Round | 6 | 7 | Steel Blue | Bounces once off walls toward nearest enemy (10m). |
| Drain Round | 6 | 5 | Dark Red | Heals player 2 HP per hit. |

### Function Cards

| Card | Color | Effect |
|---|---|---|
| Barrier | Cyan | 30 HP shield, 5 sec. |
| Vampiric Burst | Dark Red | 3 sec: gun damage heals 50% of damage dealt. |
| Reload Surge | Near-White | Instant reload. Skip 2 sec delay. Both hands reshuffle. |

---

## POWER (8 cards)

### Firing Cards

| Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|
| Heavy Round | 4 | 15 | Dark Gold | High damage. Fewer bullets, each one HURTS. |
| Armor Piercer | 6 | 10 | Steel Gray | Ignores enemy damage resistance. |
| Headhunter Round | 6 | 8 | Crimson | Headshots deal 3x (instead of 1.5x). |
| Explosive Round | 3 | 12 | Burnt Orange | Each bullet explodes on impact. 3m AoE. |

### Function Cards

| Card | Color | Effect |
|---|---|---|
| War Cry | Gold | Next magazine: ALL firing cards +50% damage. |
| Iron Skin | Steel Gray | 40 HP shield, 6 sec. While active: +20% damage. |
| Megashot | Bright Gold | Next single bullet deals 5x damage. |
| Executioner | Dark Gold | Aim at target: instant kill if below 30% HP. Wasted if above. |

---

## VENOM (6 cards)

### Firing Cards

| Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|
| Venom Round | 6 | 6 | Bright Green | +2 poison stacks per hit. |
| Toxic Needle | 6 | 4 | Dark Green | +3 poison stacks per hit. Lower damage, fast stacking. |
| Plague Round | 4 | 6 | Yellow-Green | +2 poison stacks. On kill: spreads stacks to nearest enemy (8m). |

### Function Cards

| Card | Color | Effect |
|---|---|---|
| Detonator | Purple | Hitscan. Consumes ALL poison stacks. Bonus = 3x stacks (6x if burning). |
| Toxin Bomb | Olive Green | All enemies within 8m gain 5 poison stacks. |
| Pandemic | Lime Green | All enemies within 10m gain 50% of highest poison stacks in range. |

---

## BLAZE (6 cards)

### Firing Cards

| Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|
| Incendiary Round | 6 | 8 | Orange | Applies Burn (+20% dmg taken, 5 sec, refreshes). |
| Ember Round | 8 | 5 | Warm Orange | Applies Burn. 8 bullets for sustained uptime. |
| Magma Round | 4 | 10 | Deep Red | Applies Burn. Leaves fire patch (3m, 4 sec, 3 dmg/sec). |

### Function Cards

| Card | Color | Effect |
|---|---|---|
| Flashfire | Red-Orange | All enemies within 10m get Burn. |
| Inferno | Dark Red-Orange | All burning enemies take 30 instant damage. |
| Fuel | Amber | Next 3 firing card packs also apply Burn on hit. |

---

## FLUX (7 cards)

### Firing Cards

| Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|
| Quicksilver Round | 8 | 5 | Light Silver | +20% move speed while firing this pack. |
| Tempo Round | 6 | 6 | Magenta | Consecutive hits within 0.5s: +2 bonus dmg each. Miss resets. |
| Tracer Round | 10 | 4 | Pink | Each hit gives next card pack +1 damage. Resets on reload. |

### Function Cards

| Card | Color | Effect |
|---|---|---|
| Phase Dash | Light Gray | Instant dash forward 5m. Invincible during dash. |
| Overclock | Hot Pink | 6 sec: fire rate doubled (6 shots/sec). |
| Adrenaline | Pink | 6 sec: +40% move speed, +20% fire rate, +20% reload speed. |
| Blink | Light Blue | Teleport to crosshair position (max 15m). |

---

## SHOCK (6 cards)

### Firing Cards

| Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|
| Volt Round | 6 | 7 | Blue | Hit chains to 1 nearby enemy (5m) for 50% damage. |
| Arc Round | 4 | 8 | Sky Blue | Hit chains to 2 nearby enemies (8m) for 40% damage each. |
| Static Round | 6 | 5 | Pale Blue | Applies Shock (3 sec). Shocked enemies take +15% chain damage. |

### Function Cards

| Card | Color | Effect |
|---|---|---|
| Chain Lightning | Blue | Hitscan. If target Shocked: bounces to 3 enemies, 15 dmg each. |
| Spotter | Red | Aim at target: apply Mark (+30% damage taken, 6 sec). |
| EMP Blast | Periwinkle | All enemies within 12m get Shocked + stunned 1 sec. |

---

## STATUS EFFECTS

| Status | Applied by | Effect | Duration |
|---|---|---|---|
| Poison | Venom, Toxic Needle, Plague, Toxin Bomb, Pandemic | Stacks. No decay. Consumed by Detonator (3x bonus, 6x if burning). | Until consumed |
| Burn | Incendiary, Ember, Magma, Flashfire, Fuel | +20% damage from ALL sources. | 5 sec, refreshes |
| Shock | Static Round, EMP Blast | +15% chain damage. Enables Chain Lightning bounces. | 3 sec |
| Mark | Spotter | +30% damage from ALL sources. | 6 sec, doesn't refresh |
| Slow | (no card yet — future) | -50% move speed. | 4 sec, refreshes |

## STATUS COMBOS

| Combo | Condition | Effect |
|---|---|---|
| Toxic Fire | Poison + Burn on same target | Detonator does 6x instead of 3x |
| (Future) Contagion | Poison + Shock | Execute spreads to chain targets |
| (Future) Meltdown | Burn + Slow | Burn ticks 2x fast |
| (Future) Overload | Shock + Mark | Explodes on death, AoE |
| (Future) Festering | Slow + Poison | +3 stacks/hit instead of +2 |

---

## TOTALS

| | Firing | Function | Total |
|---|---|---|---|
| NEUTRAL | 4 | 3 | 7 |
| POWER | 4 | 4 | 8 |
| VENOM | 3 | 3 | 6 |
| BLAZE | 3 | 3 | 6 |
| FLUX | 3 | 4 | 7 |
| SHOCK | 3 | 3 | 6 |
| **Total** | **20** | **20** | **40** |

---

## STARTER DECK (9 cards)

- 3x Standard Round (NEUTRAL, Firing)
- 1x Venom Round (VENOM, Firing)
- 1x Incendiary Round (BLAZE, Firing)
- 1x Piercing Round (NEUTRAL, Firing)
- 1x Detonator (VENOM, Function)
- 1x Barrier (NEUTRAL, Function)
- 1x Flashfire (BLAZE, Function)

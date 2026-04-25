# GP1 — Card Pool v2

*30+ cards organized by PLAYSTYLE, not just status type.*
*Each playstyle has its own firing cards AND function cards that work together.*
*Cards CAN cross playstyles — that's where discovery happens.*

---

## PLAYSTYLES (the "builds" players discover)

| Playstyle | Fantasy | Firing cards do | Function cards do |
|---|---|---|---|
| **POWER** | "Hit like a truck" | Raw damage, headshot bonuses, armor pierce | Damage buffs, shields, empowered shots |
| **VENOM** | "Stack and execute" | Apply poison stacks | Detonate stacks, spread poison |
| **BLAZE** | "Everything burns" | Apply burn, fire AoE | Area ignition, burn amplification |
| **FLUX** | "Speed demon" | Fast-hitting, BPM bonus, movement synergy | Dash, speed buffs, fire rate boosts |
| **SHOCK** | "Chain reaction" | Chain lightning between enemies | Trigger cascading explosions, mark targets |
| **NEUTRAL** | Flexible filler | Basic damage, pierce, ricochet | Shield, heal, utility |

---

## FIRING CARDS (Right Hand / Gun)

### POWER playstyle — raw damage, no status needed

| # | Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|---|
| F1 | Heavy Round | 4 | 15 | Dark Gold | High damage per bullet. No status. Fewer bullets = each shot matters. |
| F2 | Armor Piercer | 6 | 10 | Steel Gray | Ignores enemy damage resistance. Full damage always. |
| F3 | Headhunter Round | 6 | 8 | Crimson | Headshots deal 3x damage instead of normal 1.5x. Body shots deal normal. |
| F4 | Explosive Round | 3 | 12 | Dark Orange | Each bullet creates a 3m explosion on impact. Damages all enemies in radius. |

### VENOM playstyle — poison stacking

| # | Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|---|
| F5 | Venom Round | 6 | 6 | Green | +2 poison stacks per hit. The core stacker. |
| F6 | Toxic Needle | 6 | 4 | Dark Green | +3 poison stacks per hit, but lower damage. Fast stacking at a damage cost. |
| F7 | Plague Round | 4 | 6 | Yellow-Green | +2 poison stacks per hit. On kill: spreads all stacks to nearest enemy within 8m. |

### BLAZE playstyle — burn and fire damage

| # | Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|---|
| F8 | Incendiary Round | 6 | 8 | Orange | Applies Burn (+20% dmg taken, 5 sec, refreshes on hit). |
| F9 | Magma Round | 4 | 10 | Deep Red | Applies Burn. Bullets leave a fire patch on ground (3m, 4 sec, 3 dmg/sec to enemies standing in it). |
| F10 | Ember Round | 8 | 5 | Light Orange | Applies Burn. More bullets = more refresh uptime. Cheap sustained burn. |

### FLUX playstyle — speed, movement, BPM

| # | Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|---|
| F11 | Quicksilver Round | 8 | 5 | Silver | While firing: +20% move speed. Rewards running and gunning. |
| F12 | Tempo Round | 6 | 6 | Magenta | Each consecutive hit within 0.5s deals +2 bonus damage (combo counter). Miss resets. Rewards accuracy at speed. |
| F13 | Tracer Round | 10 | 4 | Bright Pink | Most bullets per pack. Low damage each. Every hit increases next card pack's damage by +1 (stacks across packs, resets on reload). |

### SHOCK playstyle — chain and spread

| # | Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|---|
| F14 | Volt Round | 6 | 7 | Electric Blue | Hit chains to 1 nearby enemy within 5m for 50% damage. |
| F15 | Arc Round | 4 | 8 | Blue-White | Hit chains to 2 nearby enemies within 8m for 40% damage each. Wider chain. |
| F16 | Static Round | 6 | 5 | Pale Blue | Applies Shock status (3 sec). Shocked enemies take +15% damage from chain effects. |

### NEUTRAL — flexible, any build

| # | Card | Bullets | Dmg | Color | Effect |
|---|---|---|---|---|---|
| F17 | Standard Round | 6 | 8 | White | No effect. Baseline. |
| F18 | Piercing Round | 6 | 8 | Blue | Passes through first target into next. |
| F19 | Ricochet Round | 6 | 7 | Silver-Blue | Bounces once off walls toward nearest enemy within 10m. |
| F20 | Drain Round | 6 | 5 | Dark Red | Each hit heals player 2 HP. |

**Total firing cards: 20**

---

## FUNCTION CARDS (Left Hand / Spell)

### POWER playstyle — buffs, empowerment, shields

| # | Card | Color | Effect | Consumed? |
|---|---|---|---|---|
| S1 | War Cry | Gold | Next magazine: ALL firing cards deal +50% damage. Lasts until next reload. | Yes |
| S2 | Iron Skin | Steel | Gain 40 HP shield for 6 sec. While shield active: +20% damage dealt. | Yes |
| S3 | Megashot | Bright Gold | Next single gun shot deals 5x damage. One bullet, one massive hit. | Yes |
| S4 | Executioner | Dark Gold | Aim at target: if enemy is below 30% HP, instantly kill it. If above 30%, does nothing (wasted). | Yes |

### VENOM playstyle — detonate, spread, multiply stacks

| # | Card | Color | Effect | Consumed? |
|---|---|---|---|---|
| S5 | Detonator | Purple | Hitscan at crosshair. Consumes ALL poison stacks on target. Bonus dmg = 3x stacks (6x if target also burning = Toxic Fire). Base dmg = 0. Consumed on cast. | Yes |
| S6 | Pandemic | Green-Yellow | All enemies within 10m gain 50% of the highest poison stack count on any enemy in range. | Yes |
| S7 | Toxin Bomb | Dark Green | All enemies within 8m gain 5 poison stacks instantly. | Yes |

### BLAZE playstyle — area fire, amplification

| # | Card | Color | Effect | Consumed? |
|---|---|---|---|---|
| S8 | Flashfire | Orange-Red | All enemies within 10m get Burn status. | Yes |
| S9 | Inferno | Deep Orange | All currently burning enemies take 30 instant fire damage. More burning enemies = more total damage. | Yes |
| S10 | Fuel | Amber | Next 3 firing card packs apply Burn in addition to their normal effect. Any card becomes a fire card. | Yes |

### FLUX playstyle — dash, speed, tempo

| # | Card | Color | Effect | Consumed? |
|---|---|---|---|---|
| S11 | Phase Dash | Light Gray | Instant dash forward 5m. Invincible during dash (0.2s). Can fire immediately after. | Yes |
| S12 | Overclock | Bright Magenta | For 6 sec: fire rate doubled (6 shots/sec instead of 3). All current card effects still apply. | Yes |
| S13 | Adrenaline | Pink | For 6 sec: +40% move speed, +20% fire rate, +20% reload speed. The "go fast" button. | Yes |
| S14 | Blink | White-Blue | Teleport to where crosshair is pointing (max 15m). Instant. Can fire immediately after. | Yes |

### SHOCK playstyle — chain triggers, mark, cascade

| # | Card | Color | Effect | Consumed? |
|---|---|---|---|---|
| S15 | Chain Lightning | Electric Blue | Hitscan at crosshair. If target has Shock status: lightning bounces to 3 more enemies, 15 dmg each. | Yes |
| S16 | Spotter | Red | Aim at target: apply Mark (+30% ALL damage taken, 6 sec). One target, one application. | Yes |
| S17 | EMP Blast | Pale Blue | All enemies within 12m get Shock status. Shocked enemies are stunned for 1 sec. | Yes |

### NEUTRAL — defensive, utility

| # | Card | Color | Effect | Consumed? |
|---|---|---|---|---|
| S18 | Barrier | Cyan | Gain 30 HP shield for 5 sec. | Yes |
| S19 | Vampiric Burst | Dark Red | For 3 sec: all gun damage heals player for 50% of damage dealt. | Yes |
| S20 | Reload Surge | White | Instant reload (skip 2 sec delay). Both hands reshuffle immediately. | Yes |

**Total function cards: 20**

---

## FULL POOL: 40 CARDS

| Playstyle | Firing | Function | Total |
|---|---|---|---|
| POWER | 4 (F1-F4) | 4 (S1-S4) | 8 |
| VENOM | 3 (F5-F7) | 3 (S5-S7) | 6 |
| BLAZE | 3 (F8-F10) | 3 (S8-S10) | 6 |
| FLUX | 3 (F11-F13) | 4 (S11-S14) | 7 |
| SHOCK | 3 (F14-F16) | 3 (S15-S17) | 6 |
| NEUTRAL | 4 (F17-F20) | 3 (S18-S20) | 7 |
| **TOTAL** | **20** | **20** | **40** |

---

## HOW PLAYSTYLES FEEL DIFFERENT

### POWER — "I hit hard. Every shot is a bomb."
- Firing: Heavy Round (15 dmg), Explosive Round (AoE), Headhunter (3x headshots)
- Spells: War Cry (+50% dmg), Megashot (5x single bullet), Iron Skin (shield + damage)
- Feel: Slow, deliberate, devastating. Fewer bullets per pack but each one HURTS.
- No status effects needed. Pure numbers.

### VENOM — "I build up poison, then BOOM."
- Firing: Venom (stack), Toxic Needle (fast stack), Plague (spread on kill)
- Spells: Detonator (execute), Pandemic (spread), Toxin Bomb (AoE stacks)
- Feel: Patient setup → explosive payoff. The 叠层后斩杀 playstyle.
- Combo: stack 20+ poison → Detonator = 60+ bonus damage

### BLAZE — "The world is on fire."
- Firing: Incendiary (burn), Magma (ground fire), Ember (sustained burn)
- Spells: Flashfire (area burn), Inferno (burst all burning enemies), Fuel (any card becomes fire)
- Feel: Area denial. Everything burns. Damage amplified everywhere.
- Combo: Flashfire (burn all) → any gun damage is +20% → Inferno (burst)

### FLUX — "I never stop moving."
- Firing: Quicksilver (+move speed), Tempo (combo counter), Tracer (stacking damage across packs)
- Spells: Phase Dash, Overclock (2x fire rate), Adrenaline (speed everything up), Blink (teleport)
- Feel: Hyperactive. Running, dashing, shooting fast, chaining hits. BPM matters — miss and you lose momentum.
- Combo: Overclock (6 shots/sec) + Tempo Round (combo counter) = escalating damage at high speed

### SHOCK — "Chain reaction through the room."
- Firing: Volt (chain 1), Arc (chain 2), Static (shock status)
- Spells: Chain Lightning (bounce 3), EMP Blast (shock all + stun), Spotter (mark for +30% dmg)
- Feel: One shot hits many. Crowd control. Chain reactions cascade.
- Combo: EMP Blast (shock all) → Chain Lightning (bounces everywhere) → Mark + Shock = Overload (explosions)

### NEUTRAL — "I adapt to whatever I find."
- Firing: Standard (baseline), Piercing (utility), Ricochet (utility), Drain (heal)
- Spells: Barrier (shield), Vampiric Burst (lifesteal), Reload Surge (instant reshuffle)
- Feel: Flexible. Fill gaps in any build. Never exciting alone but always useful.

---

## CROSS-PLAYSTYLE SYNERGIES (the "1+1>2" discoveries)

These are the magic moments when a player combines cards from DIFFERENT playstyles:

| Cards combined | From | Discovery |
|---|---|---|
| Venom Round + Incendiary Round + Detonator | VENOM + BLAZE | Toxic Fire: Detonator does 6x instead of 3x on burning+poisoned target |
| Fuel + Venom Round | BLAZE + VENOM | Venom bullets now also apply Burn. Double status from one card. |
| Overclock + Toxic Needle | FLUX + VENOM | 6 shots/sec × 3 stacks/hit = 18 stacks/sec. Insane stacking speed. |
| Overclock + Heavy Round | FLUX + POWER | 6 shots/sec × 15 dmg = 90 DPS raw damage. No status needed. |
| War Cry + any firing card | POWER + any | +50% damage to everything for a full magazine. Universal amplifier. |
| Phase Dash + Explosive Round | FLUX + POWER | Dash into enemies → AoE explosions point blank. Aggressive mobility. |
| Fuel + Volt Round | BLAZE + SHOCK | Volt bullets now also apply Burn. Chain lightning spreads fire. |
| Pandemic + EMP Blast | VENOM + SHOCK | Spread poison to all → shock all → Contagion combo (execute spreads further) |
| Adrenaline + Drain Round | FLUX + NEUTRAL | Move fast + heal on every hit = mobile sustain tank |
| Megashot + Headhunter Round | POWER + POWER | 5x damage on next shot × 3x headshot = 15x damage one bullet. One-shot anything. |

---

## STARTER DECK (9 cards, unchanged)

- 3x Standard Round (F17, neutral firing)
- 1x Venom Round (F5, venom firing)
- 1x Incendiary Round (F8, blaze firing)
- 1x Piercing Round (F18, neutral firing)
- 1x Detonator (S5, venom function)
- 1x Barrier (S18, neutral function)
- 1x Flashfire (S8, blaze function)

Starter deck deliberately includes cards from 3 playstyles (Neutral, Venom, Blaze) so the player experiences variety immediately.

---

## CARD OFFERING LOGIC

Between waves, offer 3 cards. Rules:
- Never offer Standard Round
- At least 1 firing and 1 function in each offering of 3
- Weight toward cards from playstyles the player is already building into (soft guidance)
- Occasionally offer a cross-playstyle card to spark discovery
- Show playstyle icon + card type icon (gun/spell) on each card

---

## NOTES

- 40 cards total. Gate 1 implements 7 (starter set). Gate 2 adds ~8-12 more. Full pool by v0.5.
- Playstyles are NOT classes. Player doesn't pick one at start. They emerge through card picks.
- Cross-playstyle combos are the depth layer. Pure single-playstyle decks work but mixed decks can be stronger.
- Numbers are all draft. Balance through playtesting.
- Flux playstyle needs the fire rate increase (3 shots/sec base) to feel distinct from other playstyles.

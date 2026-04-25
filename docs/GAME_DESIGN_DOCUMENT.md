# GP1 — Game Design Document
### Version: 2026-04-25 (post two-hand system)
### Status: Single source of truth. All other docs are history/context.

---

## 1. OVERVIEW

**FPS roguelite deckbuilder.** Your deck is your magazine. Right hand fires card-packs (bullet bursts with effects). Left hand casts function cards (spells). Build your deck between waves. Status combos create 1+1>2 synergies.

**Core design philosophy:** Stack-then-Execute (叠层后斩杀). Apply status stacks → trigger a finisher spell → massive burst damage.

---

## 2. TWO-HAND SYSTEM

### Right Hand — Gun (Firing Cards)
- Fires card-packs: each card = a burst of bullets with the same effect
- Continuous fire, semi-auto (~2 shots/sec for revolver)
- 6 card-pack magazine
- Color-coded: muzzle flash, bullet trails, crosshair tint, hit effects all match card color
- REACTIVE — player responds to whatever card pack comes up

### Left Hand — Spell (Function Cards)
- Holds up to 3 function cards
- Player triggers the active spell deliberately
- One-time effects: execute, shield, dash, area setup, etc.
- Consumed on use. When all 3 are consumed, hand is empty until reload.
- PROACTIVE — player chooses when and where to trigger

### Controls
| Action | Input |
|---|---|
| Fire gun | Left Click (semi-auto) |
| Aim down sights (ADS) | Right Click (hold) |
| Trigger spell | F key |
| Reload (both hands) | R key |
| Move | WASD |
| Sprint | Shift (hold) |
| Jump | Space |
| Crouch | Ctrl (toggle) |

Spells auto-advance: after using a spell, the next unconsumed spell becomes active. No manual cycling needed. Player just presses F when ready.

### Deck Structure
- ONE shared deck containing both firing cards and function cards
- On reload: deck shuffles → firing cards load into gun (top 6) → function cards load into spell hand (top 3)
- Remaining cards wait for next reload
- Reload reshuffles BOTH hands (R reloads everything)
- Reload mid-pack: remaining bullets in current pack WASTED

### Edge Cases
- 0 function cards in deck: spell hand is empty. Valid but suboptimal.
- 0 firing cards in deck: impossible. Minimum 3 Standard Rounds always in deck (cannot be removed).
- Unbalanced deck (e.g., 9 firing + 1 function): gun full, spell hand has 1 card and 2 empty slots.

---

## 3. WEAPON: REVOLVER (Gate 1)

| Stat | Value |
|---|---|
| Fire rate | ~3 shots/sec (semi-auto, click per shot) |
| Magazine | 6 card packs |
| Bullets per pack | 6 (except Detonator: see spell) |
| Reload time | 2 seconds |
| Base bullet damage | 8 |
| ADS FOV | 75 (from 90) |
| ADS move speed | 60% of walk (3 m/s) |
| ADS transition | 0.1 seconds |
| Spread | 0 (still or ADS), +1 degree (moving hip-fire) |

---

## 4. CARDS — GATE 1 SET (7 cards)

### Firing Cards (right hand)

| Card | Bullets | Dmg | Color | Effect | Role |
|---|---|---|---|---|---|
| Standard Round | 6 | 8 | White | None | Baseline |
| Venom Round | 6 | 6 | Green | +2 poison stacks per hit | Enabler: Poison |
| Incendiary Round | 6 | 8 | Orange | Burn (+20% dmg taken, 5 sec, refreshes) | Enabler: Burn |
| Piercing Round | 6 | 8 | Blue | Passes through first target | Utility |

### Function Cards (left hand)

| Card | Color | Effect | Consumed? | Role |
|---|---|---|---|---|
| Detonator | Purple | Hitscan raycast (same as gun). On hit: consumes ALL poison stacks, bonus dmg = 3x stacks. Base damage = 0 (bonus only). Consumed on CAST (miss = wasted). Range = infinite (same as gun). Must aim and hit. | Yes | Payoff: Poison execute |
| Barrier | Cyan | Grants 30 HP shield for 5 sec. Instant, no aiming required. | Yes | Defensive |
| Flashfire | Orange-Red | All enemies within 10m get Burn status. Instant, no aiming required. | Yes | Setup: area Burn |

### Starter Deck (9 cards)
- 3x Standard Round (firing)
- 1x Venom Round (firing)
- 1x Incendiary Round (firing)
- 1x Piercing Round (firing)
- 1x Detonator (function)
- 1x Barrier (function)
- 1x Flashfire (function)

On first shuffle: 6 firing → gun, 3 function → spell hand. Perfect fit.

---

## 5. STATUS EFFECTS

### Gate 1 Statuses

| Status | Applied by | Effect | Duration | Visual |
|---|---|---|---|---|
| Poison | Venom Round hits | Stacks. No decay. Consumed by Detonator for burst (3x stacks as bonus dmg). | Until consumed or combat ends | Green glow + stack number |
| Burn | Incendiary Round, Flashfire | +20% damage from ALL sources | 5 sec, refreshes on hit | Orange flame particles |

### Status Combo (Gate 1)

| Combo | Trigger | Effect | Visual |
|---|---|---|---|
| Toxic Fire | Enemy has Poison AND Burn when Detonator hits | Detonator bonus = 6x stacks instead of 3x | Green-orange burst + "TOXIC FIRE" text popup |

### Future Statuses (Gate 2+)
- Slow (Frost Round) — -50% move speed
- Shock (Volt Round) — chains to nearby enemy
- Mark (Spotter spell) — +30% damage taken

### Future Status Combos (Gate 2+)
- Poison + Shock = Contagion (execute spreads)
- Burn + Slow = Meltdown (burn ticks 2x)
- Shock + Mark = Overload (explodes on death)
- Slow + Poison = Festering (+3 stacks/hit)

---

## 6. PLAYER

| Stat | Value |
|---|---|
| HP | 150 |
| Walk speed | 5 m/s |
| Sprint speed | 8 m/s |
| Crouch speed | 3 m/s |
| Jump velocity | 7 m/s (~1.2m height) |
| Gravity | 20 m/s² |
| Ground accel/decel | 80 m/s² |
| Air accel | 30 m/s² |
| Air decel | 20 m/s² |
| Air control | 60% |
| Coyote time | 0.1s |
| Jump buffer | 0.1s |
| Heal on kill | 10 HP |
| Between-wave heal | 25 HP |

### Damage feedback
- Red screen flash on hit
- Camera flinch: 2-4 degrees, 0.15s recovery
- Heartbeat sound below 30 HP

---

## 7. ENEMIES — GATE 1

| Enemy | HP | Speed | Range | Damage | Behavior | Visual |
|---|---|---|---|---|---|---|
| Grunt | 30 | Medium | 10-15m | 3/shot, ~1/sec | Walks toward player, shoots visible projectiles. Projectile speed: 15 m/s (dodgeable). | Dark red capsule + gun mesh |
| Big Eye | 100 | Slow | 20-30m | 20 charged beam (telegraphed) | Stands back, 1.5 sec charge-up (visible glow), fires beam projectile. Beam speed: 20 m/s. Weak spot = eye. | Large purple sphere (1.5m), pulsing eye, floats 0.5m |
| Rusher | 20 | 9 m/s | 0-5m | 10 melee, ~1/sec | Sprints at player, melee attack with visible wind-up (0.5 sec). | Small/wide bright orange, leaning forward |

### Enemy projectile requirements
- **ALL enemy ranged attacks must be visible projectiles** (not hitscan)
- Grunt: fires a glowing red bullet, visible in flight, 15 m/s speed (player can strafe to dodge)
- Big Eye: fires a large purple beam projectile, 20 m/s, with 1.5 sec charge-up telegraph (glowing eye + audio cue)
- Projectiles must have distinct color from player card colors (enemy = red/dark tones, player = card colors)
- Projectile size: large enough to see at 20-30m distance

### Enemy attack speed note
Enemy projectiles should be SLOW enough that an aware player can dodge by strafing. This rewards movement skill and creates a "bullet hell lite" feel at higher wave counts.

### Other enemy requirements
- All enemies have floating HP bars (visible after taking damage)
- Status effects (poison glow, burn flames) must be large and obvious on enemies

### Enemy UI — Floating Display (above each enemy)

Every enemy must have a billboard UI display floating above their head. This is critical for players to make informed card decisions (e.g., "that enemy has high poison stacks, I should Detonator it").

**Health bar:**
- Position: 0.3m above enemy top
- Width: 1.2m (world space), height: 0.1m
- Background: dark gray (0.2, 0.2, 0.2)
- Fill: red, scales with HP percentage (left to right)
- Hidden at full HP. Appears after first damage taken.
- Always faces camera (billboard)

**Poison stack display:**
- Position: above HP bar, left side
- Green number showing current stack count (e.g., "12")
- Font: large, bold, black outline for readability at distance
- Green poison icon (circle or droplet) next to the number
- Hidden when stacks = 0
- Scales up briefly when stacks increase (juice: number pops +20% size for 0.1s then returns)

**Burn indicator:**
- Position: above HP bar, right side (next to poison if both active)
- Orange flame icon
- Text: "BURN" or flame emoji/icon
- Hidden when not burning
- Pulses while active (opacity oscillates 0.8-1.0)

**Status combo indicator:**
- When a status combo is active (e.g., Toxic Fire = poison + burn simultaneously):
- Show combo name above all other indicators: "TOXIC FIRE" in orange-green gradient text
- Brief flash on activation (scales up 150% over 0.2s, returns to 100%)
- Unique color per combo type

**Layout (top to bottom):**
```
[TOXIC FIRE]          ← combo name (only when active)
[🔥 BURN] [💧12]     ← status icons + poison stacks
[████████░░░░]        ← HP bar
     Enemy            ← enemy mesh below
```

**Visibility rules:**
- HP bar: hidden at full HP, visible after any damage
- Poison: hidden at 0 stacks
- Burn: hidden when not burning
- Combo name: only visible when combo condition is met
- All elements billboard toward camera at all times
- All elements must be readable at 20-30m distance (scale with distance or use fixed screen-space size)

---

## 8. WAVES & STRUCTURE

### Endless wave loop
Waves continue indefinitely until the player dies. No fixed end point. Each wave gets progressively harder (more enemies, tougher compositions). Card selection between every wave gives the player a growing deck.

### Wave scaling
| Wave | Enemies | Purpose |
|---|---|---|
| 1 | 3 Grunts | Learn to shoot, experience card transitions |
| 2 | 2 Grunts + 1 Big Eye | Stack poison on sponge, test Detonator timing |
| 3 | 1 Big Eye + 4 Rushers + 2 Grunts | Pressure test, all enemy types |
| 4+ | Scaling: +1-2 enemies per wave, mix of all types | Increasing difficulty, deck must grow to keep up |

### Scaling rules (wave 4+)
- Each wave adds 1-2 more enemies than the previous
- Enemy HP scales +10% per wave after wave 3
- Enemy composition randomizes from all 3 types
- Player deck grows by 1 card per wave (picks between every wave)

### Death = run over
- Player dies → death recap screen (waves survived, enemies killed, cards collected, highest combo)
- Restart from wave 1 with starter deck
- Goal: survive as many waves as possible, build the strongest deck you can

### Between EVERY wave
1. "WAVE X CLEARED" text (3 sec)
2. Breathing room — see HP, deck state (3 sec)
3. Card selection: pick 1 from 3 (mixed firing + function pool). Card type (gun/spell icon) shown.
4. Heal 25 HP
5. Wave countdown (3 sec)
6. Grace period (0.5s invulnerability)

### Card selection rules
- Never offer Standard Round
- Show card type icon (gun or spell) clearly
- Show current deck composition during selection
- Deck grows by 1 every wave (wave 2 = 10, wave 3 = 11, wave 10 = 18, etc.)

---

## 9. VISUAL FEEDBACK

### Gun (firing cards) — diegetic, no HUD reading
| Element | Behavior |
|---|---|
| Crosshair tint | Matches current card color |
| Muzzle flash | Card color |
| Bullet trail | Card color |
| Hit effect | Card color |
| Card transition | Visible color shift, subtle sound cue |
| Weapon model | Cylinder shows colored rounds, rotates on fire |

### Spells (function cards) — left side UI
| Element | Behavior |
|---|---|
| 3 card icons | Left side of screen, vertically stacked |
| Active spell | Highlighted/enlarged |
| Consumed spell | Grayed out |
| Cast feedback | Left-hand glow/particle + unique sound per spell type |

### Status effects on enemies
| Status | Visual |
|---|---|
| Poison | Green glow, intensity scales with stacks, floating stack number (large, bold, black outline) |
| Burn | Orange flame particles, large and bright |
| Status combo | Unique VFX + on-screen text popup ("TOXIC FIRE") + unique sound |

### Player feedback
| Event | Visual + Audio |
|---|---|
| Fire gun | Heavy revolver crack, recoil kick (3 deg), weapon viewmodel kick |
| Hit enemy | Hit marker (crosshair expand + tick marks) + thwack sound |
| Kill enemy | X marker + kill sound + screen flash |
| Take damage | Red flash + camera flinch + grunt sound |
| Low HP | Heartbeat + red vignette |
| Reload | Cylinder open/close animation + mechanical sounds |
| Spell cast | Left-hand animation + spell-specific VFX + spell-specific sound |
| Detonator hit | Large purple burst + screen flash + "BOOM" feedback |

---

## 10. ARENA (Gate 1)

- Rectangular space with cover (waist-high walls, pillars)
- Verticality (raised platforms, ramps)
- 20-30m sightlines for Big Eye
- Tight corners for Rusher encounters
- Material variety: dark floor, medium walls, brownish cover, blueish pillars
- Emissive strips on cover tops for readability

---

## 11. CAMERA

- FOV: 90 (75 ADS)
- No head bob, no motion blur, no chromatic aberration
- Recoil: 3 degree pitch kick, 0.15s recovery
- No screen shake by default (test small shake in playtesting)
- Strafe roll: ±1.5 degrees
- Damage flinch: 2-4 degrees, 0.15s recovery
- Mouse look: raw input, no smoothing, no acceleration, ±85 degree pitch clamp
- Camera follows character 1:1, no interpolation
- Yaw on character body, pitch on camera node
- During reload: full look control maintained
- During card selection: can look around, cannot fire/move, mouse cursor visible

---

## 12. CARD ACQUISITION & DECK RULES

- Pick 1 from 3 between waves (mixed pool of firing + function)
- Cards can have duplicates (1-2 copies max)
- Standard Rounds cannot be removed (minimum 3 always in deck)
- Deck thinning: TBD for Gate 2 (between waves: burn 1 card OR pick 1 card)
- No meta-progression for Gate 1 (future: card unlocks, extraction)

---

## 13. WHAT'S NOT IN GATE 1

These are designed or discussed but NOT built yet:

- Extraction mechanic (v0.5)
- Meta-progression / card unlocks (v0.5)
- Additional weapons (Rifle, SMG, Shotgun with primal perks) (Gate 3+)
- Slow, Shock, Mark statuses (Gate 2)
- Status combos beyond Toxic Fire (Gate 2)
- Additional firing cards: Frost, Volt, Ricochet, Scatter, Drain, Overcharge, Catalyst, Resonance (Gate 2-3)
- Additional function cards: Chain Lightning, Purge, Spotter, Toxin Bomb, Phase Step, Vampiric Burst, Overclock, Infusion, Reload Surge (Gate 2-3)
- Additional enemies: Sniper, Shield Bearer, Bomber (Gate 2)
- Status-resistant enemies (Gate 2)
- Boss design (v0.5)
- Room/level variety (v0.5)
- Perk/relic system (v0.5)
- Deck thinning mechanic (Gate 2)
- Death recap screen (Gate 2)
- Ascension/difficulty modifiers (v0.5)

---

## 14. PASS CRITERIA (Gate 1)

1. Can the player tell which card mode they're in from color alone?
2. Does the two-hand system feel intuitive? (Gun fires, F casts spell, no confusion)
3. Does Venom stack → Detonator burst produce a satisfying 叠层后斩杀 moment?
4. Does Toxic Fire (Poison + Burn + Detonator) feel like a genuine "1+1>2" discovery?
5. Does reload-as-sacrifice feel like a real decision?
6. Can the player dodge enemy projectiles through movement? (Are projectiles visible and slow enough?)
7. Does the endless wave loop create "one more wave" motivation?
8. Does the player want to play again immediately after dying?

---

## 15. REFERENCE DOCUMENTS

| Document | Purpose | Status |
|---|---|---|
| docs/ONE_PAGER.md | Quick pitch | Current |
| docs/GAME_DESIGN_DOCUMENT.md | THIS FILE — single source of truth | Current |
| docs/3C_DOCUMENT.md | Detailed character/camera/controls | Needs update for two-hand inputs |
| docs/CARD_POOL_DRAFT.md | Full 24-card pool (future cards) | Current |
| GATE1_BUILD_SPEC.md | Old build reference | SUPERSEDED by this document |
| devlogs/ | Design history and audits | Context only |

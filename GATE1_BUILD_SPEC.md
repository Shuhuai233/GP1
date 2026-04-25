# GP1 — Gate 1 Build Reference (SUPERSEDED)

**⚠️ THIS DOCUMENT IS OUTDATED. It predates the two-hand system (2026-04-25).**
**⚠️ See `docs/GAME_DESIGN_DOCUMENT.md` for the current single source of truth.**

*Original generation date: 2026-04-22.*

---

## The Game

**FPS roguelite deckbuilder.** Your deck is your magazine. Each card is a pack of bullets with an effect. Reload reshuffles your deck. Build a powerful deck through combat rewards. Extract to keep your build. Die and lose everything.

**Hook:** "Your deck is your magazine. Each shot fires a card."

**Core design philosophy:** Stack-then-Execute (叠层后斩杀). Apply status stacks with sustained fire, then trigger a finisher card that consumes all stacks for massive burst damage.

---

## Gate 1 Scope

Single arena room, 1 weapon, 5 card types, 3 enemy types, 3 waves, card selection between waves. Goal: prove the card-pack system feels good.

---

## Weapon: Revolver

| Stat | Value |
|---|---|
| Fire rate | ~2 shots/sec |
| Magazine | 6 card packs |
| Reload time | 2 seconds |
| Base bullet damage | 8 |

**Loading rule:** Shuffle all cards in deck → load first 6 into magazine → remaining cards wait for next reload.

---

## Cards

| # | Card | Bullets/pack | Dmg/bullet | Effect | Color |
|---|---|---|---|---|---|
| 1 | Standard Round | 6 | 8 | None | White |
| 2 | Venom Round | 6 | 6 | +2 poison stacks per hit | Green |
| 3 | Incendiary Round | 6 | 8 | Burn: target takes +20% dmg, 5 sec, refreshes on hit | Orange |
| 4 | Piercing Round | 6 | 8 | Bullet passes through first target | Blue |
| 5 | Detonator Round | 3 | 8 | First hit on poisoned target consumes ALL stacks, bonus = 3x stacks | Purple |

All packs = 6 bullets (~3 sec at 2/sec) except Detonator = 3 bullets (~1.5 sec). Power costs economy.

---

## Status Effects

### Poison
- +2 stacks per Venom bullet hit
- Stacks do NOT decay during combat (persist until Detonator consumes them or combat ends)
- Detonator: first hit consumes ALL stacks, bonus damage = 3x stack count
- Visual: green glow on enemy, intensity scales with stacks, floating stack number

### Burn
- Target takes +20% damage from ALL sources
- Duration: 5 seconds, refreshed on each Incendiary hit
- Visual: orange flame particles on enemy

---

## Starter Deck (6 cards)

- 3x Standard Round
- 1x Venom Round
- 1x Incendiary Round
- 1x Piercing Round

---

## Deck & Magazine Rules

- Deck can grow larger than magazine (6 slots)
- On reload: shuffle entire deck, load top 6 into magazine
- Remaining cards wait for next reload
- Reload mid-pack: remaining bullets in current pack WASTED, full deck reshuffles
- Card packs consumed on fire regardless of accuracy (miss = wasted bullets)

---

## Player

| Stat | Value |
|---|---|
| HP | 150 |
| Movement | Walk + sprint + jump (standard FPS) |
| Dash/dodge | None for Gate 1 |
| Heal on kill | 10 HP per enemy killed |
| Between-wave heal | 25 HP flat |

---

## Enemies

| Enemy | HP | Speed | Range | Damage | Behavior |
|---|---|---|---|---|---|
| Grunt | 30 | Medium | 10-15m | 3 dmg/shot, ~1/sec | Walks toward player, shoots |
| Big Eye | 100 | Slow | 20-30m | 20 dmg charged beam (telegraphed) | Stands back, fires beam. Weak spot = eye |
| Rusher | 20 | Fast | 0-5m | 10 dmg melee, ~1/sec | Sprints at player, melee |

---

## Waves

| Wave | Enemies | Purpose |
|---|---|---|
| 1 | 3 Grunts | Learn to shoot, experience card transitions |
| 2 | 2 Grunts + 1 Big Eye | Learn poison stacking on sponge target |
| 3 | 1 Big Eye + 4 Rushers + 2 Grunts | Pressure test |

Between waves: 10-15 sec pause → pick 1 from 3 random cards → card added to deck.

Deck grows: wave 2 start = 7 cards, wave 3 start = 8 cards. Magazine still holds 6.

---

## Visual Feedback (Diegetic — No HUD Reading)

| Element | How it communicates |
|---|---|
| Crosshair tint | Primary signal — colored to match current card |
| Muzzle flash | Color matches card |
| Bullet trail | Color matches card |
| Hit effect | Color matches card |
| Card transition | Visible color shift moment |
| Poison stacks | Green glow + floating number on enemy |
| Burn | Orange flame particles on enemy |
| Backup HUD | Small card icon near crosshair |

**Design rule:** During combat, the player SEES information through color and effects. They never READ information off a HUD panel.

---

## Arena

- Rectangular space with cover (waist-high walls, pillars)
- Some verticality (raised platforms, ramps)
- 20-30m sightlines for Big Eye range
- Tight areas for Rusher encounters

---

## Pass Criteria

1. Can the player tell which card mode they're in from color alone?
2. Does the ~3 sec card-pack pace feel right?
3. Does Venom stack → Detonator burst produce a satisfying "aha" moment?
4. Does reload-as-sacrifice feel like a real decision?
5. Does the player want to play again immediately?

---

## Key Design Context (for the builder)

- **Card packs, not single bullets.** 1 card = 6 bullets (or 3 for Detonator). Card "mode" lasts ~3 seconds. This is based on cognitive science — humans need ~1.5-2.5 sec to notice a color change, react, and play around it.
- **Reload = reshuffle.** Not just a reload animation — it's reshuffling your deck. Mid-pack reload wastes remaining bullets. This makes reload a real decision.
- **Non-bullet effects (heal, shield, dash) are NOT in the magazine.** They'll be a separate perk/relic system later. For Gate 1, magazine is offensive cards only.
- **Random shuffle order.** Player doesn't control card sequence. They react to what comes up. Progression-unlocked deck control (pinning, peeking, cycling) is a future feature.
- **Enemy range differentiation forces different strategies.** Grunt = medium, Big Eye = long (stack target), Rusher = close (panic target).
- **The "aha moment" to engineer:** Player stacks 10+ poison on Big Eye with Venom rounds across multiple reloads → Detonator comes up → they aim carefully → BOOM, 30+ bonus damage. Big Eye melts. Player thinks "I want to do that again."

---

## Design Docs

Full design history and audit are in:
- `devlogs/2026-04-22.md` — design decisions and evolution
- `devlogs/2026-04-22-design-audit.md` — game-designer review, risks, resolved blockers

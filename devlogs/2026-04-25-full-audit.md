# Full Design Audit: 2026-04-25

## Scope
Comprehensive audit of ALL design documents, covering 12 areas. Performed after the two-hand system evolution and 24-card pool draft.

---

## Verdicts by Area

| # | Area | Verdict |
|---|---|---|
| 1 | Internal Consistency | Contradictory — build spec outdated, multiple documents disagree |
| 2 | Two-Hand System | Has Issues — reload behavior, empty-hand edge cases, input scheme undefined |
| 3 | Card Pool Balance | Has Issues — Catalyst possibly broken, Purge underpowered, Scatter ambiguous, Overcharge is a noob trap |
| 4 | Synergy Depth | Has Issues — combos invisible to player, no anti-synergies, 5 statuses may overwhelm |
| 5 | Economy & Pacing | Has Issues — no deck thinning, large decks dilute key cards, pick rate may be too slow |
| 6 | Combat Feel | Has Issues — 8 cognitive channels, 18 sec magazine may be long, reload is death sentence vs Rushers |
| 7 | Enemy Interaction | Critical Gap — enemies are HP bags, no status resistance, no deck interference |
| 8 | UX & Information | Has Issues — 14+ info channels, color collisions, combo feedback undefined |
| 9 | Progression & Replayability | Critical Gap — no meta-progression, no unlocks, no death recap |
| 10 | Scope & Feasibility | Has Issues — 24 cards too many for Gate 2, minimum viable is 9-11 |
| 11 | Missing Design Areas | Critical Gap — audio, combo VFX, card selection UX, boss, rooms, extraction, relics all undefined |
| 12 | Build Spec Outdated | Blocker — spec describes a game that no longer exists |

---

## Top 15 Issues Ranked by Priority

| # | Severity | Issue |
|---|---|---|
| 1 | Blocker | Build spec is outdated — describes a game that no longer exists. Code matches old spec. |
| 2 | Blocker | Reload behavior for both hands undefined. Does reload reshuffle spell hand? Spells during reload? |
| 3 | Blocker | Spell input scheme not decided. No key bindings for cycle/trigger/targeting. |
| 4 | Blocker | Status combo feedback undefined. No visual/audio/text for any of the 5 combos. |
| 5 | Blocker | Scatter Round "applies status" is ambiguous. Which status? Key card is undefined. |
| 6 | Concern | Spell hand starvation at extreme deck compositions. 0 function cards = empty left hand. |
| 7 | Concern | Catalyst Round may be broken. +1 ALL stacks/hit x 6 hits = exponential scaling. |
| 8 | Concern | No deck thinning. 3 Standard Rounds dilute synergy forever. |
| 9 | Concern | Two-input cognitive load. 8 channels during wave 3. Needs mitigation. |
| 10 | Concern | Purge is underpowered vs Detonator. Multi-status build inferior to Poison Execute. |
| 11 | Concern | Enemies don't interact with card system. No resistances or deck interference. |
| 12 | Concern | Color collisions. Cyan, Blue-White, Dark Red, Gold, White used for 2+ cards. |
| 13 | Concern | Detonator too reliable as spell. No miss risk removes FPS skill from core payoff. |
| 14 | Nit | Overcharge is a noob trap. 50 total dmg vs Standard's 48, zero synergy. |
| 15 | Nit | No meta-progression. Fine for Gate 1 but needs death recap at minimum. |

---

## Specific Balance Concerns

### Catalyst Round — possibly broken
+1 to ALL active stacks per hit. 6 bullets per pack. If enemy has Poison(10) + Slow:
- 6 Catalyst hits = Poison goes from 10 to 16, Slow stacks go up too
- With Scatter Round (3 pellets): 3 x 6 = 18 hits = +18 to all stacks
- This scales exponentially with number of statuses applied

### Purge — dramatically underpowered
10 dmg per status type removed. Best case: 5 statuses = 50 bonus dmg.
Meanwhile Detonator on 20 poison stacks + Toxic Fire = 6 x 20 = 120 bonus dmg.
Purge is 2.4x weaker than Detonator at realistic stack counts. Multi-status build has no reason to exist.

Fix: Purge should scale with total STACKS not just status count. E.g., 3 dmg per total stack across all statuses. 20 poison + 5 burn ticks + slow = 25+ total stacks = 75+ dmg.

### Detonator — too reliable as spell
As a function card, player aims crosshair at target and triggers. No miss chance, no bullet travel, guaranteed consume. This removes FPS skill from the most important moment.

Fix: Detonator should still require hitting the target. Make it fire a single special projectile that must connect. Miss = wasted spell. Now aim skill matters for the 叠层后斩杀 moment.

### Overcharge Round — noob trap
2 bullets x 25 dmg = 50 total damage per pack. Standard Round: 6 bullets x 8 dmg = 48 total. Only 4% more damage, zero status synergy, half the hits (bad for Catalyst, bad for stack building). No experienced player would take this.

Fix: Either raise damage substantially (2 x 40 = 80) or add a unique mechanic (ignore armor, guaranteed stagger, AoE on impact).

### Scatter Round — ambiguous
"3 pellets per shot, each applies status" — WHICH status? The current card's status? The previously applied status? Its own status? This is the key card for stack acceleration builds but its core mechanic is undefined.

Fix: Clarify as "3 pellets per shot, each pellet triggers the same card effect as the PREVIOUS firing card in the magazine." This means: fire Venom Round (applies poison), then Scatter Round (each pellet applies +2 poison stacks). The order matters.

Wait — but Scatter Round IS a firing card with its own pack. It doesn't fire "after" another card; it fires as its own pack. So the pellets should apply Scatter's own damage (4 per pellet) and nothing else unless Scatter has its own status. Need to decide: does Scatter Round have a status effect, or is it purely a multi-hit utility card?

Simplest fix: Scatter Round = 3 pellets x 4 dmg each, no status. Pure multi-hit utility. Synergy: if enemy already has Burn, each pellet benefits from +20% amp. Value comes from hitting burning enemies 3x per shot.

---

## Edge Cases for Two-Hand System

### Empty hand scenarios
- Deck with 0 function cards: spell hand is permanently empty. Player has gun only. Functionally reverts to old system. Is this a valid build or a bug?
- Deck with 0 firing cards: gun is empty. Player only has spells. Can they fight? Probably not — spells are consumed, no sustained damage.
- Deck with 1 function card: spell hand loads 1 of 3 slots. What do empty slots show? Grayed out? Hidden?

Recommendation: Minimum 3 firing cards in deck at all times (Standards can't be removed). Function cards have no minimum — 0 spells is a valid (if suboptimal) choice.

### Reload reshuffle scope
Option A: Reload reshuffles BOTH hands. All consumed spells return. Full reset.
- Pro: Clean, predictable. Player always gets full hands.
- Con: Spells feel less "consumed" if they come back every 18 seconds.

Option B: Reload reshuffles gun only. Spell hand is separate — consumed spells are gone until ALL spells are consumed, then spell hand reshuffles independently.
- Pro: Spells feel more precious. Timing spell use matters more.
- Con: Complex. Player tracks two separate reshuffle cycles.

Option C: Reload reshuffles gun. Spell hand reshuffles when empty (all 3 consumed).
- Pro: Compromise. Spells are precious within a cycle, but cycle eventually.
- Con: If player uses 2 of 3 spells, the third sits alone until they use it.

Recommendation: Option A for Gate 1 (simplest). Test if spells feel "too free" at 18-second refresh. Tighten to Option C if needed.

---

## Recommendations by Phase

### Phase 1: Fix documentation (before any building)
1. Rewrite GATE1_BUILD_SPEC to v2 with two-hand system, all current decisions
2. Decide: spell input keys, reload scope, spell targeting model
3. Mark all pre-two-hand docs as superseded

### Phase 2: Fix what's built (3C, audio, navmesh)
4. Implement all P0 3C fixes
5. Add placeholder audio
6. Bake NavMesh

### Phase 3: Implement two-hand system
7. Deck sort on reload (firing → gun, function → spell)
8. Spell hand UI (3 slots, auto-advance)
9. Spell triggering (decided input)
10. Detonator, Barrier, Flashfire as spells
11. 9-card starter deck

### Phase 4: Playtest two-hand system
12. Test with players. Key: Is spell hand intuitive? Is cognitive load ok?
13. Tune magazine size, reload time, spell count based on results

### Phase 5: Prepare for Gate 2
14. Design combo VFX/audio placeholders
15. Clarify Scatter Round
16. Rebalance Purge and Overcharge
17. Design deck thinning mechanic
18. Add 2-3 more cards for second synergy path
19. Add 1 status-resistant enemy

---

## The Single Biggest Risk
There is no up-to-date specification. Build spec, devlogs, card pool, and code all describe different versions of the game. Until one document is the truth, everything is built on sand.

## The Single Biggest Strength
The core insight is genuinely original. "Deck is your magazine" + two-hand system (reactive gun + proactive spells) + status combos + diegetic color feedback. No competitor occupies this design space. The vision is clear and well-researched. The documentation just needs to catch up.

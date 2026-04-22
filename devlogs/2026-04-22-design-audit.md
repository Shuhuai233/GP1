# Design Audit v2: 2026-04-22 — Updated After Design Evolution

## What changed since Audit v1

The design has evolved significantly through conversation. Key shifts:

1. **Card = bullet pack** (not 1:1). Each card provides X bullets all carrying the same effect. Solves the pacing vs readability tension.
2. **Fast pacing preserved.** SMG, rifle, shotgun all fire at real FPS speeds. Cards cycle every ~2 seconds regardless of weapon fire rate.
3. **Diegetic visibility decided.** Screen-wide color language (muzzle flash, trails, crosshair tint, hit effects) communicates current card mode. No HUD reading during combat.
4. **Cognitive science timing.** ~1.5-2.5 sec per card pack is backed by human visual processing data (color ID ~150ms, aim adjustment ~500ms, tactical choice ~1-2 sec).
5. **No specific cards designed yet.** The 20 speculative cards from earlier brainstorming have been removed. Card archetypes, specific effects, and synergies are all TBD.
6. **4 weapons defined:** Revolver (6 cards, ~2/sec), Rifle (6 cards, ~5/sec), SMG (6 cards, ~8/sec), Shotgun (4 cards, ~1.5/sec).

---

## Updated Verdicts by Area

| # | Area | Previous | Current | What changed |
|---|---|---|---|---|
| 1 | Core Loop | Needs Work | Needs Work | Card-pack model clarifies micro-loop. Meso/macro loops still missing. |
| 2 | Player Fantasy | Critical Gap | Critical Gap | No change — still undefined. |
| 3 | Onboarding | Needs Work | Improved | Color language + card packs make the system more self-teaching. Still needs explicit plan. |
| 4 | Card System | Needs Work | Needs Work | Card-pack model is a major structural advance. But zero specific cards exist. Effect categories undefined. |
| 5 | Weapon System | Strong | Strong | Card-pack model strengthens this — all 4 weapons now have clear identities at consistent ~2 sec card pace. |
| 6 | Economy & Progression | Critical Gap | Critical Gap | No change. |
| 7 | Extraction Mechanic | Critical Gap | Critical Gap | No change. |
| 8 | Enemy Design | Critical Gap | Critical Gap | No change. |
| 9 | Level/Room Design | Critical Gap | Critical Gap | No change. |
| 10 | Difficulty & Balance | Needs Work | Needs Work | No change. |
| 11 | UX & Feel | Needs Work | Improved | Q7 answered: diegetic color language, no HUD reading during combat. Major progress. |
| 12 | Narrative & World | Needs Work | Needs Work | No change. |
| 13 | Monetization & Scope | Needs Work | Needs Work | No change. |
| 14 | Competitive Differentiation | Strong | Stronger | Card-pack model + fast pacing is even more differentiated. Nobody has this. |
| 15 | Risks & Failure Modes | Needs Work | Partially Addressed | Biggest risk (imperceptible cards at FPS speed) is directly mitigated by card-pack model + color language. |

---

## What's been resolved since v1

### RESOLVED: "Per-shot card system imperceptible at FPS speed"
This was the #1 risk. Card-pack model means cards don't cycle per bullet — they cycle every ~2 seconds. Player has time to notice, react, and play around each card mode. Color language makes identification ambient, not reading-dependent.

**New Gate 1 test:** Can the player tell which card MODE they're in from the visual language alone (no HUD reading)? This is a much more answerable question than "can they track individual bullets."

### RESOLVED: "SMG/fast weapons break the card system"
Card packs normalize card duration across all fire rates. SMG fires 15-20 bullets per card pack, revolver fires 3-5, but both spend ~2 seconds per card.

### RESOLVED: "HUD information overload"
Diegetic color language replaces HUD icons. During combat: muzzle flash color + bullet trails + hit effects + crosshair tint. HUD card icon is backup only. Player SEES information through the world, never READS it.

---

## What's still unresolved (remaining gaps)

### Critical Gaps — must address before prototyping

**1. Card effect categories — PARTIALLY RESOLVED.**
Direction decided: stack-then-execute (叠层后斩杀) is the core design philosophy. Cards apply status stacks, then finisher cards consume stacks for burst damage. Bullet-type and trigger-type cards fit the pack model cleanly. Non-bullet effects (heal, shield, dash) will be a SEPARATE perk/relic system outside the magazine — confirmed they don't fit as card packs.

Remaining work: design specific cards around stack-then-execute. Define what status types exist (poison, burn, freeze, etc.) and what finisher cards do with those stacks.

**2. Enemy design — DIRECTION SET.**
DOOM-inspired archetypes with different optimal combat distances to force weapon switching. Specific enemy types, stats, and behaviors still TBD. Need to define for Gate 1 prototype.

**3. Run structure — DEFERRED (acceptable for Gate 1).**
Gate 1 = single arena room with covers + verticality, 3 waves. Full run structure needed for Gate 2.

**4. Economy & meta-progression — DEFERRED.**
Not needed for Gate 1. Needed for v0.5.

**5. Extraction details — DEFERRED.**
Not needed for Gate 1. Needed for v0.5.

**6. Defensive/utility cards — RESOLVED.**
Non-bullet effects (heal, shield, dash) live outside the magazine as a perk/relic system. The magazine is for offensive card packs only. This cleanly resolves the "defensive packs don't make sense" problem.

**7. Curse/negative cards — DEFERRED.**
Not needed for Gate 1. Worth exploring for Gate 2+ as deck pollution / enemy interactions.

### Additional decisions that resolve prior gaps

**P7 — Miss penalty:** Card pack consumed on fire regardless of accuracy. Default rule, tune later.

**P8 — Reload mid-pack:** Remaining bullets wasted, deck reshuffles. Reload is now a real cost/decision.

**P9 — Variable bullet counts:** Confirmed. Strong cards = fewer bullets per pack, weak cards = more. Adds tuning dimension.

---

## Updated Risk Table

| # | Risk | Severity | Status |
|---|---|---|---|
| 1 | Card effects imperceptible at FPS speed | Was Critical | **Resolved** by card-pack model + color language. Validate in prototype. |
| 2 | "Every shot feels the same" (80% basics) | Was High | **Mitigated** by 70/30 starter split. Validate in prototype. |
| 3 | Card-enemy balancing | High | **Direction set** — DOOM archetypes with range differentiation. Specifics TBD. |
| 4 | UI information overload | Was High | **Resolved** by diegetic color language. |
| 5 | Content volume | Medium | Open — stack-then-execute may reduce needed card count (fewer unique cards, deeper interactions). |
| 6 | Balatro shadow | Medium | Open. |
| 7 | Bad RNG frustration | Medium | **Partially mitigated** — reload-mid-pack-waste creates agency (choose when to reshuffle). |
| 8 | Card effects too subtle | High | **Partially mitigated** by screen-wide color language. Prototype must validate. |
| 9 | Base FPS not fun on its own | High | Open — no FPS code yet. |
| 10 | Extraction always/never correct | High | Deferred — not needed for Gate 1. |
| 11 | Combinatorial explosion | Medium | Open. |
| 12 | Solo dev burnout | Medium | Open. |
| 13 | Non-bullet cards don't fit pack model | Was Medium | **Resolved** — heal/shield/dash moved to separate perk/relic system. Magazine is offensive only. |
| 14 | Curse packs too punishing | Medium | Deferred — not in Gate 1. |

---

## Remaining Questions for Gate 1

### 1-3: RESOLVED
- Q1 status types: Poison (stack+drain) + Burn (+20% amp). Defined.
- Q2 enemies: Grunt (30 HP, medium), Big Eye (100 HP, long), Rusher (20 HP, close). Defined.
- Q3 cards: Standard, Venom, Incendiary, Piercing, Detonator. Defined.

### 4. Does the player know how many bullets remain in the current card pack?
**Default for Gate 1:** Show ammo counter for current pack (like normal FPS ammo count). Test if players use the info.

### 5. Can the player see the next card pack coming?
**Default for Gate 1:** No. Transitions are surprises. Test if players care.

### 6. Weapon switching mid-combat — how does it interact with the magazine?
**Default for Gate 1:** One weapon only (Revolver). Skip weapon switching. Test card system in isolation.

---

## The Single Biggest Risk (updated v2.1)

**Stack-then-execute doesn't feel satisfying at FPS speed.**

The design bets on: player applies status stacks with sustained fire → recognizes stacks are high → switches to finisher card → detonates for big burst. This requires the player to:
1. Track stack count on the enemy (visual feedback needed)
2. Know when a finisher card is coming up in the magazine
3. Time the execution

If any of these are too hard to perceive or too slow to react to, the signature mechanic won't land. Gate 1 must test this loop specifically.

---

## The Single Biggest Strength (updated)

**The card-pack model + diegetic color language is an elegant solution to FPS-deckbuilder's hardest problem.**

Every prior attempt at real-time card combat has struggled with: "how does the player perceive card effects during fast action?" GP1's answer — cards are modes lasting ~2 seconds, communicated through screen-wide color shifts — is simple, intuitive, and trailer-ready.

A GIF of gameplay would show: player spraying orange-tinted fire bullets → color shifts to green → poison bullets with green trails → color shifts to blue → shield burst → reload shuffle → new color sequence begins. A viewer understands the system in 5 seconds without any explanation.

**This is stronger than the v1 hook.** "Your deck is your magazine" was a pitch. "Your gun cycles through color-coded card modes" is a visible, demonstrable mechanic.

---

## Recommended Next Steps

### Immediate (Gate 0.5 → Gate 1):
1. Define 2-3 status types (e.g., poison, burn) and their stack mechanics
2. Design 1 finisher/execute card that consumes stacks
3. Define 2-3 DOOM-inspired enemy types with combat distance differences
4. Pick 5 card types for Gate 1 (basic + 2 stackers + 1 finisher + 1 other)
5. Build Gate 1: arena with covers, 3 waves, card selection between waves

### Gate 1 prototype test (updated):
- Primary: **Can the player perceive card mode switches through color language alone?**
- Secondary: **Does the ~2 sec card-pack pace feel right?**
- Tertiary: **Does stack-then-execute produce a satisfying "burst" moment?**
- Bonus: **Does reload-as-sacrifice feel like a real decision?**

If all four are "yes" → the core works. Proceed to Gate 2.

# Design Audit: 2026-04-22 — Game Designer Review

## Audit Summary

The game-designer agent performed an exhaustive 15-area review of the GP1 "Cards Are Bullets" design. Overall verdict: **The hook is excellent. The design is a promising skeleton that needs significant fleshing out before prototyping.**

---

## Verdicts by Area

| # | Area | Verdict |
|---|---|---|
| 1 | Core Loop | Needs Work — micro-loop defined, meso/macro loops missing |
| 2 | Player Fantasy | Critical Gap — no identity, emotional arc, or mastery definition |
| 3 | Onboarding | Needs Work — no plan for teaching "cards are bullets" |
| 4 | Card System | Needs Work — 20 cards are still passive modifiers, not per-shot effects |
| 5 | Weapon System | Strong — "weapon as lens" is brilliant, edge cases undefined |
| 6 | Economy & Progression | Critical Gap — no economy, no meta-progression details |
| 7 | Extraction Mechanic | Critical Gap — concept only, zero implementation details |
| 8 | Enemy Design | Critical Gap — completely absent |
| 9 | Level/Room Design | Critical Gap — completely absent |
| 10 | Difficulty & Balance | Needs Work — no scaling, no anti-exploit, starter deck is 100% basic |
| 11 | UX & Feel | Needs Work — no HUD, no feedback design, no reload feel |
| 12 | Narrative & World | Needs Work — acceptable for prototype, needs direction for v0.5 |
| 13 | Monetization & Scope | Needs Work — 100+ cards ambitious, Early Access recommended |
| 14 | Competitive Differentiation | Strong — "per-shot card effects in FPS" claim holds up |
| 15 | Risks & Failure Modes | Needs Work — 5 additional risks identified |

---

## Critical Gaps (must address before prototyping)

### 1. Per-shot card mechanics are undefined
The 20 cards are passive modifiers. Many don't translate cleanly to per-shot:
- "Steady Aim" (ADS spread = 0) — what does this mean for ONE bullet?
- "Glass Cannon" (+100% dmg, -50% HP) — this is a state, not a shot
- "Hot Streak" (consecutive kills +10% dmg) — this is a tracker, not a bullet
- "Bullet Time" (kills slow time) — this is a triggered event, not a bullet modifier

**Recommendation:** Redesign cards into three categories:
- **Bullet cards** — modify THIS shot (fire, pierce, ricochet, homing). Always apply. No probability.
- **Trigger cards** — fire a normal-ish bullet but trigger effect on hit/kill/miss (slow time, heal, reload)
- **Instant cards** — fire no bullet, do something immediately (shield burst, dash, reload-and-draw)

### 2. No defensive/utility cards
All 20 cards are offensive. No shield, no heal, no dodge, no block.
- Creates no "offense vs defense" tension per shot
- Player has no way to survive except killing faster

**Recommendation:** Add 3-5 defensive cards: Shield Round, Heal Shot, Dodge Round, Decoy, Smoke Screen

### 3. No curse/negative cards
No dud rounds, no backfire, no jams.
- No risk in card acquisition
- No deck pollution from enemies or events
- Deck thinning has no urgency

**Recommendation:** Add curse cards: Dud Round (does nothing), Jam (forces reload), Cursed Bullet (damages you)

### 4. No enemy design
Zero enemy types defined. Cards exist to solve problems; enemies ARE the problems.

**Recommendation:** Define 5 types minimum:
1. Fodder — low HP, groups (tests AoE/spread)
2. Tank — high HP, slow (tests sustained DPS, burn/poison)
3. Rusher — fast, closes distance (tests defensive cards, movement)
4. Sniper — ranged, fragile (tests precision, movement)
5. Shielder — front shield (tests pierce/ricochet)

Plus 1 card-interactive enemy: "Jammer" that inserts dud rounds into your magazine.

### 5. No run structure
No room count, room types, map structure, or session flow defined.

**Recommendation:** For v0.5 target StS-style branching map:
- 8-12 nodes per run
- Types: Combat (60%), Elite (15%), Shop (10%), Event (10%), Boss (5%)
- Run length target: 15-20 minutes

### 6. No economy or meta-progression
What's the in-run currency? What do shops sell? What persists after extraction? What prevents snowball?

**Recommendation:** Extraction should UNLOCK cards in permanent collection, not let you START with them. Every run starts from scratch with expanded card pool. This is the StS model and it solves snowball.

### 7. No extraction details
When? How? What do you keep? What's the cost of extracting early?

**Recommendation:** Portals at fixed intervals (every 3 rooms). Reward scales with depth: room 3 = keep 1 card (unlock), room 6 = keep 3, room 9 = keep entire deck. Extraction ends the run.

---

## Additional Risks Identified

| # | Risk | Severity |
|---|---|---|
| 8 | Card effects too subtle — player doesn't notice the system | Critical |
| 9 | Base FPS not fun on its own — cards can't save bad shooting | High |
| 10 | Extraction always-correct or never-correct if reward isn't tuned | High |
| 11 | Combinatorial explosion — 100 cards × 3 weapons = 30,000 interaction pairs | Medium |
| 12 | Solo dev burnout on a 8-16 month complex system | Medium |

---

## Top 10 Questions Before Gate 1 Prototype

### 1. What does the player perceive and decide at each trigger pull?
If shuffle is random and player just shoots — there's no "micro-strategy moment." Define: can they see the current card? Can they skip/cycle? Is the decision "when to shoot" or "whether to shoot THIS card at THIS target"?

### 2. How do the 20 cards translate to per-shot effects — concretely, card by card?
Take the hardest cases (Steady Aim, Glass Cannon, Hot Streak, Bullet Time). Write exact per-shot versions. If they can't translate, they become a different system element (equipment/relic) or get cut.

### 3. What happens when a card fires but misses?
Consumed and wasted? Returns to deck? Triggers at impact point regardless? This determines skill floor, punishment for bad aim, and emotional weight of every shot.

### 4. What is the complete run structure?
Menu → Loadout → Room 1 → Reward → Room 2 → ... → Extract/Die. Every transition defined. Room count, types, pacing.

### 5. How does the starter deck solve "80% basics"?
Revolver (6 mag) with 6 basics = 100% mundane first room. **Start with 4 basics + 2 non-basics** so one-third of shots are interesting immediately.

### 6. What visual/audio feedback distinguishes card shots from basic shots?
If player can't TELL a fire bullet just fired without the HUD, the system doesn't exist. Define: muzzle flash color, bullet trail, hit effect, sound cue per card type.

### 7. What are the 2-3 enemy types for Gate 1?
Minimum: Fodder (groups, tests AoE), Tank (tests sustained damage), Rusher (tests reactive/defensive play).

### 8. What does reload/reshuffle feel like?
What makes it strategic? Can player see what they'll get? Cost of reloading early? If it's just "press R, wait, cards randomize" — it's not a strategic beat.

### 9. What persists after extraction vs death?
Even for Gate 1, stakes must be understood. Define the rules now even if not fully implemented.

### 10. What are the specific 5 cards for Gate 1, and why those 5?
Suggested: Basic Bullet + Ignite Rounds + Ricochet + Pierce + Shield Burst. Covers 4 effect types, Ignite + Ricochet creates emergent combo, Shield Burst tests defensive cards.

---

## The Single Biggest Risk

**The per-shot card system is imperceptible during real-time FPS gameplay.**

The game rests on one bet: that a player at FPS speed can perceive, understand, and react to individual card effects. If the game is too fast for this — if effects blur into "random stuff happening" — the hook is dead.

This is a cognitive bandwidth problem. Card games work because they're turn-based (unlimited think time). FPS games work because they're reflex-based. GP1 asks the player to do both simultaneously. That might not be possible at FPS speed.

**Gate 1 MUST answer this:** can the player identify which card just fired without looking at the HUD?

---

## The Single Biggest Strength

**"Your deck is your magazine" is genuinely novel, instantly communicable, and trailer-ready.**

It fuses FPS and deckbuilder at the verb level, not the menu level. Reloading is reshuffling. Magazine size is hand size. Weapon choice is deck archetype. Every concept maps cleanly.

This is a hook that sells in a single GIF: six shots, each visually distinct, then reload shows six new card icons. A viewer understands in 3 seconds. A streamer explains in one sentence.

**Protect this above all else.**

---

## Recommended Next Steps (before any code)

### Step 1: Paper prototype
6 index cards (4 basic, 2 special). Shuffle face-down. Flip one at a time. For each: shoot at Tank (50 HP) or Rusher (15 HP, closing)? Or hold fire and reload to reshuffle? Play 3 rounds. Do decisions feel meaningful?

### Step 2: Greybox feedback test
Firing range, no enemies. Load 5 cards. Fire each. Can you TELL which card fired from visuals/sound alone without the HUD?

### Step 3: Cognitive load test
Simplest combat room. After clearing: can you remember which cards fired? Did you ever WANT a specific card? If the player can't remember individual card moments, the system is too fast and needs to slow down or simplify.

---

## Gate 0.5 — "Do I know what I'm building?"
The audit identifies a missing gate between Gate 0 ("Do I still want this?") and Gate 1 ("One card that feels good").

**Gate 0.5 pass criteria:**
- All 10 questions above have written answers
- 5 prototype cards redesigned as per-shot effects (not passive modifiers)
- 3 enemy types defined with HP, behavior, and card-system interaction
- Run structure flowchart complete
- Paper prototype played at least once

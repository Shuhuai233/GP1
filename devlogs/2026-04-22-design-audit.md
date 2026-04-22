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

**1. Card effect categories undefined.**
What TYPES of effects can cards have? The card-pack model answers HOW cards deliver effects (X bullets per pack), but not WHAT those effects are.

Proposed categories (from v1 audit, still valid):
- **Bullet cards** — modify the bullets in this pack (fire, poison, pierce, ricochet, homing)
- **Trigger cards** — bullets are normal-ish but trigger effect on hit/kill (heal on kill, slow on hit, explode on death)
- **Instant cards** — no bullets fired, immediate effect (shield burst, dash, area pulse). Do these even make sense in the card-pack model? If a card = X bullets, what's an "instant" pack?
- **State cards** — may not belong in the magazine at all. Persistent buffs might need a separate system (relics/equipment).

**New question from card-pack model:** If an "instant" card is a pack, what does it mean? Does it fire 1 "bullet" that's actually a shield? Or does the pack concept not apply to non-bullet effects? This needs resolution.

**2. No enemy design.** (unchanged)
Zero enemy types. Cards solve problems; enemies ARE the problems. Can't evaluate card design without enemies to use cards against.

**3. No run structure.** (unchanged)
No session flow, room count, room types, or map structure.

**4. No economy or meta-progression.** (unchanged)
No in-run currency, no shop design, no extraction reward details, no snowball prevention.

**5. No extraction details.** (unchanged)
Concept only. When, how, what you keep, cost of extracting early — all undefined.

**6. Defensive/utility cards not yet considered.** (unchanged)
All discussion has been about offensive effects. No shield, heal, dodge concepts. In the card-pack model: what does a "defensive pack" feel like? You pull the trigger and instead of bullets, you get a shield for X seconds?

**7. Curse/negative cards not yet considered.** (unchanged)
No dud rounds, jams, or deck pollution. In the card-pack model: a curse pack means X bullets of NOTHING (or harmful). That could feel very punishing — you're stuck in "dud mode" for 2 seconds. Might be too harsh or might create great tension.

---

## Updated Risk Table

| # | Risk | Severity | Status |
|---|---|---|---|
| 1 | Card effects imperceptible at FPS speed | Was Critical | **Mitigated** by card-pack model + color language. Still needs prototype validation. |
| 2 | "Every shot feels the same" (80% basics) | High | Open — starter deck composition still undefined |
| 3 | Card-enemy balancing | High | Open — no enemies designed |
| 4 | UI information overload | Was High | **Mitigated** by diegetic color language decision |
| 5 | Content volume (200-300 cards) | Medium | Open — card-pack model may reduce needed variety (fewer card types needed since each lasts longer) |
| 6 | Balatro shadow | Medium | Open |
| 7 | Bad RNG frustration | Medium | Open — card-pack model may worsen this (stuck in bad-card mode for 2 sec vs 1 bullet) |
| 8 | Card effects too subtle | High | **Partially mitigated** by screen-wide color language. Prototype must validate. |
| 9 | Base FPS not fun on its own | High | Open — no FPS code exists yet |
| 10 | Extraction always/never correct | High | Open — no extraction details |
| 11 | Combinatorial explosion | Medium | Open |
| 12 | Solo dev burnout | Medium | Open |
| 13 | **NEW: Instant/defensive cards don't fit card-pack model** | Medium | The card-pack model assumes "X bullets per card." Non-bullet effects (shield, heal, dash) need a coherent answer for how they work as "packs." |
| 14 | **NEW: Curse packs too punishing** | Medium | Being stuck in "dud mode" for ~2 seconds during fast combat could feel terrible. Needs careful tuning or mitigation (shorter curse packs? manual skip at a cost?). |

---

## Updated Top 10 Questions Before Gate 1

### 1. What card effect categories exist, and how does each work as a "pack"?
Bullet packs (X fire bullets) are clear. What about trigger packs, instant packs, defensive packs? Define each category's pack behavior.

### 2. What happens when the player fires a card pack but misses most bullets?
Is the pack consumed regardless? Does accuracy matter? If a fire pack has 10 bullets and you miss 8, did you "waste" the card? This determines skill expression.

### 3. What is the complete run structure?
Menu → Loadout → Room 1 → Reward → Room 2 → ... → Extract/Die. Every transition. Room count, types, pacing.

### 4. How does the starter deck avoid "100% basic" first room?
With 6 card slots per magazine, starting with 4 basic + 2 non-basic means one-third of card packs are interesting from minute one.

### 5. What are the 2-3 enemy types for Gate 1?
Minimum: Fodder (groups, tests AoE packs), Tank (tests sustained DPS packs), Rusher (tests defensive play).

### 6. Can the player see how many bullets remain in the current card pack?
Options: a fading color intensity, a small counter, nothing (surprise switch). This affects how much the player can plan "I have 5 more fire bullets, enough to kill this enemy before it switches."

### 7. Can card packs have different bullet counts?
Fire = 5 bullets (strong per-bullet), Poison = 15 bullets (weak per-bullet, but lasts longer). Variable pack sizes add another tuning dimension but increase complexity.

### 8. What happens on reload mid-card-pack?
Player reloads with 7 bullets left in a 10-bullet fire pack. Are those 7 bullets wasted? Does the fire card go back into the deck? Or does it resume after reshuffle?

### 9. What persists after extraction vs death?
Even for Gate 1, stakes need to be understood. Define rules now even if not fully implemented.

### 10. What are the specific 5 card types for Gate 1 prototype?
Must include: at least 1 basic, at least 2 visually distinct offensive types, ideally 1 non-offensive card to test whether non-bullet packs work.

---

## The Single Biggest Risk (updated)

**"Instant" and defensive cards may not fit the card-pack model.**

The card-pack model elegantly solves offensive cards: fire pack = 10 fire bullets. But what about:
- A heal card? Is it a "pack" of 10 heal bullets you shoot at yourself?
- A shield card? You pull the trigger and get a shield for... 10 shots?
- A dash card? You fire and dash 10 times?

These don't make sense as "packs of bullets." If the game is ALL offensive bullet packs, it might work but limits strategic depth (no offense/defense tension). If non-bullet cards exist, they need a different mechanic that still fits the magazine/reload framework.

This is the design's current frontier — the card-pack model works beautifully for offense but hasn't been stress-tested against the full design space.

---

## The Single Biggest Strength (updated)

**The card-pack model + diegetic color language is an elegant solution to FPS-deckbuilder's hardest problem.**

Every prior attempt at real-time card combat has struggled with: "how does the player perceive card effects during fast action?" GP1's answer — cards are modes lasting ~2 seconds, communicated through screen-wide color shifts — is simple, intuitive, and trailer-ready.

A GIF of gameplay would show: player spraying orange-tinted fire bullets → color shifts to green → poison bullets with green trails → color shifts to blue → shield burst → reload shuffle → new color sequence begins. A viewer understands the system in 5 seconds without any explanation.

**This is stronger than the v1 hook.** "Your deck is your magazine" was a pitch. "Your gun cycles through color-coded card modes" is a visible, demonstrable mechanic.

---

## Recommended Next Steps

### Before any code (Gate 0.5):
1. Define card effect categories and how each works as a pack
2. Define 3 enemy types for prototype
3. Define run structure flowchart
4. Answer: what do non-bullet cards (heal, shield, dash) look like as packs?
5. Pick 5 specific card types for Gate 1

### Gate 1 prototype test:
- Primary question: **Can the player tell which card mode they're in from visual language alone?**
- Secondary question: **Does the ~2 sec card-pack pace feel right?**
- Tertiary question: **Does the player ever WANT a specific card mode and play around it?**

If all three are "yes" → the core works. Proceed to Gate 2.

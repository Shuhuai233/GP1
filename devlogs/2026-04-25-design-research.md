# Design Research: StS1, StS2, Vampire Crawlers

## Purpose

Deep design analysis of three reference games to inform GP1's card system redesign. Focus on synergy mechanics, what makes builds feel good, and what GP1 should learn from each.

Sources: Steam API reviews, Metacritic critic reviews, game design analysis.

---

## GAME 1: SLAY THE SPIRE 1

**Metacritic: 89** (24 critics, 100% positive) | **Steam: Overwhelmingly Positive** (75,066 reviews, 97.5%)
**User score: 8.0** (1,357 Metacritic ratings)

### The Design

Turn-based roguelite deckbuilder. 4 characters, ~350 cards total. Climb 3 floors + optional boss. Each run: build a deck from offered cards, find relics (passive items), fight enemies with hand-drawn cards.

### What Makes It Great — Design Analysis

#### 1. Cards are MULTIPLIERS, not ADDERS
The genius of StS is that cards interact MULTIPLICATIVELY:
- Inflame (+2 Strength) makes ALL future attacks deal +2
- Vulnerable (+50% damage taken) makes ALL attacks 50% stronger
- Focus (+1 per orb) makes ALL orbs permanently better
- Catalyst (double poison) turns linear stacking into exponential

This means: 1 multiplier card improves your ENTIRE deck. 2 multiplier cards improve each other. The power curve is exponential, not linear.

**GP1 lesson: Cards must amplify each other, not just add flat effects.**

#### 2. Three-role card taxonomy
Every card serves one of three roles:
- **ENABLER** — creates a condition (Apply Vulnerable, Apply Poison, Gain Strength)
- **PAYOFF** — exploits the condition (Heavy Strike scales with Strength, Catalyst doubles poison)
- **MULTIPLIER** — amplifies everything (Vulnerable, Strength, Focus)

The interplay between these three creates the "1+1>2" feeling. An Enabler alone is mediocre. A Payoff alone is mediocre. Together they're devastating.

**GP1 lesson: Design cards in Enabler/Payoff pairs. Then add Multipliers that connect different pairs.**

#### 3. Deck thinning = synergy density
StS lets you remove cards. Fewer cards = you draw your synergy pieces more often. A tight 15-card deck with 8 synergy cards cycles 2x faster than a 30-card deck with 8.

**GP1 lesson: Players need ways to remove Basic Rounds from their deck. Deck thinning is a strategy, not just cleanup.**

#### 4. Relics are permanent build direction
Relics (passive items found outside combat) define your build direction:
- Shuriken: gain Strength after 3 attacks → rewards attack-heavy decks
- Dead Branch: exhaust a card = add random card → rewards exhaust strategies

Relics give you a reason to pick specific cards. Without them, card choices are abstract.

**GP1 lesson: The perk/relic system (outside the magazine) should DIRECT card choices. "I have a relic that rewards poison stacking, so I'll pick Venom Rounds whenever offered."**

### What's Bad — From Real Player Reviews

**#1 complaint: RNG frustration**
- "RNG feels miserable... terrible hand = half my health gone with nothing I can do" (Steam)
- "The endgame is entirely based on luck" (Metacritic, user score 4)
- "Feels like pure luck... 17 losses and 3 wins" (Steam)
- "Boss will just decide its time for you to go and you are cooked" (Steam)

**#2 complaint: Steep learning curve**
- "Too hard, not fun unless you've memorized everything" (Steam)
- "300+ cards, new players don't know what synergizes" (observation)

**#3 complaint: Passive turns**
- "Too passive, correct move is just play all cards in any order" (Steam)
- "After a great run I don't feel like I did much" (Steam)

**GP1 lesson: Mitigate RNG with card foresight (next 2 pips) and reload-as-reshuffle (agency over draws). Keep card count LOW so new players learn fast. Make every card pack feel active (you're SHOOTING, not just playing cards).**

### Critic Consensus
- "Simple to learn, difficult to master. Every choice meaningful." (Worth Playing, 95)
- "Core dynamic gameplay loop begs for experimentation and discovery" (App Trigger, 95)
- "Mechanics so incredibly well designed it makes me like the art style" (Steam user, most-helpful positive)
- "The best single player deckbuilder" (Screen Rant, 100)

---

## GAME 2: SLAY THE SPIRE 2

**Metacritic: TBD** (9 Early Access reviews, including PCGamesN 100, Gamersky 90)
**Steam: No user reviews yet** (EA launched March 2026)

### What Changed

#### 1. Spells — persistent cards between combats
New card type that stays active across fights. Creates a new synergy layer without cluttering your hand.

**GP1 parallel: Your perk/relic system (outside the magazine) could function like Spells — persistent effects that modify how card packs behave.**

#### 2. Clearer archetype signposting
Cards more explicitly belong to "families" so new players identify synergy paths faster.

**GP1 parallel: Color-coding + clear naming conventions. "Venom" family, "Incendiary" family, etc.**

#### 3. Co-op mode
2-player with separate decks. Player A debuffs, Player B nukes.

**Not relevant for GP1 (single-player), but the DESIGN of "one player enables, one player pays off" is exactly the Enabler/Payoff pattern within a single player's deck.**

#### 4. "Command" keyword
Some cards let you choose between two effects when played.

**GP1 parallel: Could card packs have an alt-fire? Hold fire for effect A, tap for effect B?**

### Critic Consensus
- "More about refinement than evolution" (PCGamesN, 100)
- "Elevated to consistently deliver more 'I can't believe I just did that!' moments" (PCGamesN)
- "If you already feel burnout with the original, this sequel might not be new enough" (Ars Technica)
- "Framework of original remains intact, but so many new cards and unique characters" (Het Nieuwsblad, 100)

**GP1 lesson from StS2: The formula WORKS. Don't reinvent it. Refine it. Deliver "I can't believe I just did that" moments through synergy discovery.**

---

## GAME 3: VAMPIRE CRAWLERS

**Metacritic: 82** (16 critics, 86% positive) | **Steam: Overwhelmingly Positive** (3,311 reviews in 3 days, 97%)
**User score: 8.4** (27 Metacritic ratings)
**Released: April 21, 2026** (3 days ago)
**Price: $9.99**
**Developer: poncle** (Vampire Survivors developer)

### What It Is

First-person dungeon crawler + card deckbuilder + roguelite. PS1-style visuals. Turn-based combat using cards. Set in the Vampire Survivors universe with the same items, weapons, and evolution system.

This is GP1's closest competitor: card-based combat + first-person perspective + PS1 aesthetic + roguelite.

**Critical difference: Vampire Crawlers is turn-based. GP1 is real-time FPS. This is the key differentiator.**

### What Makes It Great — From Real Reviews

#### 1. VS's evolution system translated to cards
Players who know VS's weapon+passive=evolution formula can apply that knowledge. The discovery loop carries over.

**Critic (Destructoid, 90):** "Vampire Survivors' addicting, screen-filling, dopamine rush gameplay lives on in Vampire Crawlers, where fights are card-based, but the roguelite itch is scratched just as well as ever."

#### 2. Escalating combo system
Cards of increasing mana cost boost attributes. Building combos within a hand is the core mechanic.

**Player review (JaguarUSF):** "Has more depth than you'd initially think: playing cards of increasing mana cost boosts their attributes."

#### 3. The "snowball" feeling
Like VS, the game starts slow and builds to absurd power levels.

**Player review (DevTwoThousand):** "As a deckbuilder, Crawlers snowballs quickly and purposefully, it puts infinity within your grasp almost always, while making you fear the day infinity won't be enough."

#### 4. Anti-infinite mechanic (Shatter/Eyes)
The game has a built-in system to punish infinite loops: if you combo too hard, your cards shatter and a time demon boss appears.

**Player review (BS_Zephyr):** "oh hey i think i found an infinite, nice! wait, why are my cards being shattered? wait, did I just summon a boss? > gets mauled by 4 time demons for rigging the game. 10/10"

**GP1 lesson: If your card system allows infinites (which it will), design a FUN punishment for it rather than a hard cap. Make the game fight back when you break it.**

#### 5. Dopamine pacing
Multiple reviewers describe losing track of time, playing demos for 11-24 hours, being unable to stop.

**Player (ctmurphee, top review, 479 upvotes):** "Its a good thing my job can't tell if I'm working, because I'm not. Also a good thing they don't drug test because this game is addicting."

**Player (John Castlevania, 794 upvotes):** "I played the demo for 11 hours before this. This game is addictive and you should never ever buy it."

### What's Bad — From Negative Reviews

#### 1. "Play All" problem — becomes mindless
The #1 negative pattern. Once you build a strong deck, the optimal play is spamming "play all cards" without thinking.

**Player (COWABUNGA, 150 upvotes, negative):** "What kind of card game doesn't require you to think about what cards you're playing?? There's even an in-built anti-infinites system, but you can circumvent this by just freezing the enemy on the turn it triggers."

**Player (oxi):** "brainless game. Imagine playing a card game where you can just mindlessly tap play all"

**Player (Dingosama):** "After getting to 30x-40x combo every hand, the game lost its luster for me. Every hand became a number matching game."

#### 2. Repetitive after mastery
Once you find the dominant strategy, variety disappears.

**Player (Klipzen):** "Once you figure out that infinite cast loop the game gets pretty boring. It's also very short."

**Player (not smart):** "I like this game, but it is very repetitive. Unlike Vampire Survivors it is not a charming repetition."

#### 3. Little strategic depth for experienced card gamers
**Player (cowboys):** "After 4 hours i feel like ive already gotten the gist of the game and there's... not really a whole lot going on for this one as a deckbuilder? every weapon and every character kinda follows the same base structure."

**PC Gamer (50, lowest critic):** "Too often I just wanted to ram a garlic-flavoured stake through Vampire Crawlers repetitive, grindy heart."

### What This Means for GP1

**The "Play All" problem is GP1's biggest opportunity.** Vampire Crawlers fails for experienced card gamers because there's no THINKING — you just slam all your cards. GP1 can't have this problem because you're AIMING. Each card pack goes somewhere specific. You choose targets based on card type. The FPS skill layer prevents "play all" autopilot.

**The repetition problem is solvable with deeper synergies.** VC's combos are essentially: play cards in ascending mana order. GP1's status combo system (Poison + Burn = Toxic Fire) has more permutations and discovery depth.

**The anti-infinite mechanic is brilliant design.** If GP1 ever has a "broken build" that trivializes combat, the game should fight back in a fun way (harder enemies, boss spawns, card mutations) rather than just capping damage.

---

## CROSS-GAME COMPARISON

| Aspect | StS1 | StS2 | Vampire Crawlers | GP1 (target) |
|---|---|---|---|---|
| Combat | Turn-based | Turn-based | Turn-based | **Real-time FPS** |
| Perspective | 2D side | 2D side | First-person | **First-person** |
| Aesthetic | Hand-drawn | Hand-drawn | PS1/retro | **TBD** |
| Card mechanic | Play from hand | Play from hand | Play from hand | **Cards ARE your ammo** |
| Synergy type | Enabler/Payoff/Multiplier | Same + Spells | VS-style evolution combos | **Status combos + stack-execute** |
| Skill expression | Strategic choices | Strategic choices | Minimal (play all) | **Aiming + target selection** |
| Biggest strength | Depth, replayability | Refinement, co-op | Dopamine, accessibility | **FPS skill + deckbuilding** |
| Biggest weakness | RNG frustration, learning curve | Too familiar | Mindless after mastery | **TBD (unproven concept)** |
| Metascore | 89 | TBD (~90+) | 82 | Target: 80+ |
| Steam reviews | 97.5% positive (75k) | N/A | 97% positive (3.3k in 3 days) | Target: 85%+ |

### GP1's Unique Position
None of these three games combine:
- **Real-time FPS aiming** (skill expression in combat, not just card selection)
- **Card-pack ammunition** (cards ARE the bullets, not hand-played abstractions)
- **Status combo discovery** (emergent effects from combining statuses)
- **Diegetic color feedback** (read your card type from the game world, not UI)

This is genuinely unoccupied design space. The closest is Vampire Crawlers (first-person + cards + PS1) but it's turn-based with no aim skill.

---

## DESIGN PRINCIPLES EXTRACTED

### From StS1:
1. **Cards must MULTIPLY, not ADD.** Design Enabler → Payoff → Multiplier chains.
2. **Deck thinning is a strategy.** Let players remove Basic Rounds.
3. **Relics/perks DIRECT card choices.** "I have this relic, so I want those cards."
4. **RNG needs mitigation.** Card foresight, reload-as-reshuffle, status combos that work across types.

### From StS2:
5. **Refine, don't reinvent.** The core formula works. Deliver more "I can't believe that just happened" moments.
6. **Persistent effects (Spells) add depth without hand clutter.** GP1's perk system should work this way.
7. **Clearer archetype signposting** helps new players find synergies faster.

### From Vampire Crawlers:
8. **The "Play All" problem: GP1 can't have it** because aiming IS the gameplay. This is GP1's advantage.
9. **Anti-infinite mechanics should be FUN, not punishing.** Make the game fight back when players break it.
10. **Dopamine pacing matters.** The "can't put it down" feeling comes from escalating power + discovery.
11. **Avoid the repetition trap.** Deep synergies with many permutations prevent "solved builds."
12. **$10 price point is viable.** Vampire Crawlers at $10 has 3,311 reviews in 3 days.

### The Master Principle for GP1:
> **StS gives you strategic depth. VS/VC gives you dopamine. GP1 must give you BOTH — strategic depth THROUGH your aim, dopamine THROUGH your synergies.**

The aiming IS the strategic layer (target selection based on card type). The synergies ARE the dopamine (Toxic Fire erupting when Poison + Burn combine). Neither exists without the other. This is the design that no other game occupies.

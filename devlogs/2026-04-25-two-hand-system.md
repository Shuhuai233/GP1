# Devlog: 2026-04-25 — Two-Hand System (Major Design Evolution)

## Context

Playtest feedback revealed that the firing-card-only system lacks in-combat decisions. Player fires and reacts to card colors but never makes a strategic CHOICE during combat. The core loop felt flat.

## The Problem

Card packs (multiple bullets per card) solved the readability problem but created a new one: the player has no agency DURING combat. They just shoot what comes up. All strategy happens between waves (card selection) with none during waves.

## The Solution: Two-Hand System

**One deck, two card types, two hands.**

### Right Hand — Gun (Firing Cards)
- What we already have: card packs with multiple bullets
- Continuous fire, color-coded, reactive
- Player holds trigger, cards cycle through the magazine
- Strategy: target selection based on current card color
- Fires: poison bullets, burn bullets, pierce bullets, standard rounds, etc.

### Left Hand — Spell Hand (Function Cards)
- NEW: single-use ability cards
- Player cycles through available spells and triggers manually
- One-time effects: Detonator, shield, heal, AoE blast, etc.
- Strategy: WHEN to trigger, WHICH spell to use, on WHAT target
- This is where proactive decisions live during combat

### How It Works Together
- One shared deck contains both firing cards and function cards
- On reload/shuffle: firing cards load into gun magazine (6 slots), function cards load into spell hand (3 slots)
- Both hands work simultaneously — fire gun while having a spell queued
- Firing = reactive (shoot what you get). Spells = proactive (choose when to trigger).

## Why This Is Better

### Before (firing only):
- Player shoots → cards cycle → player reacts to colors → repeat
- No decisions during combat except "which enemy to aim at"
- Felt flat, no strategy while fighting

### After (two hands):
- Left hand fires continuously (reactive, damage output)
- Right hand holds spells ready (proactive, strategic triggers)
- "I'm stacking poison with my gun... stacks are high... NOW I trigger Detonator with my spell hand" — THIS is the 叠层后斩杀 moment done properly
- Player makes decisions every few seconds: "Do I trigger Detonator now or wait for more stacks? Do I use my heal now or save it?"

### Reference: DOOM Eternal
Similar to how DOOM Eternal works:
- Right trigger: shoot (continuous)
- Left-hand abilities: equipment launcher, chainsaw, blood punch (triggered)
- The interplay between continuous fire and triggered abilities IS the gameplay depth

## Decisions

### Detonator moves to Function Card
- Was: a firing card (3 bullet pack, randomly appears in magazine)
- Now: a function card (sits in spell hand, triggered manually)
- Why: Detonator's purpose is "consume poison stacks at the perfect moment." That's a DECISION, not a random bullet. It belongs in the hand where the player has agency.

### Deck Structure: One deck, auto-sorted
- One shared deck with both card types
- On shuffle: firing cards → gun magazine (6 slots), function cards → spell hand (3 slots)
- Card selection between waves: pick 1 from 3, mixed pool (could be firing or function)
- This means deck composition affects BOTH hands. More function cards = more spells but fewer firing options. Tradeoff.

### Spell Hand Size: 3 for Gate 1
- 3 function card slots in the left hand
- Player cycles through them (scroll wheel? number keys? Q/E?)
- Enough for strategy, not overwhelming
- Scale to 5 later if it works

## Deck Composition Tradeoff

This creates a new layer of deckbuilding strategy:

If your deck has 9 cards (6 firing + 3 function):
- Magazine loads 6 firing cards
- Spell hand loads 3 function cards
- Perfect balance

If your deck has 12 cards (7 firing + 5 function):
- Magazine loads 6 firing cards, 1 waits for next reload
- Spell hand loads 3 function cards, 2 wait for next reload
- More variety but slower cycling

If your deck has 9 cards (3 firing + 6 function):
- Magazine loads only 3 firing cards (half-empty gun!)
- Spell hand loads 3 function cards, 3 wait
- Spell-heavy build = less shooting, more casting

This is a genuine strategic axis: gun-heavy vs spell-heavy builds.

## Function Card Consumption Rules

- Most function cards are consumed on use (gone until reshuffle)
- Some function cards may be reusable with cooldowns (future design — not Gate 1)
- After all function cards in spell hand are used, hand is empty until reload/reshuffle
- This creates tension: "I used my Detonator early, now I have no spells left this magazine"

## What Needs Redesign

### Detonator — now a function card
- Type: Function (left hand)
- Effect: Target the enemy you're looking at. Consume ALL poison stacks. Deal 3x stacks as bonus damage.
- Consumed on use.
- Visual: large purple burst on target + screen flash
- Player aims at poisoned enemy, triggers spell → BOOM

### New function cards needed for Gate 1
Need at least 2-3 function cards to fill the spell hand. Candidates:

**Detonator** (confirmed)
- Consumes all poison stacks on aimed target, 3x bonus damage
- The 叠层后斩杀 payoff card

**Barrier** (proposed)
- Grants temporary shield (absorbs 30 damage, lasts 5 sec)
- Defensive option during Rusher pressure

**Flashfire** (proposed)
- Instantly applies burn to all enemies within 10m
- Setup spell: burn everything, then all subsequent fire damage is amplified

These give the spell hand: 1 finisher + 1 defensive + 1 setup. Three distinct roles.

## Updated Card Pool for Gate 1

### Firing Cards (right hand / gun):
| # | Card | Bullets/pack | Dmg | Color | Effect |
|---|---|---|---|---|---|
| 1 | Standard Round | 6 | 8 | White | None |
| 2 | Venom Round | 6 | 6 | Green | +2 poison stacks per hit |
| 3 | Incendiary Round | 6 | 8 | Orange | Burn (+20% dmg, 5 sec) |
| 4 | Piercing Round | 6 | 8 | Blue | Passes through first target |

### Function Cards (left hand / spell):
| # | Card | Type | Color | Effect |
|---|---|---|---|---|
| 5 | Detonator | Consume | Purple | Aim at target, consume all poison stacks, 3x bonus dmg |
| 6 | Barrier | Defensive | Cyan | 30 HP shield, 5 sec duration |
| 7 | Flashfire | Setup | Orange-Red | All enemies within 10m get burn status |

### Starter Deck (9 cards total):
- 3x Standard Round (firing)
- 1x Venom Round (firing)
- 1x Incendiary Round (firing)
- 1x Piercing Round (firing)
- 1x Detonator (function)
- 1x Barrier (function)
- 1x Flashfire (function)

On first shuffle: 6 firing cards → gun, 3 function cards → spell hand. Perfect fit.

## UI Implications

### Left side of screen (spell hand):
- 3 small card icons stacked vertically
- Currently selected spell highlighted
- Consumed spells grayed out
- Cycle with scroll wheel or Q/E keys
- Trigger with middle mouse or dedicated key (F? G? V?)

### Right side of screen (gun):
- Existing: ammo counter, crosshair color, card foresight pips
- No changes needed

## Open Questions for Prototype

1. What key triggers the spell? (Middle mouse? F key? V key?)
2. What key cycles spells? (Scroll wheel? Q/E?)
3. Does targeting for spells use the crosshair (like firing) or is it a separate targeting system?
4. What visual feedback for spell activation? (Left-hand animation? Screen-wide flash? Particle effect?)
5. Can you trigger a spell while reloading?

## Decision Log

| Date | Decision | Rationale |
|---|---|---|
| 2026-04-25 | Two-hand system: gun (firing) + spell hand (function) | Adds in-combat decisions. Player was passive with firing-only system. |
| 2026-04-25 | One shared deck, auto-sorted by card type | Deck composition creates gun-heavy vs spell-heavy tradeoff. |
| 2026-04-25 | Detonator moves to function card (spell hand) | Execute mechanic needs deliberate timing, not random appearance. |
| 2026-04-25 | 3 spell slots for Gate 1 | Manageable complexity. Scale to 5 later if it works. |
| 2026-04-25 | Both hands work simultaneously | Fire while having spell queued. Similar to DOOM Eternal's ability system. |

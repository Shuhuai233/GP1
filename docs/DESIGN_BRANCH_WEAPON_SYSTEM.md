# Design Branch: Weapon + Function Card System

*This is a design exploration. NOT yet committed to the GDD.*
*Purpose: flesh out the weapon-as-collectible + function-as-ability system before deciding.*

---

## Core Concept

Two card types only:

**Weapon Cards** = actual guns you find and customize
**Function Cards** = abilities you cast (character spells + magazine spells)

No more "firing cards" that carry status effects. Weapons are guns. Function cards are everything else.

---

## WEAPON CARDS

### What they are
Each weapon card is a distinct gun with its own fire rate, damage, feel. Players collect weapons during runs and customize them with attachments.

### Weapon roster (draft)

| Weapon | Fire rate | Mag size | Damage | Feel | Identity |
|---|---|---|---|---|---|
| Revolver | ~3/sec | 18 | 12/bullet | Slow, heavy, precise | Power per shot. Each bullet matters. |
| AR (Assault Rifle) | ~6/sec | 40 | 6/bullet | Medium, versatile, reliable | The all-rounder. Good at everything, best at nothing. |
| SMG | ~10/sec | 60 | 3/bullet | Fast, spraying, aggressive | Volume of fire. Burns through ammo and magazine spells fast. |
| Shotgun | ~1.5/sec | 8 | 5×6 pellets/blast | Slow, devastating up close | Close range monster. Each blast fires 6 pellets. |
| Sniper | ~0.8/sec | 5 | 30/bullet | Very slow, extreme damage | One shot, one kill. ADS mandatory. |
| SMG Pistol | ~8/sec | 30 | 4/bullet | Fast, mobile, hipfire focused | The run-and-gun weapon. High move speed while firing. |

### Carrying limit: 2 weapons
- Player carries 2 weapons at a time
- Switch with scroll wheel or 1/2 keys
- When you find a 3rd weapon: choose to swap or discard
- Each weapon has its own magazine state
- Reload only reloads the ACTIVE weapon

### Attachments
Attachments modify weapons permanently (until removed). Found during play as loot.

**Design rule: NO +15% stat bumps. Every attachment must be visually and mechanically obvious.**

| Attachment | What it does | Visual tell |
|---|---|---|
| Split Barrel | Bullets split into 3 after 5m of travel | 3 trails instead of 1 |
| Explosive Tips | Bullets explode on impact (2m AoE) | Orange explosion on hit |
| Ricochet Chamber | Bullets bounce off walls once toward nearest enemy | Visible bounce trajectory |
| Extended Mag | +50% magazine size | Bigger magazine model on gun |
| Speed Loader | Reload time halved | Faster reload animation |
| Piercing Rounds | Bullets pass through first target | Trail continues through enemy |
| Homing Module | Bullets slightly curve toward nearest enemy within 3m of trajectory | Curved bullet trails |
| Drum Barrel | Shotgun fires 10 pellets instead of 6 (but slower) | Wider barrel model |
| Scope | ADS zoom 2x further, +30% ADS damage | Visible scope on gun model |
| Tracer Feed | Every 5th bullet fires twice | Double muzzle flash every 5 shots |
| Chain Link | Hit chains to 1 nearby enemy for 40% damage | Lightning arc between enemies |
| Suppressor | Enemies don't aggro from sound while firing | No muzzle flash, quieter sound |

**Attachment slots: unlimited per weapon, but each attachment is unique (one copy in your run).**
If you find Split Barrel, you attach it to ONE weapon. Your other weapon doesn't get it unless you find another.

### Gunsmith mechanic
Between waves, if you pick an attachment, you enter a brief "gunsmith" screen:
- See your 2 weapons
- Drag the attachment onto one
- See the weapon model update with the attachment visible
- Confirm and continue

This is the "build your gun" moment. It should feel like customizing a weapon in a gun game — satisfying, visual, permanent for the run.

---

## FUNCTION CARDS

### What they are
Abilities the player casts with the F key. Two categories:

### Category 1: Character Spells (affect the player)

| Card | Color | Effect | Duration | Design intent |
|---|---|---|---|---|
| Shield Wall | Cyan | Project a shield in front of you. Blocks all incoming projectiles. You can fire through it. | 4 sec | Active defense. Blocks Grunt bullets and Big Eye beams. You choose WHERE to face the shield. |
| Dash | Light Gray | Instant dash in movement direction. Invincible during dash. | Instant (0.2s) | Dodge a beam. Close distance. Escape melee. The universal "oh shit" button. |
| Blink | White-Blue | Teleport to crosshair position (max 15m). | Instant | Repositioning. Get to high ground. Escape a corner. Creative movement. |
| Iron Skin | Steel | Absorb next 3 hits (regardless of damage). | Until 3 hits absorbed or 8 sec | Hard defense. "I know I'm about to take 3 shots, but I won't care." |
| Adrenaline | Pink | +50% move speed, +30% fire rate for 6 sec. | 6 sec | The "go fast" button. Everything speeds up. Pairs with SMG for maximum spray. |
| Vampiric Aura | Dark Red | 5 sec: all weapon damage heals player 40% of damage dealt. | 5 sec | Aggressive healing. Shoot enemies to heal. Rewards offense over hiding. |

### Category 2: Magazine Spells (load special ammo into weapon)

| Card | Color | Effect | Duration | Design intent |
|---|---|---|---|---|
| Poison Magazine | Green | Load poison ammo. Every bullet applies +2 poison stacks. | Until reload | Stack poison on targets. Pairs with Detonator for execute combo. |
| Fire Magazine | Orange | Load incendiary ammo. Every bullet applies Burn (+20% dmg taken). | Until reload | Universal damage amplifier. Everything you shoot takes more damage. |
| Shock Magazine | Electric Blue | Load shock ammo. Every bullet chains to 1 nearby enemy for 40% dmg. | Until reload | AoE through shooting. Hit one, damage two. |
| Frost Magazine | Cyan-White | Load cryo ammo. Every bullet applies Slow (-50% move speed). | Until reload | Crowd control. Rushers stop rushing. Big Eyes can't reposition. |
| Explosive Magazine | Dark Orange | Load explosive ammo. Every bullet creates 2m AoE on impact. | Until reload | Turn any weapon into an area damage weapon. SMG + Explosive = carpet bombing. |

### Category 3: Execute / Trigger Spells (consume status for burst)

| Card | Color | Effect | Design intent |
|---|---|---|---|
| Detonator | Purple | Hitscan at crosshair. Consume ALL poison stacks. Bonus = 3x stacks (6x if also burning). | The 叠层后斩杀 payoff. Stack → Execute. |
| Purge | White-Gold | Hitscan at crosshair. Consume ALL statuses on target. Deal 15 dmg per status type + 2 per total stack. | Multi-status execute. Rewards applying many different effects. |
| Chain Detonation | Blue-Purple | Hitscan at crosshair. Consume poison on target. Explosion spreads 50% of stacks to all enemies within 6m. | AoE execute. One Detonator becomes a room clear. |

---

## HOW THE SYSTEMS INTERACT

### Example play sequence:

1. **Start of run:** Player has Revolver + AR. Starter function cards: Poison Magazine, Shield Wall, Detonator.
2. **Wave 1:** Fire Revolver at Grunts. Normal bullets. Kill 3 Grunts with basic damage.
3. **Between waves:** Offered: Fire Magazine, Dash, Split Barrel (attachment). Player picks Split Barrel, attaches to AR.
4. **Wave 2:** Player casts Poison Magazine (F key). AR now fires poison bullets (each bullet splits into 3 from the attachment, each pellet applies +2 poison stacks = 6 stacks per shot!). Big Eye gets 40+ stacks fast. Player casts Detonator on Big Eye. BOOM — 120+ bonus damage.
5. **Between waves:** Offered: Explosive Tips (attachment), Shock Magazine, Blink. Player picks Explosive Tips, attaches to Revolver. Now has: AR with Split Barrel (crowd/stacking), Revolver with Explosive Tips (AoE damage).
6. **Wave 3:** Cast Fire Magazine on Revolver. Explosive + burning bullets. Cast Poison Magazine on AR. Split + poison bullets. Switch between weapons based on situation. Shield Wall when Rushers close. Detonator to finish Big Eye.

### The "build comes online" moment:
By wave 5-6, a player might have:
- AR with Split Barrel + Chain Link (bullets split into 3, each chains to 1 more = hitting 6 enemies per shot)
- Revolver with Explosive Tips + Scope (precision AoE sniper)
- Function hand: Poison Magazine, Fire Magazine, Detonator, Dash, Adrenaline

Casting Poison Magazine → switching to AR → Split Barrel sends 3 poison bullets per shot → Chain Link spreads them further → 30 stacks on the whole room in seconds → Detonator one target → Chain Detonation spreads it → ROOM CLEARED.

THAT is the "1+1>2" moment, and it happened through 5 separate choices that each felt meaningful on their own.

---

## ATTACHMENT + MAGAZINE SPELL INTERACTIONS

This is where the depth lives. Each attachment interacts differently with each magazine spell:

| Attachment | + Poison Mag | + Fire Mag | + Shock Mag | + Frost Mag | + Explosive Mag |
|---|---|---|---|---|---|
| Split Barrel | 3x stacking speed | 3 burn sources per shot | 3 chains per shot | 3 slow applications | 3 explosions per shot |
| Explosive Tips | Poison AoE on impact | Fire AoE (double fire) | Shock AoE | Frost AoE | Double explosion (stacks?) |
| Ricochet | Poison bounces to new target | Burn bounces | Shock bounces (triple chain) | Slow bounces | Explosive bounce |
| Chain Link | Poison chains further | Burn chains | Double chain | Slow chains | Explosive chain |
| Piercing | Poison hits 2 targets | Burn hits 2 | Shock hits 2 + chain | Slow hits 2 | Explosion + pierce through |

Every cell in this table is a discoverable interaction. The player doesn't see this table — they discover it by combining attachments and magazine spells.

---

## WHAT THIS REPLACES FROM OLD DESIGN

| Old system | New system |
|---|---|
| 40 firing + function cards | ~6 weapons + ~12 attachments + ~15 function cards |
| Firing cards carry status effects | Magazine spells apply status effects to ANY weapon |
| Card-packs with color-coded bullets | Weapons fire normally. Magazine spells add visual color to bullets. |
| 4 weapons with primal perks | 6 weapons with distinct feel + unlimited attachments |
| Fixed card effects | Modular: any weapon × any attachment × any magazine spell |

### Advantages of new system:
1. Weapons FEEL different (not just color-coded bullet packs)
2. Attachments are visual and exciting ("my AR shoots 3 bullets now!")
3. Magazine spells create clear "mode switches" (green poison bullets vs orange fire bullets)
4. Combinatorial depth: 6 weapons × 12 attachments × 5 magazine types = 360 combinations
5. "Build your gun" fantasy is strong and marketable
6. Easier to understand: "I have a gun. I modify the gun. I cast spells."

### Risks:
1. Losing the "deck is your magazine" unique hook — this is closer to a traditional FPS + ability system
2. Attachment inventory management could slow down the pace
3. Magazine spells that last "until reload" mean the player must choose between keeping special ammo OR getting spells back
4. Balancing 6 weapons × 12 attachments × 5 magazine types is harder than balancing 40 flat cards

---

## OPEN QUESTIONS

1. Is this still a "deckbuilder"? Or has it become an "FPS roguelite with gun customization + abilities"? Both are valid but they market differently.
2. Does the "deck is your magazine" hook survive this redesign? Or do we need a new hook?
3. How does the spell hand work? Still 5 slots with auto-advance? Or a different UI?
4. Do weapons come from the card pool (between-wave picks) or from separate loot?
5. When the player has 5 function cards in hand and uses one, do they get it back on reload? Or consumed permanently?
6. What's the starter loadout? Which 2 weapons, which function cards?

---

## STATUS: EXPLORATION ONLY

This document is a design branch. The GDD has NOT been updated. The current GDD still has the old 40-card system with manual weapon switching.

If you commit to this direction, the GDD, card pool, card reference, and all .tres files need to be rewritten.

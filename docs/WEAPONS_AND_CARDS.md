# GP1 — Weapons, Attachments & Function Cards

*Complete design reference. All items the player can find, equip, and use.*
*Design rule: NO "+15% of something." Every item must be visually obvious and mechanically dramatic.*

---

## PART 1: WEAPONS (6 types)

Player carries 2 weapons. Switch with scroll wheel or 1/2 keys. Each weapon is a distinct gun with its own personality. Weapons are found between waves as loot picks.

---

### Revolver

| Stat | Value |
|---|---|
| Fire rate | ~3 shots/sec |
| Magazine | 18 rounds |
| Damage | 12 per bullet |
| Reload | 2.0 sec |
| Attachment slots | Unlimited |

**Identity:** The hand cannon. Every shot sounds like thunder. High damage per bullet means every hit matters, every miss hurts. The weapon for players who aim well.

**Why it exists:** Baseline weapon. Starter gun. Teaches the player that aim = damage. Sets the expectation that GP1 is about precision, not spray.

**Best with:** Magazine spells that benefit from high per-bullet damage. Poison Magazine on Revolver = fewer stacks but each bullet's base damage is high. Fire Magazine = every bullet applies burn AND does 12 damage. Power-oriented.

**Worst with:** Effects that scale on hit count (Shock chains, Frost slow) — slow fire rate means fewer applications.

---

### AR (Assault Rifle)

| Stat | Value |
|---|---|
| Fire rate | ~6 shots/sec |
| Magazine | 40 rounds |
| Damage | 6 per bullet |
| Reload | 2.5 sec |
| Attachment slots | Unlimited |

**Identity:** The all-rounder. Reliable, versatile, boring alone — but becomes a monster with the right attachments and magazine spells. The weapon for players who want flexibility.

**Why it exists:** Mid-tier fire rate + mid-tier damage means it works with every magazine spell and every attachment. It's the "platform" weapon — its purpose is to be modified. An unmodded AR is mediocre. A modded AR with Split Barrel + Poison Magazine is a stacking machine.

**Best with:** Attachments that multiply its moderate fire rate (Split Barrel turns 6/sec into 18 projectiles/sec). Magazine spells that benefit from sustained fire.

**Worst with:** Nothing — that's the point. It's never the best, never the worst.

---

### SMG

| Stat | Value |
|---|---|
| Fire rate | ~10 shots/sec |
| Magazine | 60 rounds |
| Damage | 3 per bullet |
| Reload | 1.5 sec |
| Attachment slots | Unlimited |

**Identity:** The bullet hose. Spray and pray. Low damage per bullet but sheer volume overwhelms. The weapon for players who like holding the trigger and watching numbers fly.

**Why it exists:** Maximum status application speed. Poison Magazine on SMG = 10 stacks per second (10 shots × 2 stacks per hit, but actually every bullet hit at 10/sec). Also burns through magazine spells fastest — cast Poison Magazine on full SMG mag, that's 60 poison bullets. Cast on half-empty, still 30. The SMG is the "spell amplifier" weapon.

**Best with:** Any magazine spell. Shock Magazine = 10 chain procs per second. Frost Magazine = enemies are permanently slowed. Explosive Magazine = carpet bombing at 10 explosions per second.

**Worst with:** Situations requiring precision or single-target burst. Each bullet does 3 damage — killing a Big Eye (100 HP) takes 34 bullets minimum without status effects.

---

### Shotgun

| Stat | Value |
|---|---|
| Fire rate | ~1.5 blasts/sec |
| Magazine | 8 shells |
| Damage | 5 per pellet × 6 pellets = 30 per blast |
| Reload | 2.0 sec |
| Pellets per blast | 6 |
| Attachment slots | Unlimited |

**Identity:** The room clearer. Devastating up close, useless at range. Each blast fires 6 pellets that spread. At point blank, all 6 hit one target = 30 damage. At range, pellets spread across multiple enemies.

**Why it exists:** The close-range power fantasy. When Rushers close in, switch to Shotgun and blast them. Also the best weapon for multi-hit interactions — each pellet triggers magazine spell effects independently. Poison Magazine on Shotgun = 6 pellets × 2 stacks = 12 stacks per blast. That's 96 stacks in one full magazine (8 blasts × 12).

**Best with:** Magazine spells that scale with hit count. Poison Magazine = turbo stacking. Shock Magazine = 6 chain procs per blast. Any per-hit attachment.

**Worst with:** Long range targets. Big Eye at 25m = most pellets miss. Also burns through magazine spells in only 8 blasts.

---

### Sniper Rifle

| Stat | Value |
|---|---|
| Fire rate | ~0.8 shots/sec |
| Magazine | 5 rounds |
| Damage | 30 per bullet |
| Reload | 3.0 sec |
| ADS zoom | 2.5x (FOV 36) |
| Headshot multiplier | 3x (90 damage headshot) |
| Attachment slots | Unlimited |

**Identity:** One shot, one kill. The slowest weapon with the highest per-bullet damage. ADS is mandatory — hip-fire spread is massive. For players who want to line up the perfect shot and delete an enemy.

**Why it exists:** The skill ceiling weapon. A headshot does 90 damage — enough to one-shot a Grunt (30 HP) three times over. Against Big Eye (100 HP), two headshots kill. With Fire Magazine active, headshot = 90 × 1.2 = 108 damage — one-shot Big Eye. The Sniper rewards aim skill more than any other weapon.

**Best with:** Magazine spells that amplify per-bullet impact. Fire Magazine (burn on a 30-damage bullet = 36 effective). Poison Magazine on Sniper is only 5 bullets of stacking, but each bullet carries the status — use it to apply poison, then switch to another weapon.

**Worst with:** Crowd control situations. 5 bullets, slow fire, long reload. Against a Rusher swarm, the Sniper is a death sentence. Always carry a secondary weapon.

---

### Machine Pistol

| Stat | Value |
|---|---|
| Fire rate | ~8 shots/sec |
| Magazine | 30 rounds |
| Damage | 4 per bullet |
| Reload | 1.2 sec |
| Move speed while firing | +15% (built-in) |
| Attachment slots | Unlimited |

**Identity:** The run-and-gun weapon. Built-in movement speed bonus while firing makes this the FLUX player's dream. Faster than SMG's reload, smaller magazine but each bullet does slightly more. The weapon for players who never stop moving.

**Why it exists:** Movement-oriented playstyle. No other weapon lets you move faster WHILE shooting. The Machine Pistol + Dash + Adrenaline = a player who's impossible to pin down. It's the "I never stand still" weapon.

**Best with:** Character spells that boost speed (Adrenaline, Dash). Magazine spells on a 30-round mag get decent value. Frost Magazine = enemies can't catch you AND you're running away fast.

**Worst with:** Stationary defensive play. If you're hiding behind cover, the Machine Pistol's move speed bonus is wasted. Use the Revolver or Sniper for that.

---

## PART 2: ATTACHMENTS (15 types)

Attachments modify a weapon permanently for the run. Found between waves. Player drags attachment onto one of their 2 weapons. Unlimited slots per weapon. Each attachment is unique (only one copy per run).

**Design rule: every attachment must be VISIBLE on the gun model and IMMEDIATELY noticeable in gameplay. No invisible stat bumps.**

---

### Barrel Attachments (change what leaves the gun)

**1. Split Barrel**
- Effect: Bullets split into 3 projectiles after 5m of travel. Each does 50% of original damage.
- Visual: 3 bullet trails fan out after 5m
- Why: Turns single-target weapons into AoE. AR + Split Barrel = 18 projectiles per second. Sniper + Split Barrel = 3 high-damage bullets per shot.
- Magazine interaction: Each split projectile applies magazine spell effects independently. Poison Magazine + Split Barrel = 3× stacking speed.
- On gun model: Triple barrel tip visible

**2. Explosive Tips**
- Effect: Bullets explode on impact. 2m AoE. Explosion does 40% of bullet damage to all enemies in radius.
- Visual: Orange fireball on every hit
- Why: AoE damage on any weapon. Revolver + Explosive Tips = 12 damage bullet + 4.8 AoE per shot. Sniper + Explosive Tips = 30 damage bullet + 12 AoE.
- Magazine interaction: Explosion applies magazine spell status to all enemies in AoE.
- On gun model: Orange-tipped barrel

**3. Ricochet Chamber**
- Effect: Bullets bounce off walls once toward nearest enemy within 10m.
- Visual: Bullet trail changes direction at wall, seeks target
- Why: Shoot around cover. Hit enemies you can't see. Sniper + Ricochet = bank shots for 30 damage. Also turns misses into potential hits if there's a wall nearby.
- Magazine interaction: Bounced bullet still carries magazine spell effects.
- On gun model: Ribbed barrel with angular cuts

**4. Piercing Barrel**
- Effect: Bullets pass through the first enemy and continue to the next enemy in line.
- Visual: Bullet trail continues through enemy
- Why: Double damage when enemies line up. Sniper piercing = 30 damage to 2 targets per shot. Shotgun piercing = pellets pass through front enemy into back enemy.
- Magazine interaction: Both targets get magazine spell effects applied.
- On gun model: Elongated thin barrel

**5. Chain Link**
- Effect: On hit, damage chains to 1 nearby enemy within 6m for 40% damage.
- Visual: Lightning arc between hit enemy and chain target
- Why: Every bullet hits 2 enemies. SMG + Chain Link = 10 hits per second × 2 targets = 20 effective hits/sec. The crowd damage attachment.
- Magazine interaction: Chain target also gets magazine spell status applied.
- On gun model: Coil wrapped around barrel

---

### Magazine Attachments (change how ammo feeds)

**6. Drum Magazine**
- Effect: Magazine size doubled.
- Visual: Large drum visible on weapon
- Why: Double the bullets = double the magazine spell value. SMG goes from 60 to 120 rounds. Shotgun from 8 to 16 shells. Massive sustained fire.
- Trade-off: Reload time +50% (bigger mag takes longer to reload).
- On gun model: Large cylindrical drum attached to weapon

**7. Speed Loader**
- Effect: Reload time halved.
- Visual: Faster reload animation (snap instead of individual rounds)
- Why: More reloads per minute = more magazine spell casts. Also reduces the vulnerability window. Sniper goes from 3.0s to 1.5s reload.
- On gun model: Quick-release mechanism visible

**8. Double Feed**
- Effect: Every shot fires 2 bullets instead of 1. Magazine drains at 2x speed.
- Visual: Double muzzle flash, two bullet trails per shot
- Why: Double damage output for half the magazine duration. Revolver with Double Feed = 24 damage per trigger pull (but only 9 effective shots). Shotgun = 12 pellets per blast instead of 6.
- Magazine interaction: Both bullets apply magazine spell effects.
- On gun model: Dual feed mechanism visible at receiver

---

### Optics Attachments (change how you aim)

**9. Holo Sight**
- Effect: ADS transition instant (0.0s instead of 0.1s). ADS removes ALL spread.
- Visual: Holographic reticle appears on ADS
- Why: Snap-aim weapon. For players who quick-scope. Especially good on Sniper (instant ADS) and Shotgun (tighter pellet spread in ADS).
- On gun model: Small holo sight on top rail

**10. Thermal Scope**
- Effect: ADS highlights all enemies through walls (red outline, visible through geometry). Highlight range: 30m.
- Visual: ADS view shows red enemy silhouettes through walls
- Why: Information advantage. See where enemies are before they appear. Combined with Piercing Barrel = shoot enemies through thin cover. Combined with Sniper = wallhack headshots.
- On gun model: Large scope with orange lens

---

### Grip Attachments (change how the weapon handles)

**11. Steady Grip**
- Effect: Zero recoil. Camera doesn't kick on fire. Perfect tracking on moving targets.
- Visual: No camera shake while firing
- Why: Sustained accuracy. SMG with Steady Grip = laser beam of 10 bullets/sec exactly where you aim. Removes the skill ceiling on recoil control but replaces it with pure tracking skill.
- On gun model: Foregrip visible under barrel

**12. Quick Grip**
- Effect: Weapon switch to this gun is instant AND grants 0.3s of invincibility on switch.
- Visual: Brief flash/shimmer on weapon switch
- Why: Turns weapon switching into a defensive mechanic. Getting hit? Switch weapons for i-frames. Also enables rapid weapon combos — apply Poison Magazine on SMG, switch to Sniper (i-frames), headshot with Detonator follow-up.
- On gun model: Slim ergonomic grip

---

### Special Attachments (unique, build-defining)

**13. Vampiric Barrel**
- Effect: Every bullet heals player for 1 HP on hit.
- Visual: Red trail on bullets, brief red flash on hit
- Why: Sustained healing through offense. SMG + Vampiric = 10 HP/sec while firing. Shotgun = 6 HP per blast. Turns any weapon into a lifesteal weapon. The "I don't need healing spells" attachment.
- On gun model: Dark red barrel with vein-like texture

**14. Elemental Converter**
- Effect: When you cast a Magazine Spell, it applies to BOTH weapons simultaneously (not just the active one).
- Visual: Both weapon icons glow with magazine spell color
- Why: Normally you cast Poison Magazine on your active weapon only. With Elemental Converter, one cast poisons BOTH guns. Double value from every magazine spell. The build-defining attachment for dual-weapon status builds.
- On gun model: Glowing crystal embedded in the stock

**15. Chaos Engine**
- Effect: Every bullet has a 20% chance to fire as a random magazine spell type (Poison, Fire, Shock, Frost, or Explosive) regardless of whether you've cast one.
- Visual: Random colored bullets — each shot might be green, orange, blue, cyan, or dark orange
- Why: The "wildcard" attachment. No magazine spells needed — your weapon self-enchants randomly. Creates unpredictable, chaotic gameplay. You never know what status your next bullet applies.
- Trade-off: You can't control WHICH status gets applied. Shotgun + Chaos Engine = 6 pellets, each might be a different element. Insane visual spectacle.
- On gun model: Pulsing multicolor crystal in the barrel

---

## PART 3: FUNCTION CARDS (20 cards)

Function cards are abilities in the spell hand (5 slots). Cast with F key, auto-advance to next. Consumed on use. Spell hand refills on reload.

Found between waves alongside weapons and attachments. All from the same pick-1-from-3 offering pool.

---

### Category A: Magazine Spells (5 cards)

*Apply special ammo to remaining bullets in current magazine. Reload clears the effect.*

| # | Card | Color | Effect | Design intent |
|---|---|---|---|---|
| A1 | Poison Magazine | Green | Remaining bullets apply +2 poison stacks per hit. Pellets each apply independently. | The stacking enabler. Full SMG mag = 120 stacks. Half Shotgun = 4 blasts × 6 pellets × 2 = 48 stacks. |
| A2 | Fire Magazine | Orange | Remaining bullets apply Burn (+20% damage from all sources, 5 sec, refreshes on hit). | The universal amplifier. Every weapon hits 20% harder while burning. Cast early in mag for max uptime. |
| A3 | Shock Magazine | Electric Blue | Remaining bullets chain to 1 nearby enemy for 40% damage on hit. | AoE through shooting. SMG + Shock = 10 chains per second. Shotgun + Shock = 6 chains per blast. |
| A4 | Frost Magazine | Cyan | Remaining bullets apply Slow (-50% move speed, 4 sec, refreshes). | Crowd control. Rushers stop rushing. Cast on Shotgun, blast a crowd, everything slows. |
| A5 | Explosive Magazine | Dark Orange | Remaining bullets create 2m AoE on impact. AoE deals 30% of bullet damage. | Turn any weapon into AoE. SMG + Explosive = carpet bombing. Sniper + Explosive = precision AoE (30 × 0.3 = 9 AoE per shot). |

---

### Category B: Character Spells (8 cards)

*Affect the player directly. Movement, defense, buffs.*

| # | Card | Color | Effect | Design intent |
|---|---|---|---|---|
| B1 | Dash | Light Gray | Instant dash in movement direction, 5m. Invincible for 0.2s. | The universal dodge. Escape melee, dodge beams, cross gaps. Every build wants this. |
| B2 | Blink | White-Blue | Teleport to crosshair position (max 15m). Instant. | Repositioning. Get to high ground. Teleport behind Big Eye. Creative movement. |
| B3 | Shield Wall | Cyan | Project a barrier in front of you for 4 sec. Blocks all enemy projectiles. You can shoot through it. | Active defense. Plant it and fire through it. Blocks Grunt bullets and Big Eye beams. Positioning matters — it's directional. |
| B4 | Iron Skin | Steel | Absorb next 3 hits regardless of damage. Lasts 8 sec or until 3 hits absorbed. | Hard defense. "I'm going to eat 3 shots and not care." Good for pushing through Rusher swarms. |
| B5 | Adrenaline | Pink | 6 sec: +50% move speed, +30% fire rate. | Go fast, shoot fast. Machine Pistol + Adrenaline = untouchable speed demon. Also good for burning through Poison Magazine faster on SMG. |
| B6 | Vampiric Aura | Dark Red | 5 sec: all weapon damage heals player 40% of damage dealt. | Aggressive healing. Revolver doing 12 damage = 4.8 HP per hit. Sniper headshot = 36 HP healed. Rewards offense over hiding. |
| B7 | War Cry | Gold | 8 sec: all weapon damage +50%. | The raw power buff. Every weapon, every bullet, +50%. Sniper headshot = 90 × 1.5 = 135. Stack with Fire Magazine (burn) for +50% and +20% simultaneously. |
| B8 | Time Warp | Purple-White | 4 sec: all enemies move and attack at 30% speed. Player unaffected. | Bullet time. Dodge everything. Line up headshots. Cast right before Big Eye beam fires — now you have time to sidestep. The "oh shit" card for overwhelming situations. |

---

### Category C: Execute / Trigger Spells (4 cards)

*Consume status effects for burst damage. The payoff cards.*

| # | Card | Color | Effect | Design intent |
|---|---|---|---|---|
| C1 | Detonator | Purple | Hitscan at crosshair. Consume ALL poison stacks on target. Bonus damage = 3× stacks. If target also Burning: 6× stacks (Toxic Fire). | THE execute card. 叠层后斩杀. Stack poison → aim → F → BOOM. Must hit to trigger. Miss = wasted. |
| C2 | Chain Detonation | Blue-Purple | Hitscan at crosshair. Consume ALL poison stacks on target. Deal 3× stacks damage. Explosion spreads 50% of original stacks to all enemies within 6m. | AoE execute. The upgrade to Detonator. One target's stacks become everyone's problem. |
| C3 | Purge | White-Gold | Hitscan at crosshair. Consume ALL statuses on target. Deal 15 damage per status type active + 2 damage per total stack across all statuses. | Multi-status execute. Reward for applying many different effects. Poison(20) + Burn + Slow + Shock = 4 types × 15 = 60 + 20 stacks × 2 = 40 = 100 bonus damage. |
| C4 | Shatter | Ice-White | Hitscan at crosshair. If target is Slowed: instantly freeze (stun 3 sec) and deal 50 damage. If not Slowed: nothing (wasted). | Frost execute. Cast Frost Magazine → slow enemies → Shatter the big threat. 3 sec stun is enormous — that's 3 seconds of free shooting on a Big Eye. |

---

### Category D: Tactical Spells (3 cards)

*Utility effects that set up combos or provide information.*

| # | Card | Color | Effect | Design intent |
|---|---|---|---|---|
| D1 | Spotter | Red | Hitscan at crosshair. Apply Mark on target (+30% damage from all sources, 6 sec). | Focus fire enabler. Mark the Big Eye → everything does +30% to it. Stacks with Burn (+20%) = +50% total. |
| D2 | Reload Surge | Near-White | Instant reload on active weapon. Skip the reload time. Does NOT consume magazine spell — special ammo carries over into the new magazine. | Emergency reload + magazine spell preservation. The only way to reload without losing your special ammo. Extremely valuable with expensive magazine spells on slow-reload weapons. |
| D3 | Magnetize | Yellow | 5 sec: all enemies within 15m are pulled 3m toward the player every second. | Crowd control + grouping. Pull enemies together for AoE. Shotgun + Magnetize = pull them in → blast. Also horrifying with Explosive Tips — pull them in, then explode them all. |

---

## PART 4: STATUS EFFECTS

| Status | Applied by | Effect | Duration | Visual |
|---|---|---|---|---|
| Poison | Poison Magazine bullets | Stacks (+2 per hit). No decay. Consumed by Detonator/Chain Det/Purge. | Until consumed | Green glow, stack number |
| Burn | Fire Magazine bullets | +20% damage from ALL sources. | 5 sec, refreshes on hit | Orange flames |
| Shock | Shock Magazine bullets | Hit chains to 1 nearby enemy for 40% dmg. | 3 sec | Blue-white sparks |
| Slow | Frost Magazine bullets | -50% move speed. | 4 sec, refreshes on hit | Cyan frost particles |
| Mark | Spotter spell | +30% damage from ALL sources. | 6 sec, doesn't refresh | Red crosshair icon |
| Freeze | Shatter spell | Stunned, can't move or attack. | 3 sec | Ice crystal encasing |

### Status Combos

| Combo | Condition | Effect | Visual |
|---|---|---|---|
| Toxic Fire | Poison + Burn on same target | Detonator deals 6× stacks instead of 3× | Green-orange burst + "TOXIC FIRE" popup |
| Brittle | Freeze + any damage | Frozen enemies take 2× damage from all sources while frozen | Ice cracks on hit |
| Contagion | Poison + Shock on same target | Chain Detonation spreads 100% of stacks instead of 50% | Green lightning arcs |
| Marked for Death | Mark + Burn on same target | Mark damage bonus increases to +50% (from +30%) | Red flames on Mark icon |
| Permafrost | Slow + Frost Magazine (keep hitting a slowed target) | After 5 Frost hits on a Slowed target: auto-Freeze (stun 2 sec, no Shatter needed) | Ice gradually builds, then snaps into full freeze |

---

## PART 5: STARTER LOADOUT

### Weapons
- Slot 1: Revolver (no attachments)
- Slot 2: Empty (find a second weapon in waves 1-3)

### Function Cards (spell hand, 5 slots)
- Poison Magazine
- Fire Magazine
- Detonator
- Shield Wall
- Dash

### Design intent of starter loadout
- Revolver teaches basic shooting (aim matters, each shot is valuable)
- Poison Magazine + Detonator teaches the 叠层后斩杀 loop immediately
- Fire Magazine teaches burn as damage amplifier
- Poison + Fire on same target = player discovers Toxic Fire organically
- Shield Wall + Dash = survival basics
- Empty weapon slot 2 = immediate motivation to explore ("I need a second gun")

---

## PART 6: LOOT OFFERING RULES

Between each wave, offer 3 items. Types:

| Item type | What it is | Rarity in offerings |
|---|---|---|
| Function card | A new spell for the spell hand | Common (~40%) |
| Attachment | A permanent weapon mod | Uncommon (~30%) |
| Weapon | A new gun (swap into slot 1 or 2) | Rare (~20%) |
| Attachment for free | Apply to either weapon, no swap needed | Rare (~10%) |

### Rules
- Offer always contains at least 1 function card
- Weapons appear in offerings from wave 1 (player needs a 2nd gun early)
- Attachments appear from wave 2 onwards
- Show item type icon clearly (gun / attachment / spell)
- If player has 5 function cards and is offered more: they can swap (drop one, take new one)
- If player has 2 weapons and is offered a 3rd: choose which slot to replace

---

## PART 7: ITEM COUNTS

| Category | Count |
|---|---|
| Weapons | 6 |
| Attachments | 15 |
| Magazine Spells | 5 |
| Character Spells | 8 |
| Execute Spells | 4 |
| Tactical Spells | 3 |
| **Total function cards** | **20** |
| **Total all items** | **41** |

---

## PART 8: CROSS-SYSTEM SYNERGIES (the discoveries)

| Combo | Items | What happens | Why it's exciting |
|---|---|---|---|
| Turbo Stack | SMG + Poison Magazine | 10 poison hits/sec = 20 stacks/sec | Stack 60+ stacks in 3 seconds → Detonator = 180+ damage |
| Shotgun Execute | Shotgun + Poison Magazine + Detonator | 6 pellets × 2 stacks × 8 shells = 96 stacks → Detonator | Fastest stacking weapon + execute = one-shot anything |
| Split Poison | AR + Split Barrel + Poison Magazine | 6 shots/sec × 3 splits × 2 stacks = 36 stacks/sec | The mid-range stacking machine |
| Carpet Bomb | SMG + Explosive Magazine | 10 explosions per second across the room | Everything dies. Visual spectacle. |
| Sniper Delete | Sniper + Fire Magazine + War Cry | 30 × 1.2(burn) × 1.5(war cry) = 54 per bullet, headshot = 162 | One bullet kills anything in the game |
| Chaos Shotgun | Shotgun + Chaos Engine | 6 pellets per blast, each random element | Every blast is a rainbow of effects. Pure chaos. |
| Freeze Lock | Any weapon + Frost Magazine + Shatter | Slow → Freeze (3 sec stun) → free damage for 3 seconds | Complete crowd control. Lock down the scariest enemy. |
| Elemental Dual | Any + Elemental Converter + any Magazine Spell | One spell cast buffs BOTH weapons | Double value from every magazine spell. Switch freely without losing enchant. |
| Speed Demon | Machine Pistol + Adrenaline + Frost Magazine | +65% move speed while firing frozen bullets | Untouchable. Everything around you is slow, you're going fast. |
| Wall Sniper | Sniper + Ricochet + Thermal Scope | See through walls + bank shots around corners | Hit enemies that can't see you. Ultimate positioning. |
| Pull and Blast | Shotgun + Magnetize | Pull enemies in → point blank shotgun blast | 6 pellets, all hit, all apply status. Devastating. |
| Reload Loop | Sniper + Speed Loader + Reload Surge | 1.5 sec reload + free reload spell | Almost no downtime between 5-round magazines. Sustained sniper fire. |

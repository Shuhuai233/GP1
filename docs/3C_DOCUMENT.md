# GP1 — 3C Document (Character, Camera, Controls)

*Gate 1 prototype specification. All values are starting points — tune through playtesting.*

---

## Design Intent

GP1 is a first-person shooter where the player must be able to:
1. **Move fluidly** — smooth, responsive, satisfying moment-to-moment
2. **Aim precisely** — revolver rewards accuracy, Detonator spell requires hitting the target
3. **Read card modes** — crosshair and screen center must be visually clear enough to notice color shifts
4. **Make spatial decisions** — use cover, manage distance to enemies at different ranges (5m-30m)

The 3C should feel **responsive and modern** — closer to DOOM Eternal / Hades pace than Tarkov / ARMA. The player is active, not camping.

---

## 1. CHARACTER

### Player body
- First-person only (no third-person)
- No visible player model for Gate 1 (arms + weapon only)
- Capsule collider: height 1.8m, radius 0.3m
- Eye height: 1.6m from ground

### Health
- HP: 150
- No passive regeneration for Gate 1
- No armor / shield system for Gate 1
- Heal on kill: 10 HP per enemy killed
- Between-wave heal: 25 HP flat
- Death = run over (restart from wave 1)

### Damage feedback
- Screen edge red flash on hit (intensity scales with damage)
- Camera flinch: small random pitch kick on taking damage (2-4 degrees, recovers in 0.15s)
- Audio: impact grunt
- Low HP warning: heartbeat sound below 30 HP, subtle red vignette

---

## 2. CAMERA

### Base settings
- FOV: 90 degrees (standard FPS, wide enough for spatial awareness)
- Near clip: 0.05m
- Far clip: 100m
- No head bob for Gate 1 (clean read on crosshair color is priority)

### Camera position & attachment
- Camera attached to character capsule at eye height (1.6m from ground)
- Horizontal offset: 0 (centered)
- Camera follows character position with NO interpolation (locked, 1:1). Any smoothing/lag causes motion sickness in first-person.
- Crouch: camera lowers to 1.0m eye height, interpolated over 0.15s (smooth crouch transition)

### Rotation model
- **Horizontal rotation (yaw):** applied to the CHARACTER body (CharacterBody3D rotates on Y-axis). Mouse X input → body Y rotation.
- **Vertical rotation (pitch):** applied to the CAMERA node only (camera rotates on local X-axis). Mouse **Y** input → camera X rotation.
- **Roll (Z-axis):** NO persistent roll. Camera always returns to level. Brief roll effects allowed (see below).
- Rotation is Euler-based (pitch + yaw). No quaternion slerp needed for first-person.
- Rotation is applied IMMEDIATELY from mouse input — no interpolation, no smoothing, no lerp. Raw input → raw rotation. Any delay = nausea.

### Mouse look
- Sensitivity: configurable (default ~0.002 rad/pixel, typical for 800 DPI)
- No mouse acceleration
- No mouse smoothing
- Vertical look: clamped to ±85 degrees (can't look straight up/down)
- Horizontal: unclamped (full 360)
- Raw mouse input only (Input.MOUSE_MODE_CAPTURED, use InputEventMouseMotion.relative)

### Camera roll effects (Z-axis tilt)
All roll effects are BRIEF and SMALL. Camera always returns to 0 roll. These are juice, not mechanics.

| Trigger | Roll amount | Duration | Recovery |
|---|---|---|---|
| Strafe left | +1.5 degrees (tilt left) | While strafing | 0.2s return to 0 |
| Strafe right | -1.5 degrees (tilt right) | While strafing | 0.2s return to 0 |
| Taking damage | Random ±2 degrees | Instant | 0.15s return to 0 |
| Landing from height | 0 (no roll on land) | — | — |
| Recoil | 0 (no roll on fire) | — | — |

### Camera effects (subtle — must not interfere with card color reading)
- **Recoil kick:** 3 degree upward pitch per shot, recovers over 0.15s. Revolver at 2/sec means the camera has a rhythmic punch.
- **Landing impact:** small downward pitch (3-5 degrees) on landing from height >1m, recovers in 0.2s. No effect for small drops.
- **Sprint tilt:** very subtle forward lean (1-2 degrees pitch down) while sprinting. Interpolated over 0.3s. Returns on stop.
- **Damage flinch:** random pitch kick (2-4 degrees in random direction), recovers in 0.15s. Brief — player must return to reading card colors quickly.
- **NO screen shake for Gate 1 by default.** Try small shake (0.5-1 degree, 0.05s) during playtesting. Revert if it hurts card color readability.
- **NO chromatic aberration, NO motion blur.** These smear the color language.

### Camera state transitions

| From → To | Behavior |
|---|---|
| Hip → ADS | FOV 90→75 over 0.1s (linear interpolation). Camera position unchanged. |
| ADS → Hip | FOV 75→90 over 0.1s. |
| Standing → Crouch | Camera Y position 1.6m→1.0m over 0.15s (smooth). |
| Crouch → Standing | Camera Y position 1.0m→1.6m over 0.15s. Check headroom first — cancel if blocked. |
| Alive → Death | Camera drops to ground (physics-driven fall or scripted Y interpolation to 0.3m over 0.5s). Pitch tilts to ~30 degrees. Slight random roll (±10 degrees). Freeze at final position. No ragdoll cam for Gate 1. |
| Combat → Card selection | Camera stays in-world at current position. Card selection UI overlays. Player CAN still look around but CANNOT fire or move. Mouse cursor appears for card picking. |
| Card selection → Combat | UI dismisses. Mouse cursor hides. Full control returns. Brief 0.5s grace period (no enemy damage) to re-orient. |

### Camera during reload
- Camera stays fully controlled by player (can still look around during reload)
- No camera animation during reload — the weapon model animates (cylinder open/close), not the camera
- Player can track enemies while reloading (important for Rusher awareness)

### Critical constraint
The crosshair area must remain visually clean at all times. Card color tinting is communicated through the crosshair. Any camera effect that obscures, smears, or distracts from the screen center works AGAINST the core mechanic.

---

## 3. CONTROLS

### Movement

| Action | Key | Behavior |
|---|---|---|
| Walk forward | W | Constant speed |
| Walk backward | S | Constant speed (same as forward) |
| Strafe left | A | Constant speed |
| Strafe right | D | Constant speed |
| Sprint | Shift (hold) | Increased speed, forward only |
| Jump | Space | Instant impulse upward |
| Crouch | Ctrl (toggle) | Reduce height, slower move speed |

**Movement values:**

| Stat | Value | Notes |
|---|---|---|
| Walk speed | 5 m/s | Standard FPS pace |
| Sprint speed | 8 m/s | 60% faster, forward-only |
| Crouch speed | 3 m/s | Slower, behind cover |
| Jump impulse | 7 m/s upward | ~1.2m max jump height |
| Gravity | 20 m/s² | Slightly heavier than real (9.8). Snappy landings. |
| Air control | 60% of ground speed | Can adjust mid-air, reasonable strafe |
| Acceleration (ground) | 80 m/s² | Near-instant. Responsive, not floaty. |
| Deceleration (ground) | 80 m/s² | Stop fast. No ice-skating. |
| Acceleration (air) | 30 m/s² | Responsive air control |
| Deceleration (air) | 20 m/s² | Stop reasonably fast in air |

**Movement feel targets:**
- Grounded, responsive, no float
- Sprint feels noticeably faster but doesn't break spatial awareness
- Jumping is a commitment (can't bunny-hop effectively due to landing recovery)
- Crouch is for using cover, not for crouch-spamming

**Coyote time:** 0.1s — player can still jump for 0.1s after walking off an edge.
**Jump buffer:** 0.1s — pressing jump just before landing still registers.

### Combat

| Action | Key | Behavior |
|---|---|---|
| Fire | Left Mouse (hold or click) | Fires current card pack. Semi-auto feel at ~2/sec. |
| Reload | R | Manual reload. 2 sec animation. Wastes remaining bullets in current pack. Reshuffles BOTH gun and spell hand. |
| Aim (ADS) | Right Mouse (hold) | Slight zoom (FOV 90→75), tighter crosshair, slower move speed |
| Cast Spell | F | Triggers the active function card in spell hand. Spells auto-advance (next unconsumed spell becomes active). |

**Firing behavior:**
- Semi-automatic: player must click for each shot (no full-auto hold)
- Fire rate cap: ~3 shots/sec (0.33s between shots minimum)
- Raycast from camera center (hitscan, not projectile for Gate 1)
- Bullet spread: none while standing still. Minimal spread while moving (+1 degree). No spread while ADS.

**Why semi-auto, not full-auto:** The revolver fires deliberately. Each shot has weight. At 3/sec, the player has ~0.33s between clicks. This is fast enough to feel punchy while still supporting card-mode awareness.

**ADS (Aim Down Sights):**

| Stat | Value |
|---|---|
| ADS FOV | 75 (from 90) |
| ADS move speed | 60% of walk speed (3 m/s) |
| ADS spread | 0 (perfect accuracy) |
| ADS transition | 0.1s (snappy) |
| Can sprint while ADS | No |

**Reload:**

| Stat | Value |
|---|---|
| Reload time | 2 seconds |
| Can cancel reload | No (committed once started) |
| Can move during reload | Yes (walk speed only, no sprint) |
| Can fire during reload | No |
| Visual | Revolver cylinder opens, card-colored rounds visible, new rounds load in |

**Reload is a commitment.** 2 seconds of no shooting, no sprinting. This is the cost of reshuffling. Rushers can close ~16m during a reload. The player must find safe moments.

### Interaction

| Action | Key | Behavior |
|---|---|---|
| Card selection (between waves) | Mouse click on card | Pick 1 from 3 presented cards |
| Pause | Esc | Pause menu |

### Input priority
- Fire cancels ADS exit (can fire immediately from ADS)
- Reload cancels current card pack (remaining bullets wasted)
- Jump cancels crouch
- Sprint cancels ADS

---

## 4. WEAPON FEEL (Revolver)

### Visual
- Revolver held in right hand, offset to lower-right of screen
- Cylinder visible — shows 6 slots with card-colored rounds
- As cards are fired, cylinder slots empty (rotate animation per shot)
- On reload: cylinder swings open, spent rounds eject, new colored rounds load

### Audio (placeholder descriptions — actual assets TBD)
- **Fire:** Heavy, punchy revolver crack. Single shot feel. Distinct from enemy weapons.
- **Reload start:** Cylinder click-open
- **Reload end:** Cylinder snap-shut (satisfying mechanical sound)
- **Empty mag click:** Dry-fire sound if player tries to fire with no bullets. Signals "reload now."
- **Card transition:** Subtle tonal shift when one card pack ends and next begins. Not a UI sound — a world sound. Like a chamber rotating to a different round type.

### Recoil pattern
- Pure vertical kick: 3 degrees upward per shot
- Recovery: returns to original aim point over 0.15s
- No horizontal wander (revolver is stable)
- Visual gun kick: weapon model kicks back on fire (translate Z +0.05 over 0.05s, return over 0.1s)
- At 2 shots/sec, the rhythm is: kick → recover → kick → recover. Metronomic. Punchy.

### Muzzle flash
- Color matches current card pack (white/green/orange/blue/purple)
- Duration: 0.05s per flash
- Size: moderate (visible but not obscuring)
- This is a PRIMARY card-mode signal — make it clear

---

## 5. CROSSHAIR

### Design
- Simple dot + circle reticle
- Default size: small (encourages precision)
- **Entire crosshair tints to current FIRING card color** — this is the primary card-mode indicator
- White = Standard, Green = Venom, Orange = Incendiary, Blue = Piercing
- Crosshair does NOT change for function cards (spells use left-hand UI, not crosshair)

### Crosshair states
| State | Visual |
|---|---|
| Hip-fire, still | Small dot + circle, card-colored |
| Hip-fire, moving | Slightly expanded circle (+1 px), card-colored |
| ADS | Dot only (tighter), card-colored |
| Over enemy | Dot turns red (hit confirmation affordance) |
| Reloading | Crosshair fades to 50% opacity |

### Hit markers
- On hit: brief crosshair expansion + white tick marks (standard FPS hit marker)
- On kill: crosshair flashes + larger X mark
- On poison stack: green + number pops near crosshair
- On Detonator spell hit: large purple burst from crosshair + screen flash + "BOOM" feedback
- On Toxic Fire trigger: green-orange burst + "TOXIC FIRE" text popup

---

## 6. FEEL TARGETS (qualitative)

| Aspect | Target feel | Reference |
|---|---|---|
| Movement | Responsive, grounded, no float | DOOM Eternal (slightly slower) |
| Shooting | Weighty, punchy, deliberate | Destiny 2 hand cannon |
| Reloading | Mechanical, committed, satisfying sounds | Hunt: Showdown revolver |
| Card transitions | Smooth color shift, noticeable but not jarring | — (novel, no direct reference) |
| Taking damage | Urgent but not disorienting | Hades (red flash, quick recovery) |
| Death | Quick, clear, not punishing to restart | Hotline Miami (instant restart feel) |

---

## 7. IMPORTANT CONSTRAINTS

1. **No head bob.** Interferes with card color reading at crosshair.
2. **No screen shake on fire by default.** Test small shake (0.5-1 deg, 0.05s). Revert if hurts readability.
3. **No motion blur.** Smears the color language.
4. **No chromatic aberration.** Smears the color language.
5. **Semi-auto fire only.** Player must click per shot. Supports deliberate shooting.
6. **Crosshair must always be visible and colored.** No state should hide or obscure the crosshair during combat.
7. **Camera effects on damage should be brief** (< 0.2s recovery). Player needs to return to reading card colors quickly.

---

## 8. TUNING KNOBS (adjust in playtesting)

| Parameter | Starting value | Range to test |
|---|---|---|
| Walk speed | 5 m/s | 4-7 m/s |
| Sprint speed | 8 m/s | 6-10 m/s |
| Jump height | ~1.2m | 0.8-1.5m |
| Gravity | 20 m/s² | 15-25 m/s² |
| Fire rate | 3 shots/sec | 2-4 shots/sec |
| Recoil kick | 3.0 degrees | 1.5-4 degrees |
| ADS FOV | 75 | 65-80 |
| ADS transition time | 0.1s | 0.08-0.2s |
| Reload time | 2s | 1.5-3s |
| Mouse sensitivity | 0.002 rad/px | Player-configurable |
| Coyote time | 0.1s | 0.05-0.15s |
| Jump buffer | 0.1s | 0.05-0.15s |

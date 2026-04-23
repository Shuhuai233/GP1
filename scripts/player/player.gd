## Player — FPS controller per 3C document
## Walk, sprint (forward-only), crouch, jump (coyote + buffer), acceleration model, air control
## ADS, damage feedback, camera effects (recoil, landing, sprint tilt, strafe roll, damage roll)
## Death camera sequence
extends CharacterBody3D

# --- Movement ---
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 3.0
@export var jump_velocity: float = 5.0
@export var mouse_sensitivity: float = 0.002

@export_group("Acceleration")
@export var ground_accel: float = 50.0
@export var ground_decel: float = 50.0
@export var air_accel: float = 15.0
@export var air_decel: float = 5.0  # Low decel preserves momentum for "committed jumps"
@export var air_control_factor: float = 0.3

@export_group("Jump Assist")
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

@export_group("Health")
@export var max_hp: float = 100.0

@export_group("Camera")
@export var default_fov: float = 90.0
@export var ads_fov: float = 75.0
@export var ads_transition_speed: float = 1.0 / 0.15  # 0.15s transition
@export var ads_move_multiplier: float = 0.6

@export_group("Camera Effects")
@export var recoil_kick_degrees: float = 1.5
@export var recoil_recovery_time: float = 0.2
@export var landing_kick_degrees: float = 4.0
@export var landing_recovery_time: float = 0.2
@export var sprint_tilt_degrees: float = 1.5
@export var sprint_tilt_transition_time: float = 0.3
@export var strafe_roll_degrees: float = 2.0
@export var strafe_roll_speed: float = 8.0
@export var damage_flinch_degrees: float = 3.0
@export var damage_flinch_recovery: float = 0.15
@export var damage_roll_degrees: float = 2.0

@export_group("Crouch")
@export var stand_height: float = 1.8
@export var crouch_height: float = 1.0
@export var crouch_eye_height: float = 1.0  # 3C doc: crouch eye at 1.0m
@export var stand_eye_height: float = 1.6
@export var crouch_transition_speed: float = 4.0  # 0.6m / 0.15s ≈ 4.0

@export_group("Death Camera")
@export var death_eye_height: float = 0.3
@export var death_pitch_tilt: float = 30.0  # degrees
@export var death_roll: float = 10.0  # degrees
@export var death_drop_time: float = 0.5

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var damage_overlay: ColorRect = $ScreenEffects/DamageOverlay
@onready var vignette: ColorRect = $ScreenEffects/LowHPVignette

var current_hp: float
var is_dead: bool = false

# Movement state
var is_crouching: bool = false
var is_sprinting: bool = false
var is_ads: bool = false
var was_on_floor: bool = true
var prev_fall_velocity: float = 0.0

# Jump assist
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# Camera effect state
var recoil_offset: float = 0.0
var landing_offset: float = 0.0
var sprint_tilt_current: float = 0.0
var strafe_roll_current: float = 0.0
var flinch_pitch_offset: float = 0.0
var flinch_yaw_offset: float = 0.0
var damage_roll_offset: float = 0.0

# Weapon reference
var weapon: Node3D = null

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	current_hp = max_hp
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	camera.fov = default_fov
	camera.near = 0.05
	camera.far = 100.0

	weapon = get_node_or_null("Head/WeaponHolder")

	if damage_overlay and damage_overlay.material:
		damage_overlay.material.set_shader_parameter("intensity", 0.0)
	if vignette and vignette.material:
		vignette.material.set_shader_parameter("intensity", 0.0)

	EventBus.player_health_changed.emit(current_hp, max_hp)
	EventBus.weapon_fired.connect(_on_weapon_fired)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-85.0), deg_to_rad(85.0))
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Crouch toggle
	if event.is_action_pressed("crouch"):
		if is_crouching:
			_try_uncrouch()
		else:
			_enter_crouch()

	# Jump cancels crouch
	if event.is_action_pressed("jump"):
		if is_crouching:
			_try_uncrouch()
		jump_buffer_timer = jump_buffer_time


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# --- Coyote time ---
	if is_on_floor():
		coyote_timer = coyote_time
		# Landing impact: trigger on landing from >= ~1m fall (velocity >= 6.3 m/s)
		if not was_on_floor and prev_fall_velocity < -6.0:
			_apply_landing_impact()
	else:
		coyote_timer -= delta

	was_on_floor = is_on_floor()
	# Track fall velocity before move_and_slide resets it
	if not is_on_floor():
		prev_fall_velocity = velocity.y

	# --- Gravity ---
	if not is_on_floor():
		velocity.y -= gravity * delta

	# --- Jump (with coyote + buffer) ---
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		if coyote_timer > 0:
			velocity.y = jump_velocity
			coyote_timer = 0.0
			jump_buffer_timer = 0.0

	# --- Input ---
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# --- Sprint / ADS state ---
	var wants_sprint := Input.is_action_pressed("sprint") and not is_crouching
	var wants_ads := Input.is_action_pressed("ads")

	# Sprint requires forward input (input_dir.y < 0 = forward in get_vector)
	if wants_sprint and input_dir.y < 0.0:
		is_ads = false
		is_sprinting = true
	else:
		is_sprinting = false

	# Can't ADS while sprinting
	if wants_ads and not is_sprinting:
		is_ads = true
	elif not wants_ads:
		is_ads = false

	# --- Determine speed ---
	var target_speed: float
	var is_reloading := false
	if weapon and weapon.has_method("is_reloading"):
		is_reloading = weapon.is_reloading()

	if is_reloading:
		is_sprinting = false
		target_speed = walk_speed
	elif is_crouching:
		target_speed = crouch_speed
	elif is_sprinting:
		target_speed = sprint_speed
	elif is_ads:
		target_speed = walk_speed * ads_move_multiplier
	else:
		target_speed = walk_speed

	# Sprint is forward-only: zero strafe and backward
	if is_sprinting:
		input_dir.x = 0.0
		if input_dir.y > 0.0:
			input_dir.y = 0.0

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# --- Acceleration ---
	var accel: float
	var decel: float
	if is_on_floor():
		accel = ground_accel
		decel = ground_decel
	else:
		accel = air_accel
		decel = air_decel
		# Air: new input limited to 30% of walk speed; existing momentum preserved by low decel
		target_speed = walk_speed * air_control_factor

	if direction:
		velocity.x = move_toward(velocity.x, direction.x * target_speed, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * target_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, decel * delta)
		velocity.z = move_toward(velocity.z, 0, decel * delta)

	move_and_slide()

	# --- Camera effects ---
	_update_camera_effects(delta, input_dir)

	# --- Crouch interpolation ---
	_update_crouch(delta)

	# --- ADS FOV ---
	var target_fov := ads_fov if is_ads else default_fov
	camera.fov = move_toward(camera.fov, target_fov, (default_fov - ads_fov) * ads_transition_speed * delta)


func _update_camera_effects(delta: float, input_dir: Vector2) -> void:
	# --- Recoil recovery ---
	if recoil_offset > 0:
		var recovery_rate := deg_to_rad(recoil_kick_degrees) / recoil_recovery_time
		recoil_offset = move_toward(recoil_offset, 0.0, recovery_rate * delta)

	# --- Landing recovery ---
	if landing_offset > 0:
		var recovery_rate := deg_to_rad(landing_kick_degrees) / landing_recovery_time
		landing_offset = move_toward(landing_offset, 0.0, recovery_rate * delta)

	# --- Flinch recovery (pitch + yaw) ---
	if flinch_pitch_offset != 0:
		var recovery_rate := deg_to_rad(damage_flinch_degrees) / damage_flinch_recovery
		flinch_pitch_offset = move_toward(flinch_pitch_offset, 0.0, recovery_rate * delta)
	if flinch_yaw_offset != 0:
		var recovery_rate := deg_to_rad(damage_flinch_degrees) / damage_flinch_recovery
		flinch_yaw_offset = move_toward(flinch_yaw_offset, 0.0, recovery_rate * delta)

	# --- Damage roll recovery ---
	if damage_roll_offset != 0:
		var recovery_rate := deg_to_rad(damage_roll_degrees) / damage_flinch_recovery
		damage_roll_offset = move_toward(damage_roll_offset, 0.0, recovery_rate * delta)

	# --- Sprint tilt (forward lean) ---
	var tilt_target := deg_to_rad(-sprint_tilt_degrees) if is_sprinting else 0.0
	var tilt_rate := deg_to_rad(sprint_tilt_degrees) / sprint_tilt_transition_time
	sprint_tilt_current = move_toward(sprint_tilt_current, tilt_target, tilt_rate * delta)

	# --- Strafe roll (Z-axis tilt) ---
	var roll_target := 0.0
	if input_dir.x < -0.1:
		roll_target = deg_to_rad(strafe_roll_degrees)  # Tilt left when strafing left
	elif input_dir.x > 0.1:
		roll_target = deg_to_rad(-strafe_roll_degrees)  # Tilt right when strafing right
	strafe_roll_current = lerp(strafe_roll_current, roll_target, strafe_roll_speed * delta)

	# --- Apply all camera offsets ---
	# Pitch: recoil (up) + landing (down) + flinch (random) + sprint lean
	camera.rotation.x = -recoil_offset - landing_offset + flinch_pitch_offset + sprint_tilt_current

	# Roll: strafe roll + damage roll
	camera.rotation.z = strafe_roll_current + damage_roll_offset

	# Yaw flinch applied to body (small, transient)
	if absf(flinch_yaw_offset) > 0.001:
		rotate_y(flinch_yaw_offset * delta * 10.0)

	# --- Low HP vignette (shader) ---
	if vignette and vignette.material:
		if current_hp > 0 and current_hp / max_hp < 0.3:
			var current_intensity: float = vignette.material.get_shader_parameter("intensity")
			vignette.material.set_shader_parameter("intensity", lerp(current_intensity, 0.3, delta * 3.0))
		else:
			var current_intensity: float = vignette.material.get_shader_parameter("intensity")
			vignette.material.set_shader_parameter("intensity", lerp(current_intensity, 0.0, delta * 5.0))


func _update_crouch(delta: float) -> void:
	var capsule: CapsuleShape3D = collision_shape.shape
	var target_height := crouch_height if is_crouching else stand_height
	var target_eye := crouch_eye_height if is_crouching else stand_eye_height

	capsule.height = move_toward(capsule.height, target_height, crouch_transition_speed * delta)
	collision_shape.position.y = capsule.height / 2.0
	head.position.y = move_toward(head.position.y, target_eye, crouch_transition_speed * delta)


func _enter_crouch() -> void:
	is_crouching = true
	is_sprinting = false


func _try_uncrouch() -> void:
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP * crouch_height,
		global_position + Vector3.UP * stand_height,
		collision_mask
	)
	query.exclude = [get_rid()]
	var result := space.intersect_ray(query)
	if not result:
		is_crouching = false


func _apply_landing_impact() -> void:
	landing_offset = deg_to_rad(landing_kick_degrees)


func _on_weapon_fired(_card: Resource) -> void:
	recoil_offset += deg_to_rad(recoil_kick_degrees)


func take_damage(amount: float) -> void:
	if is_dead:
		return
	current_hp = maxf(current_hp - amount, 0.0)
	EventBus.player_health_changed.emit(current_hp, max_hp)
	EventBus.player_damaged.emit(amount)

	# Camera flinch: random pitch + yaw
	flinch_pitch_offset = deg_to_rad(randf_range(-damage_flinch_degrees, damage_flinch_degrees))
	flinch_yaw_offset = deg_to_rad(randf_range(-damage_flinch_degrees * 0.5, damage_flinch_degrees * 0.5))

	# Damage roll: ±2 degrees
	damage_roll_offset = deg_to_rad(randf_range(-damage_roll_degrees, damage_roll_degrees))

	# Red screen edge flash (shader vignette)
	if damage_overlay and damage_overlay.material:
		var intensity := clampf(amount / 30.0, 0.15, 0.6)
		damage_overlay.material.set_shader_parameter("intensity", intensity)
		var tween := create_tween()
		tween.tween_method(
			func(val: float): damage_overlay.material.set_shader_parameter("intensity", val),
			intensity, 0.0, 0.3
		)

	if current_hp <= 0.0:
		die()


func die() -> void:
	is_dead = true
	EventBus.player_died.emit()

	# Death camera: drop eye to 0.3m, tilt pitch 30°, roll ±10°, freeze
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(head, "position:y", death_eye_height, death_drop_time).set_ease(Tween.EASE_IN)
	tween.tween_property(head, "rotation:x", deg_to_rad(-death_pitch_tilt), death_drop_time)
	var roll_dir := 1.0 if randf() > 0.5 else -1.0
	tween.tween_property(camera, "rotation:z", deg_to_rad(death_roll * roll_dir), death_drop_time)


func heal(amount: float) -> void:
	current_hp = minf(current_hp + amount, max_hp)
	EventBus.player_health_changed.emit(current_hp, max_hp)


func get_is_moving() -> bool:
	return Vector2(velocity.x, velocity.z).length() > 0.5


func get_is_ads() -> bool:
	return is_ads

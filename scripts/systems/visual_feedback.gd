## VisualFeedback — Handles muzzle flash, bullet trails, hit effects
## All color-coded to match the current card
extends Node3D

@onready var muzzle_flash: GPUParticles3D = $MuzzleFlash
@onready var hit_effect: GPUParticles3D = $HitEffect


func _ready() -> void:
	EventBus.weapon_fired.connect(_on_weapon_fired)
	EventBus.hit_confirmed.connect(_on_hit_confirmed)
	EventBus.hit_missed.connect(_on_hit_missed)


func _on_weapon_fired(card: Resource) -> void:
	_spawn_muzzle_flash(card.muzzle_color)


func _on_hit_confirmed(hit_pos: Vector3, card: Resource, _enemy: Node3D) -> void:
	_spawn_hit_effect(hit_pos, card.color)
	_spawn_trail(hit_pos, card.trail_color)


func _on_hit_missed(hit_pos: Vector3, card: Resource) -> void:
	_spawn_hit_effect(hit_pos, card.color * 0.5)
	_spawn_trail(hit_pos, card.trail_color * 0.7)


func _spawn_muzzle_flash(color: Color) -> void:
	if muzzle_flash:
		var mat: ParticleProcessMaterial = muzzle_flash.process_material
		if mat:
			mat.color = color
		muzzle_flash.restart()
		muzzle_flash.emitting = true


func _spawn_hit_effect(pos: Vector3, color: Color) -> void:
	# Create a temporary particle burst at hit position
	var particles := GPUParticles3D.new()
	particles.emitting = true
	particles.amount = 8
	particles.one_shot = true
	particles.lifetime = 0.4
	particles.explosiveness = 0.9

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 0.1
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 60.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 5.0
	mat.gravity = Vector3(0, -5, 0)
	mat.scale_min = 0.05
	mat.scale_max = 0.15
	mat.color = color
	particles.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.03
	mesh.height = 0.06
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.albedo_color = color
	mesh_mat.emission_enabled = true
	mesh_mat.emission = color
	mesh_mat.emission_energy_multiplier = 3.0
	mesh.material = mesh_mat
	particles.draw_pass_1 = mesh

	particles.global_position = pos
	get_tree().current_scene.add_child(particles)

	# Auto cleanup
	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(particles.queue_free)


func _spawn_trail(to_pos: Vector3, color: Color) -> void:
	# Simple line from muzzle to hit point
	var cam := get_viewport().get_camera_3d()
	if not cam:
		return

	var from_pos := cam.global_position + cam.global_transform.basis * Vector3(0.2, -0.15, -0.5)

	var trail := MeshInstance3D.new()
	var imm := ImmediateMesh.new()
	trail.mesh = imm

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(color.r, color.g, color.b, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	imm.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	imm.surface_add_vertex(from_pos)
	imm.surface_add_vertex(to_pos)
	imm.surface_end()

	get_tree().current_scene.add_child(trail)

	# Fade and remove
	var tween := get_tree().create_tween()
	tween.tween_property(trail, "transparency", 1.0, 0.15)
	tween.tween_callback(trail.queue_free)

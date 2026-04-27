## EnemyProjectile — Visible slow projectile for enemies
## Used by Grunt (red, 15 m/s) and BigEye (purple, 20 m/s)
## Deals damage on hitting player. Destroys on any collision.
class_name EnemyProjectile
extends Area3D

@export var speed: float = 15.0
@export var damage: float = 3.0
@export var color: Color = Color(1, 0.1, 0.1, 1)
@export var lifetime: float = 5.0

var direction: Vector3 = Vector3.FORWARD
var _age: float = 0.0
var _mesh: MeshInstance3D


func _ready() -> void:
	# Build mesh and material procedurally
	_mesh = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.12
	sphere.height = 0.24
	_mesh.mesh = sphere

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 4.0
	_mesh.set_surface_override_material(0, mat)
	add_child(_mesh)

	# Collision shape
	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.12
	col.shape = shape
	add_child(col)

	collision_layer = 0
	collision_mask = 0b10000011  # environment + player + shield_wall (layer 8)

	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	global_position += direction * speed * delta


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		# Check grace period via wave_manager group
		var wm := get_tree().get_first_node_in_group("wave_manager")
		var grace: bool = wm != null and wm.has_method("is_grace_period") and wm.is_grace_period()
		if not grace:
			body.take_damage(damage)
	queue_free()


func init(pos: Vector3, dir: Vector3, spd: float, dmg: float, col: Color) -> void:
	global_position = pos
	direction = dir.normalized()
	speed = spd
	damage = dmg
	color = col

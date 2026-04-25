## Arena — Bakes navigation mesh at runtime so enemies path around cover
extends Node3D


func _ready() -> void:
	# Bake the NavigationMesh at runtime
	# The NavigationRegion3D with its CSG geometry must be ready first
	await get_tree().process_frame
	var nav_region := get_node_or_null("NavigationRegion3D")
	if nav_region:
		NavigationServer3D.bake_from_source_geometry_data_async(
			nav_region.navigation_mesh,
			NavigationMeshSourceGeometryData3D.new()
		)
		# Simpler: use the built-in bake method
		nav_region.bake_navigation_mesh(false)

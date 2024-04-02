@tool
extends Node3D
class_name Building

@export var building_preset: BuildingPreset

func _get_tool_buttons() -> Array:
	return [
		{call=_generate, text="Generate", tint=Color.GREEN}
	]

func _generate():
	if building_preset == null: return
	
	var building: MeshInstance3D = get_node("building")
	var vegetation: MeshInstance3D = get_node("vegetation")
	
	for child in building.get_children():
		building.remove_child(child)
	building.mesh = building_preset.building_mesh
	building.create_trimesh_collision()
	building.get_child(0).get_child(0).hide()
	building.set_surface_override_material(0, building_preset.walls_material)
	building.set_surface_override_material(1, building_preset.windows_material)
	
	var vegMesh = building_preset.vegetation_meshes.pick_random()
	vegetation.mesh = vegMesh
	vegetation.set_surface_override_material(0, building_preset.vegetation_material)

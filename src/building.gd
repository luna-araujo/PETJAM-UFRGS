@tool
extends Node3D
class_name Building

@export var building_preset: BuildingPreset

@export_group("Computed")
@export var building_mesh: Mesh
@export var vegetation_mesh: Mesh

func _ready():
	update_meshes()

func _get_tool_buttons() -> Array:
	return [
		{call=_randomize, text="Randomize", tint=Color.GREEN}
	]

func pick_meshes():
	if building_preset == null: return
	
	building_mesh = building_preset.building_mesh
	vegetation_mesh = building_preset.vegetation_meshes.pick_random()

func update_meshes():
	if (building_mesh != null):
		var building: MeshInstance3D = get_node("building")
		for child in building.get_children():
			building.remove_child(child)
		building.mesh = building_mesh
		building.create_trimesh_collision()
		building.get_child(0).get_child(0).hide()
		building.set_surface_override_material(0, building_preset.walls_material)
		building.set_surface_override_material(1, building_preset.windows_material)
		building.set_surface_override_material(2, building_preset.bars_material)
	if (vegetation_mesh != null):
		var vegetation: MeshInstance3D = get_node("vegetation")
		vegetation.mesh = vegetation_mesh
		vegetation.set_surface_override_material(0, building_preset.vegetation_material)

func _randomize():
	pick_meshes()
	update_meshes()

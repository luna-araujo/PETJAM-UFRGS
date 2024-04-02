extends Resource
class_name BuildingPreset

@export_group("Mesh")
@export var building_mesh: Mesh
@export var vegetation_meshes: Array[Mesh];

@export_group("Material")
@export var walls_material: Material
@export var windows_material: Material
@export var vegetation_material: Material

func _init(
	_building_mesh: Mesh = null,
	_vegetation_meshes: Array[Mesh] = [],
	_walls_material: Material = null,
	_windows_material: Material = null,
	_vegetation_material: Material = null
):
	building_mesh = _building_mesh
	vegetation_meshes = _vegetation_meshes
	walls_material = _walls_material
	windows_material = _windows_material
	vegetation_material = _vegetation_material

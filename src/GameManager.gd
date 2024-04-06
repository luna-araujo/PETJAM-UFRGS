class_name GameManager
extends Node

@export var game_over_scene:PackedScene

var compounds
var completed_compounds:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	compounds = get_tree().get_nodes_in_group("Compound")
	
	for compound in compounds:
		compound.task_completed.connect(on_compound_task_completed)
	
	print(compounds.size())

func on_compound_task_completed():
	completed_compounds += 1
	if completed_compounds == compounds.size():
		end_game()

func  end_game():
	var scene = game_over_scene.instantiate()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().get_root().add_child(scene)
	get_parent().queue_free()


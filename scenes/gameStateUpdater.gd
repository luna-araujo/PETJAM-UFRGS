extends Node3D

@export var end_game_scene:PackedScene

@onready var compounds = get_tree().get_nodes_in_group("Compound");
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var good = true;
	for compound in compounds:
		good = good && compound.complete_task;
	if(good):
		get_tree().change_scene_to_packed(end_game_scene);

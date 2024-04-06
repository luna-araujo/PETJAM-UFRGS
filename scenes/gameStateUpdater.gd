extends Node3D

@export var end_game_scene:PackedScene

@onready var compounds = get_tree().get_nodes_in_group("Compound");
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var good = false;
	var cnt = 0;
	for compound in compounds:
		good = good && compound.complete_task;
		if(compound.complete_task):
			cnt+=1;
	print(cnt);
	if(good):
		get_tree().change_scene_to_packed(end_game_scene);

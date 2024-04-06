class_name MainMenu
extends Node

@export var game_scene:PackedScene

func _ready():
	pass # Replace with function body.

func _on_quit_button_button_down():
	get_tree().quit()


func _on_play_button_button_down():
	get_tree().change_scene_to_packed(game_scene);

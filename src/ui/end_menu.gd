class_name EndMenu
extends Node

@export var menu_scene:PackedScene

func _on_quit_button_button_down():
	get_tree().quit()

func _on_return_button_button_down():
	get_tree().quit()

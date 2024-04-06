class_name EndMenu
extends Node

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;

func _on_return_button_button_down():
	get_tree().quit()

class_name Sign
extends Node3D

@export_multiline var text: String = ""
@export var no_mesh:bool = false
@onready var label: Label3D = $"Label3D"
@onready var area: Area3D = $"Area3D"
var hidden: bool = true

func _ready():
	if no_mesh:
		$"Visuals".queue_free()
	
	label.text = text
	label.modulate = Color.TRANSPARENT
	label.outline_modulate =  Color.TRANSPARENT


func _process(delta):
	if hidden:
		label.modulate = lerp(label.modulate, Color.TRANSPARENT, 10 * delta)
		label.outline_modulate = lerp(label.outline_modulate, Color.TRANSPARENT, 10 * delta)
	else:
		label.modulate = lerp(label.modulate, Color.WHITE, 10 * delta)
		label.outline_modulate = lerp(label.outline_modulate, Color.BLACK, 10 * delta)
	pass

func update_text(text: String):
	label.text = text

func _on_area_3d_body_entered(body):
	if body is CharacterController:
		hidden = false


func _on_area_3d_body_exited(body):
	if body is CharacterController:
		hidden = true

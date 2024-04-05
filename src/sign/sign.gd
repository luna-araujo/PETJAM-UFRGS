class_name Sign
extends Node3D

@export_multiline var text: String = ""
@onready var label: Label3D = $"Label3D"
@onready var area: Area3D = $"Area3D"
var hidden: bool = true

func _ready():
	label.text = text
	label.modulate = Color.TRANSPARENT
	label.outline_modulate =  Color.TRANSPARENT


func _process(delta):
	if hidden:
		label.modulate = lerp(label.modulate, Color.TRANSPARENT, 5 * delta)
		label.outline_modulate = lerp(label.outline_modulate, Color.TRANSPARENT, 5 * delta)
	else:
		label.modulate = lerp(label.modulate, Color.WHITE, 5 * delta)
		label.outline_modulate = lerp(label.outline_modulate, Color.BLACK, 5 * delta)
	pass


func _on_area_3d_body_entered(body):
	if body is CharacterController:
		hidden = false


func _on_area_3d_body_exited(body):
	if body is CharacterController:
		hidden = true

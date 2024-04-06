class_name Package
extends Node3D

@export var package_number:int = 1

@onready var mesh = $"package"
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	package_anim(delta)


func package_anim(delta):
	mesh.position.y = .5 + sin(timer * 2) * .25
	mesh.rotate(Vector3.UP, delta *  1)


func _on_area_3d_body_entered(body):
	if body is CharacterController:
		body.set_held_package(package_number)
		queue_free()

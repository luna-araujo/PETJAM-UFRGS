class_name RatCompound
extends Node3D

@export var compound_number: int = 1
@export_multiline var incomplete_text:String = ""
@export_multiline var complete_text:String = ""
@onready var area:Area3D = $"Area3D"
@onready var sign:Sign = $"Sign"

var complete_task:bool = false

signal task_completed

func _ready():
	sign.update_text(incomplete_text)

func _on_area_3d_body_entered(body):
	if body is CharacterController:
		if body.held_package == compound_number:
			body.set_held_package(0)
			complete_task = true
			task_completed.emit()
			sign.update_text(complete_text)
			($bonfire/SmokeParticles as GPUParticles3D).emitting = false;
		else:
			for package in get_tree().get_nodes_in_group("package"):
				if(package.package_number == compound_number):
					print(package.global_position);
					var package_direction = ((package as Node3D).global_position - global_position).normalized();
					DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.75, 0.0), global_position + Vector3(0.0, 2.75, 0.0) + package_direction * 3, Color("#ff0066"), 1.0,true,10.0);


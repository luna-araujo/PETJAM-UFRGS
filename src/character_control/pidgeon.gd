class_name Pidgeon
extends Node3D

@onready var package = $"Armature/Skeleton3D/Package/Package"

func set_package_visibility(value):
	package.visible = value

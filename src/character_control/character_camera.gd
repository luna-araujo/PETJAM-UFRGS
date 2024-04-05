extends Camera3D

@export var default_fov: float 
@export var max_fov: float
@export var camera_position: Vector3 = Vector3(0, 2, 4);

@onready var player: CharacterController = $"..";
@onready var caster: ShapeCast3D = $"../ShapeCast3D";

func _process(delta):
	collide_with_terrain(delta)
	update_fov(delta)

func update_fov(delta):
	var target_fov = lerpf(default_fov,max_fov, player.velocity.length() / player.MAX_VELOCITY)
	fov = lerpf(fov, target_fov, 10 * delta)

func collide_with_terrain(delta):
	var target = player.to_global(camera_position);
	caster.target_position = caster.to_local(target);
	caster.force_shapecast_update();
	var result;
	if caster.is_colliding():
		var fraction = caster.get_closest_collision_safe_fraction();
		var point = lerp(
			caster.global_position,
			caster.to_global(caster.target_position),
			fraction
		);
		result = player.to_local(point);
	else:
		result = player.to_local(target);
	position = result;

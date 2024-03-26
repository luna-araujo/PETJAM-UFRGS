extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SEN = 0.25;
const CAMERA_DIST = 3.0;

var yaw = 0.0
var pitch = 0.0
var player_front = Vector3(0.0,0.0,-1.0);

@onready var camera = $Camera3D;
@onready var collisionShape = $CollisionShape3D;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func update_camera_vectors():
	camera.transform.origin = Vector3(
		cos(PI * yaw/180) * cos(PI * pitch/180),
		sin(PI * pitch/180),
		sin(PI * yaw/180) * cos(PI * pitch/180)).normalized() * CAMERA_DIST + Vector3(0.0,1.0,0.0);
	camera.look_at(collisionShape.global_transform.origin, Vector3(0.0,1.0,0.0));
	player_front = (camera.global_transform.origin - collisionShape.global_transform.origin);
	player_front = Vector3(player_front.x, 0.0, player_front.z).normalized();

func update_model_vectors():
	pass
	#$".".look_at(player_front + global_transform.origin, Vector3(0.0,1.0,0.0));

func  _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
func _input(event):
	if event is InputEventMouseMotion:
		yaw += event.relative.x * MOUSE_SEN;
		pitch += -event.relative.y * MOUSE_SEN;
		pitch = clamp(pitch, -20, 89);
		print_debug(yaw, " ", pitch);
		update_camera_vectors();
		update_model_vectors();

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

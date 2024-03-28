extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const JOLT_FORCE = 0.75
const MOUSE_SEN = 0.25;
const CAMERA_DIST = 3.0;
const JOLT_COOLDOW = 0.5;
const WORLD_UP = Vector3(0.0,1.0,0.0);

var yaw = 0.0
var pitch = 0.0
var player_front = Vector3(0.0,0.0,-1.0);
var player_right;
var player_up;

var grounded = true;

var cur_force = Vector3(0.0,0.0,0.0);
var damp_amt = 0.9;
const VELOCITY_DAMP = 0.99;
const MAX_VELOCITY = 10.0;
var inertia = 0.0;

var current_stamina = 100.0
var jolt_cooldown = 1.0

@onready var collisionShape = $CollisionShape3D;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func process_grounded(delta):
	
	#reset stamina because on ground
	current_stamina = 100.0
	inertia = 0.0
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Handle jump.
	if Input.is_action_just_pressed("player_up") and grounded:
		if(!is_on_floor()):
			jolt_cooldown = JOLT_COOLDOW;
			velocity.y = -0.5;
			cur_force += (direction * 0.25 + Vector3(0.0,1.0,0.0)).normalized() * JOLT_FORCE; 
			grounded = false;
		else:
			velocity.y = JUMP_VELOCITY
	
	# Handle ground state	
	if(is_on_floor() and !grounded):
		grounded = true;		
		
	if !is_on_floor():
		velocity.y -= gravity * delta
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
func process_flying(delta):
	if(is_on_floor()):
		grounded = true;
		return;
		
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backwards");
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	
	if(Input.is_action_just_pressed("player_up") and jolt_cooldown - 0.000001 <= 0.0):
		jolt_cooldown = JOLT_COOLDOW;
		cur_force += (direction * 0.5 + Vector3(0.0,1.0,0.0)).normalized() * JOLT_FORCE; 
		
	velocity += -Vector3(0.0, gravity * delta, 0.0) + player_front * inertia;
	inertia = max(inertia + gravity * delta * player_front.dot(-WORLD_UP), gravity*delta/3);

	DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + player_front, Color("#ff6600"));
	DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + player_right, Color("#0066ff"));
	DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + player_up, Color("#00ff66"));
	
	velocity *= VELOCITY_DAMP;
	if(velocity.length() > MAX_VELOCITY):
		velocity = velocity.normalized() * MAX_VELOCITY;
	

func _process(delta):
	player_front = Vector3(
		cos(PI * yaw / 180) * cos(PI * pitch / 180),
		sin(PI * pitch / 180),
		sin(PI * yaw / 180) * cos(PI * pitch / 180)
	).normalized();
	$".".look_at(Vector3(global_position + player_front));
	player_right = player_front.cross(WORLD_UP).normalized();
	player_up = player_right.cross(player_front).normalized();
	
	if(grounded):
		process_grounded(delta);
	else:
		process_flying(delta);
	DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + velocity * 0.35, Color("#ff0066"));
	
	velocity += cur_force;
	cur_force *= damp_amt;

	jolt_cooldown = max(jolt_cooldown-delta, 0.0);

	print_debug(player_front.dot(-WORLD_UP));

	move_and_slide()

func  _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
func _input(event):
	if event is InputEventMouseMotion:
		yaw += event.relative.x * MOUSE_SEN;
		pitch += -event.relative.y * MOUSE_SEN;
		pitch = clamp(pitch, -89, 89);

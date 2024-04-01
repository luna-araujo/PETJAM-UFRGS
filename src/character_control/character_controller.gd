extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const JOLT_FORCE = 0.75
const MOUSE_SEN = 0.25;
const CAMERA_DIST = 3.0;
const JOLT_COOLDOW = 0.5;
const WORLD_UP = Vector3(0.0,1.0,0.0);
const VELOCITY_DAMP = 0.99;
const MAX_VELOCITY = 100.0;
const STAMINA_PASSIVE_DEP = -5.0;
const STAMINA_JOLT_DEP = 10.0;
const DRAG_COEF = 1.0;
const WEIGHT = 3.0;

var yaw = 0.0;
var pitch = 0.0;
var player_front = Vector3(0.0,0.0,-1.0);
var player_right;
var player_up;

@export var coef := 50.0;

var grounded = true;

var cur_force = Vector3(0.0,0.0,0.0);
var damp_amt = 0.9;
var mass = 1.0;

var current_stamina = 100.0
var jolt_cooldown = 1.0

@onready var collisionShape = $CollisionShape3D;
@onready var animator = $pidgeon/AnimationPlayer;
@onready var player_body = $pidgeon;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func can_jolt():
	return jolt_cooldown - 0.000001 <= 0.0 and current_stamina - 0.000001 > 0.0

func process_grounded(delta):
	
	if(velocity.length() > 0.0000001):
		player_body.look_at(Vector3(global_position + Vector3(velocity.x, 0.0, velocity.z).normalized()));
	else:
		player_body.look_at(Vector3(global_position + Vector3(player_front.x, 0.0, player_front.z).normalized()));
	#reset stamina because on ground
	if(is_on_floor()):
		current_stamina = move_toward(current_stamina, 100.0, 50.0 * delta * 10.0);
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Handle jump.
	if Input.is_action_just_pressed("player_up") and grounded:
		if(!is_on_floor() and can_jolt()):
			current_stamina -= STAMINA_JOLT_DEP;
			jolt_cooldown = JOLT_COOLDOW;
			#velocity.y = -0.5;
			animator.play("flap");
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
		animator.play("walk");
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
func process_flying(delta):
	if(!animator.is_playing()):
		animator.play("fly");
	
	player_body.look_at(Vector3(global_position + velocity.normalized()));
	var inertia = velocity.length() * WEIGHT;
	
	if(is_on_floor()):
		animator.play("RESET");
		grounded = true;
		return;
	if(current_stamina - 0.0000001 <= 0.0):
		inertia = 0.0;
		
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backwards");
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	
	if(Input.is_action_just_pressed("player_up") and can_jolt()):
		current_stamina = move_toward(current_stamina, 0.0, STAMINA_JOLT_DEP);
		jolt_cooldown = JOLT_COOLDOW;
		animator.play("flap");
		cur_force += (direction * 0.5 + Vector3(0.0,1.0,0.0)).normalized() * JOLT_FORCE; 
	
	
	velocity.y += -gravity * delta;

	var acc = (velocity.length() * player_front - velocity) * inertia * delta;
	velocity += acc; 

	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + player_front, Color("#ff6600"));
	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + player_right, Color("#0066ff"));
	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + player_up, Color("#00ff66"));
	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + acc, Color("#00ff66"));
	
	
	#print_debug(toHor, " ", toVer);
	#inertia = move_toward(inertia, 0.0, DRAG_COEF * delta)	
	current_stamina = clamp(current_stamina - STAMINA_PASSIVE_DEP * delta, 0.0, 100.0);
	velocity *= DRAG_COEF
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
	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + velocity * 0.35, Color("#ff0066"));
	
	velocity += cur_force;
	cur_force *= damp_amt;

	jolt_cooldown = max(jolt_cooldown-delta, 0.0);
	
	#print_debug(1.0 - abs(player_front.dot(WORLD_UP)));
	#print_debug((PI/180 * pitch));

	move_and_slide()

func  _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	animator.play("RESET");
	
func _input(event):
	if event is InputEventMouseMotion:
		yaw += event.relative.x * MOUSE_SEN;
		pitch += -event.relative.y * MOUSE_SEN;
		pitch = clamp(pitch, -89, 89);

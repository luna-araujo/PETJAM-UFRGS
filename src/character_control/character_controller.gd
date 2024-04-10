class_name CharacterController
extends CharacterBody3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var JOLT_FORCE = 0.75
const MOUSE_SEN = 0.25;
@export var JOLT_COOLDOW = 0.5;
const WORLD_UP = Vector3(0.0,1.0,0.0);
@export var VELOCITY_DAMP = 1.00;
@export var MAX_VELOCITY = 100.0;
@export var STAMINA_PASSIVE_DEP = -5.0;
@export var STAMINA_JOLT_DEP = 33.3;
@export var DRAG_COEF = 0.02;
@export var WEIGHT = 0.5;

var yaw = 0.0;
var pitch = 0.0;
var player_front = Vector3(0.0,0.0,-1.0);
var player_right;
var player_up;
var player_body_target;
@onready var last_player_grounded_position = position;

@onready var last_grounded_cooldow = 0.0;

@export var coef := 50.0;

var grounded = true;

var cur_force = Vector3(0.0,0.0,0.0);
var damp_amt = 0.9;
var mass = 1.0;

var current_stamina = 100.0;
var jolt_cooldown = 1.0;
var last_velocity: Vector3 = Vector3.ZERO;

var held_package:int = 0
var target_compond;

@onready var collisionShape = $CollisionShape3D;
@onready var anim_tree: AnimationTree = $pidgeon/AnimationTree;
@onready var player_body:Pidgeon = $pidgeon;

signal died;
signal flap;
signal water_hit;
signal solid_hit;

var time = 0.0;
var heights: Array[float];
var graph_size = 300;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func can_jolt():
	return jolt_cooldown - 0.000001 <= 0.0 and current_stamina - 0.000001 > 0.0

func process_grounded(delta):
	#print_debug(last_grounded_cooldow);
	last_grounded_cooldow -= delta; 
	if(last_grounded_cooldow <= 0.0):
		last_grounded_cooldow = 1.0;
		if(is_on_floor()):
			last_player_grounded_position = position;
	
	if(Vector3(velocity.x, 0.0, velocity.z).length() > 0.0000001):
		player_body_target = Vector3(velocity.x, 0.0, velocity.z).normalized();
	else:
		player_body_target = Vector3(player_front.x, 0.0, player_front.z).normalized();
	#reset stamina because on ground
	if(is_on_floor()):
		current_stamina = move_toward(current_stamina, 100.0, 50.0 * delta * 10.0);
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backwards")
	var direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y);
	direction = Vector3(direction.x, 0, direction.z).normalized();
	
	# Handle jump.
	if Input.is_action_just_pressed("player_up") and grounded:
		if(!is_on_floor() and can_jolt()):
			#current_stamina -= STAMINA_JOLT_DEP;
			flap.emit()
			jolt_cooldown = JOLT_COOLDOW;
			#velocity.y = -0.5;
			cur_force += (direction * 0.25 + Vector3(0.0,1.0,0.0)).normalized() * JOLT_FORCE; 
			grounded = false;
		elif(is_on_floor()):
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
	
	time += delta;
	last_grounded_cooldow = 1.0;
	
	if(velocity.normalized().dot(WORLD_UP) < 1.0):
		player_body_target = velocity.normalized();
	
	var inertia = velocity.length() * WEIGHT;
	if(cur_force.length() > 0.0000001):
		inertia = velocity.length() * 1.0;
	
	if(is_on_floor()):
		grounded = true;
		return;
	if(current_stamina <= 0.0000001):
		current_stamina = 0.0;
	else:
		current_stamina = clamp(current_stamina - STAMINA_PASSIVE_DEP * delta, 0.0, 100.0);
		
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backwards");
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	
	if(Input.is_action_just_pressed("player_up") and can_jolt()):
		flap.emit()
		current_stamina = move_toward(current_stamina, 0.0, STAMINA_JOLT_DEP);
		jolt_cooldown = JOLT_COOLDOW;
		if(Vector2(velocity.x, velocity.z).length() > 20.0):
			cur_force += WORLD_UP * JOLT_FORCE;
		else:
			cur_force += (direction * 0.5 + Vector3(0.0,1.0,0.0)).normalized() * JOLT_FORCE; 
	velocity.y += -gravity * delta;

	var acc = (velocity.length() * player_front - velocity) * clamp(inertia * delta, 0.0, 1.0);
	velocity += acc; 

	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + player_front, Color("#ff6600"));
	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + player_right, Color("#0066ff"));
	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + player_up, Color("#00ff66"));
	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + acc, Color("#00ff66"));
	
	# THIS IS THE COOLEST DEBUG OPTION
	#if(time >= 0.1):
		#time = 0.0;
		#for i in graph_size-1:
			#heights[i] = heights[i+1];
		#heights[graph_size-1] = position.y;
	#
	#var botLeft = position + player_front + player_up - player_right * 3;
	#var last_pos = botLeft + (player_up * heights[0] / 100);
	#for i in graph_size:
		#if(i == 0):
			#continue;
		#var cur_pos = botLeft + i / 50.0 * player_right + (player_up * heights[i] / 100);
		#DebugDraw3D.draw_line(last_pos, cur_pos, Color(1,1,1));
		#last_pos = cur_pos;
	#==========================================================================================
	
	#print_debug(toHor, " ", toVer);
	#inertia = move_toward(inertia, 0.0, DRAG_COEF * delta)	
	var true_coef = 1.0 / (DRAG_COEF * 1000);
	velocity = velocity - velocity * true_coef * delta;
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
	
	var player_body_cur = -player_body.get_global_transform().basis.z;
	var off = (player_body_target - player_body_cur) * 10.0 * delta;
	
	#var turn_amt = player_front_hor.dot(player_front_hor) * 0.5 + 0.5;
	
	var horz_variation = Vector3((player_front - player_body_cur).x, 0.0, (player_front - player_body_cur).z);
	
	var up = WORLD_UP;
	if(!grounded):
		up = WORLD_UP + horz_variation * 5.0 * (1.0-abs((player_front).dot(WORLD_UP)));
	
	player_body.look_at(player_body.global_position + player_body_cur + off, up.normalized());
	
	if(grounded):
		process_grounded(delta);
	else:
		process_flying(delta);
	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + velocity * 0.35, Color("#ff0066"));
	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + player_body_cur, Color("#ff0066"));
	#DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + player_front, Color("#6600FF"));
	if(held_package != 0):
		var package_direction = (target_compond - global_position).normalized();
		DebugDraw3D.draw_arrow(global_position + Vector3(0.0, 2.25, 0.0), global_position + Vector3(0.0, 2.25, 0.0) + package_direction, Color("#00FF66"));
		
	
	velocity += cur_force;
	cur_force *= damp_amt;

	jolt_cooldown = max(jolt_cooldown-delta, 0.0);
	
	#print_debug(1.0 - abs(player_front.dot(WORLD_UP)));
	#print_debug((PI/180 * pitch));

	move_and_slide()
	process_death()
	last_velocity = velocity	
	process_animations()

func  _ready():
	heights.resize(graph_size);
	print_debug("drag_coef is: ", 1.0 - 1.0 / (DRAG_COEF * 1000));
	player_body.set_package_visibility(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	player_body_target = Vector3(0.0,0.0,-1.0);
	
	
func _input(event):
	if event is InputEventMouseMotion:
		yaw += event.relative.x * MOUSE_SEN;
		pitch += -event.relative.y * MOUSE_SEN;
		pitch = clamp(pitch, -89, 89);
		
func process_animations():
	anim_tree["parameters/StateMachine/conditions/flap"] = jolt_cooldown > 0;
	anim_tree["parameters/StateMachine/conditions/no_flap"] = jolt_cooldown <= 0;
	anim_tree["parameters/StateMachine/conditions/flying"] = !grounded;
	anim_tree["parameters/StateMachine/conditions/idling"] = grounded && velocity.length() <= 0.01;
	anim_tree["parameters/StateMachine/conditions/walking"] = grounded && velocity.length() > 0.01;
	var player_body_cur = -player_body.get_global_transform().basis.z;
	anim_tree["parameters/StateMachine/fly/blend_position"] = player_body_cur.dot(-WORLD_UP);

func process_death():
	if (position.y < -0.25):
		died.emit(last_player_grounded_position);
		water_hit.emit()
		return;
	var col = get_last_slide_collision();
	if col:
		var body = col.get_collider() as StaticBody3D;
		var root = body.owner;
		if (last_velocity.length() > 20):
			if root.is_in_group("building"):
				var dot = col.get_normal().dot(-last_velocity.normalized());
				if (dot * last_velocity.length()) > 20:
					died.emit(last_player_grounded_position);
					solid_hit.emit()
		if body.is_in_group("barbed_wire"):
			solid_hit.emit()
			died.emit(last_player_grounded_position);
		elif body.is_in_group("water"):
			water_hit.emit()
			died.emit(last_player_grounded_position);

func _on_died(last_grounded: Vector3):
	grounded = true;
	velocity *= 0.0;
	position = last_grounded;

func set_held_package(package_number):
	held_package = package_number;
	if held_package == 0:
		player_body.set_package_visibility(false);
	else:
		for compond in get_tree().get_nodes_in_group("Compound"):
			if(compond.compound_number == package_number):
				target_compond = compond.global_position;
		player_body.set_package_visibility(true);


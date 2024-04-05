extends Node
class_name CharacterAudio

@export_group("Streams")
@export var flaps: Array[AudioStream]
@export var water_splashes: Array[AudioStream]
@export var solid_splashes: Array[AudioStream]

@onready var character: CharacterController = $".."
@onready var fly_wind_player: AudioStreamPlayer = $fly_wind
@onready var ambient_wind_player: AudioStreamPlayer = $ambient_wind

func _ready():
	ambient_wind_player.play()
	fly_wind_player.volume_db = -80
	fly_wind_player.play()

func _process(delta):
	if !ambient_wind_player.playing: ambient_wind_player.playing = true
	if !fly_wind_player.playing: fly_wind_player.playing = true
	fly_wind_player.volume_db = lerp(
		-80, 0,
		sqrt(clamp(character.velocity.length() / 30, 0, 1))
	)

func _on_character_controller_flap():
	if (flaps.size()):
		var flapStream = flaps.pick_random()
		spawn_audio(flapStream)

func _on_character_controller_water_hit():
	if (water_splashes.size()):
		var splashStream = water_splashes.pick_random()
		spawn_audio(splashStream)

func _on_character_controller_solid_hit():
	if (solid_splashes.size()):
		var splashStream = solid_splashes.pick_random()
		spawn_audio(splashStream)

func spawn_audio(stream: AudioStream):
	var player = AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.play()
	await get_tree().create_timer(stream.get_length()).timeout
	remove_child(player)

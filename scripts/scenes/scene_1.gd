extends Node3D

@export var scene_animation_player: AnimationPlayer

@export var player_side_camera: PhantomCamera3D
@export var player_front_camera: PhantomCamera3D
@export var vinod: Node3D

#@export var rightHandForearmHint: Node3D
#@export var leftHandForearmHint: Node3D

#@export var test_look: Node3D

var current_camera: PhantomCamera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# For instant camera switch
	player_side_camera.set_tween_duration(0)
	player_front_camera.set_tween_duration(0)
	
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	var player: Player = get_tree().get_first_node_in_group("player")
	player.story_mode = true
	player.model.position.y += 0.249
	
	player.animation_tree.active = false
	
	scene_animation_player.play("scene1_cutscene1")
	player.animation_player.play("Girl Animations/Girl_Scene1_Cutscene1")
	vinod.animation_player.play("Male Animations/Male_Scene1_Cutscene1")
	
	#player.leftHandForearmTarget.position = leftHandForearmHint.position
	#player.rightHandForearmTarget.position = rightHandForearmHint.position

	#player.leftHandForearmIK.start()
	#player.rightHandForearmIK.start()
	
	#player.headIK.start()
	
	player_side_camera.priority = 20
	current_camera = player_side_camera
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	#player.look_at_ik(test_look)

func enable_camera(camera_path: NodePath) -> void:
	var camera: PhantomCamera3D = get_node(camera_path)
	camera.priority = 20
	current_camera = camera

func disable_camera(camera_path: NodePath) -> void:
	var camera: PhantomCamera3D = get_node(camera_path)
	camera.priority = 0
	current_camera = null
	
func start_timeline(timeline: String) -> void:
	Dialogic.start(timeline)


func _on_dialogic_signal(argument:Dictionary):
	if argument["action_type"] == "camera_switch":
		var target_camera: PhantomCamera3D = get_node(argument["target_camera_path"])
		if current_camera:
			current_camera.priority = 0
			
		target_camera.priority = 20
		current_camera = target_camera
	elif argument["action_type"] == "audio":
		var stream = load(argument["file"])
		
		if !stream:
			print("Unable to audio stream!")
			return
			
		var audio_stream_player: AudioStreamPlayer3D
		if (argument["target"] == "vinod"):
			audio_stream_player = vinod.audio_stream_player
		elif argument["target"] == "meera":
			audio_stream_player = get_tree().get_first_node_in_group("player").audio_stream_player
			
		audio_stream_player.stream = stream
		audio_stream_player.play()

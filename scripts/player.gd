class_name Player
extends CharacterBody3D

@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer

@export var audio_stream_player: AudioStreamPlayer3D

@export var sensitivity_horizontal = 0.5
@export var sensitivity_vertical = 0.2
@export var walk_speed = 2.0
@export var run_speed = 5.0
@export var camera_pivot: Node3D
@export var third_person_camera: PhantomCamera3D

#@export var leftHandForearmIK: SkeletonIK3D
#@export var rightHandForearmIK: SkeletonIK3D
#@export var headIK: SkeletonIK3D

#@export var leftHandForearmTarget: Node3D
#@export var rightHandForearmTarget: Node3D
#@export var headTarget: Node3D

#@export var headUpDownRotationCorrection: float = 0.256

@export var story_mode = false

@onready var model: Node3D = $visuals

const JUMP_VELOCITY = 4.5

var speed = 2.0
var is_running = false
var basic_anim = 0.0
var is_aiming = false
var is_falling = false
var is_interacting: bool = false
var is_sitting_talk_left: bool = false
var is_sit_idle: bool = false
var is_typing: bool = false

func _ready() -> void:
	# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass
	
func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and !story_mode:
		rotate_y(-deg_to_rad(event.relative.x * sensitivity_horizontal))
		
		var pcam_rotation_degrees: Vector3

		# Assigns the current 3D rotation of the SpringArm3D node - so it starts off where it is in the editor
		pcam_rotation_degrees = third_person_camera.get_third_person_rotation_degrees()

		# Change the X rotation
		pcam_rotation_degrees.x -= event.relative.y * sensitivity_vertical

		# Clamp the rotation in the X axis so it go over or under the target
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, -45, 45)

		# Change the Y rotation value
		pcam_rotation_degrees.y -= event.relative.x * sensitivity_horizontal

		# Sets the rotation to fully loop around its target, but witout going below or exceeding 0 and 360 degrees respectively
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, 0, 360)

		# Change the SpringArm3D node's rotation and rotate around its target
		third_person_camera.set_third_person_rotation_degrees(pcam_rotation_degrees)
		
		if !is_aiming:
			# Making the model rotate in the opposite direction. So, the model looks like not rotating.
			model.rotate_y(deg_to_rad(event.relative.x * sensitivity_horizontal))
		
func _physics_process(delta: float) -> void:
	if story_mode:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if !is_interacting && Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Vector2.ZERO if is_interacting else Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	is_running = Input.is_action_pressed("run")
	is_aiming = Input.is_action_pressed("aim")
	
	is_falling = !is_on_floor()
		
	if is_running:
		speed = run_speed
	else:
		speed = walk_speed
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		if !is_aiming:
			var target_rotation = atan2(direction.x, direction.z) - rotation.y
			model.rotation.y = lerp_angle(model.rotation.y, target_rotation, 0.1)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
		
	if is_on_floor():
					
		var target_anim = 1.0 if input_dir != Vector2.ZERO else 0.0
		target_anim = target_anim * 2.0 if is_running else target_anim * 1
		basic_anim = lerpf(basic_anim, target_anim, 0.1)
		animation_tree.set("parameters/basic_movement/blend_position", basic_anim)
			
		# Strafe animations
		var animX = input_dir.x * 2 if is_running else input_dir.x
		var animY = input_dir.y * 2 if is_running else input_dir.y
			 
		animation_tree.set("parameters/aim_movement/blend_position", Vector2(animX, animY))		

	move_and_slide()

func notify_interactable(interactable: Interactable) -> void:
	pass
	
#func look_at_ik(object_to_look: Node3D) -> void:
	#var head_pos = headTarget.global_position
	#var target_pos = object_to_look.global_position
	#
	## Calculate the direction vector from head to target
	#var direction = target_pos - head_pos
	#
	## Since our model faces positive Z, we need to adjust our transform
	## We'll use the direction directly instead of negating it
	#var look_transform = Transform3D().looking_at(direction, Vector3.UP)
	#
	## Get the euler angles from the transform
	#var euler = look_transform.basis.get_euler()
	#
	## Apply clamping in radians (since we're working with radians now)
	#euler.x = -clamp(euler.x, -PI/4, PI/4)  # Up/down (about ±45 degrees)
	#euler.y = clamp(euler.y, -PI/2, PI/2)  # Left/right (about ±90 degrees)
	#euler.z = 0  # Keep head level
	#
	## The head target is kept on above the player head at a certain distance.
	## Now while rotating the head up/down we should consider the those
	## gap. Otherwise the head rotation will be too high for the target
	## on either side up/down.
	#euler.x -= headUpDownRotationCorrection
		#
	## Create a new basis from the euler angles and apply it
	#headTarget.basis = Basis().from_euler(euler)

	

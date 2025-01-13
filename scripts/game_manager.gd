extends Node3D

var main_scene: Node3D
var current_scene: Node

func start() -> void:
	# This should be start menu something like that.
	load_scene("scene1")
	print("Loaded Scene1")

func unload_current_scene() -> void:
	if is_instance_valid(current_scene):
		current_scene.queue_free()
	current_scene = null
	
func load_scene(scene_name: String) -> void:
	unload_current_scene()
	var scene_path = "res://scenes/level-scenes/%s.tscn" % scene_name
	var scene_resource = load(scene_path)
	if scene_resource:
		current_scene = scene_resource.instantiate()
		main_scene.add_child(current_scene)
		

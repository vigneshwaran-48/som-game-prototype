extends Node3D

@onready var main_scene: Node3D = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.main_scene = main_scene
	GameManager.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

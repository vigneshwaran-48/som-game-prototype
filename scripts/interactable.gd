class_name Interactable
extends Area3D

@export var display_text: String
@export var is_interactable: bool = true

var interact: Callable = func(player: Player):
	pass

func disable_interaction() -> void:
	is_interactable = false
	InteractionManager.unregister_interactable(self)
	
func enable_interacation() -> void:
	is_interactable = true

func _on_body_entered(body: Node3D) -> void:
	if is_interactable:
		InteractionManager.register_interactable(self)

func _on_body_exited(body: Node3D) -> void:
	InteractionManager.unregister_interactable(self)

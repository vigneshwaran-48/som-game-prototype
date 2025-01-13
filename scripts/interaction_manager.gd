extends Node
class_name InteracationManager

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var label: Label = %Label

var interactables: Array[Interactable] = []
var canInteract: bool = true

func register_interactable(interactable: Interactable):
	interactables.push_back(interactable)
	
func unregister_interactable(interactable: Interactable):
	var index = interactables.find(interactable)
	if index != -1:
		interactables.remove_at(index)
	
func sort_interactables(interactable1, interactable2) -> bool:
	var distToPlayerFor1 = player.global_position.distance_to(interactable1.global_position)
	var distToPlayerFor2 = player.global_position.distance_to(interactable2.global_position)
	return distToPlayerFor1 < distToPlayerFor2
	
		
func _process(delta: float) -> void:
	if interactables.size() > 0:
		interactables.sort_custom(sort_interactables)
		label.text = interactables[0].display_text
		label.show()
	else:
		label.hide()
	
func _input(event: InputEvent) -> void:
	if interactables.size() > 0 && event.is_action_pressed("interact") && canInteract:
		canInteract = false
		label.hide()
		
		await interactables[0].interact.call(player)
		
		canInteract = true
		

class_name InteractMinigame
extends Interact


@export var minigame_scene: String


func _on_interact():
	interactable.finish_interact()
	TransitionManager.global.transition_to("minigames/" + minigame_scene)

extends Node2D


func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	MinigameManager.global.minigame_complete(true)
	TransitionManager.global.transition_to("map")

extends Node2D


func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	TransitionManager.global.transition_to("map")

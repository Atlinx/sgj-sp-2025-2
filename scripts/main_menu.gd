class_name MainMenu
extends Control


@export var _start_button: Button
@export var _quit_button: Button


func _ready() -> void:
	_start_button.pressed.connect(TransitionManager.global.transition_to.bind("map"))
	_quit_button.pressed.connect(get_tree().quit)

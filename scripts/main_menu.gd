class_name MainMenu
extends Control


@export var _start_button: Button
@export var _quit_button: Button


func _ready() -> void:
	_start_button.pressed.connect(_on_start_pressed)
	_quit_button.pressed.connect(get_tree().quit)


func _on_start_pressed():
	GameManager.global.reset()
	TransitionManager.global.transition_to("map")

class_name DefaultAnimationPlayer
extends AnimationPlayer


@export var default_animation: String


func _ready() -> void:
	if default_animation != "":
		play(default_animation)

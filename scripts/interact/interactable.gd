class_name Interactable
extends Node2D


signal interact_finished()
signal interacted()


@export var is_oneshot: bool

var is_interacting: bool


func interact():
	is_interacting = true
	interacted.emit()


func finish_interact():
	if is_interacting:
		is_interacting = false
		interact_finished.emit()
		if is_oneshot:
			visible = false

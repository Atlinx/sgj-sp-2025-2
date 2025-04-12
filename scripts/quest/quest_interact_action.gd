@icon("res://assets/sprites/target.png")
class_name QuestInteractAction
extends QuestAction


enum Mode {
	NONE,
	ONE_FINISHED,
	ALL_FINISHED,
}


# Stores interactables as its children
@export var mode: Mode

var finished_count: int = 0
var interactable_count: int = 0


func _ready():
	super._ready()
	for child in get_children():
		if child is Interactable:
			interactable_count += 1
			child.interact_finished.connect(_on_interact_finished)


func _on_interact_finished():
	finished_count += 1
	if mode == Mode.ALL_FINISHED and finished_count == interactable_count:
		# All children are finished
		complete()
	elif mode == Mode.ONE_FINISHED:
		# One interactable finished, let's advance
		complete()

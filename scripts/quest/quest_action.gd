@icon("res://assets/sprites/target.png")
class_name QuestAction
extends Node2D


signal completed()


var action_name: String
@export_multiline var description: String
# Will completing this action count as completing the quest?
@export var is_terminal: bool
# Actions that this action depends on
@export var prereq_actions: Array[String]
# Set of actions that are mutually exclusive from each other
# If one action is chosen, the remaining actions are locked out
@export var choice_actions: Array[String]
# Maps a set name to a set of prereqs that must be satisfied together
# { "path1": [name1, name2], "path2": [name3, name4], "path3": [name5] }
#
# Each sub-array is a set of prereqs that must be satisfied together
# However if just one of the sub-arrays is satsfied, then
# we're allowed to take this action.
#
# This effectively lets us model branching actions.
var prereq_sets: Dictionary[String, Array]
var disabled: bool = false

# TODO NOW: Add exclusive prereqs


func _ready() -> void:
	action_name = name
	y_sort_enabled = true
	prereq_sets = {}
	for action in prereq_actions:
		var res = action.split(":")
		var set_name = ""
		if res.size() >= 2:
			set_name = res[1]
		if not set_name in prereq_sets:
			prereq_sets[set_name] = []
		prereq_sets[set_name].append(res[0])


func complete():
	completed.emit()

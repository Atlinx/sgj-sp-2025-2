@icon("res://assets/sprites/target_quest.png")
class_name Quest
extends Resource


signal quest_started()
signal quest_completed()
signal action_completed()


@export var name: String
@export_multiline var description: String
@export var prerequisites: Array[Quest]

# Maps active actions to descriptions
var active_actions: Dictionary[String, String]
var started: bool
var completed: bool

var _completed_actions: Dictionary[String, bool]


func _init() -> void:
	active_actions = {}
	_completed_actions = {}


# Accepts
# 	a set of prerequsities in Array[String]
# 	OR a set of multiple prerequisite sets Dictionary[String, Array]
func are_action_prereqs_satisfied(action_prerequisites):
	if action_prerequisites.size() == 0:
		return true
	if typeof(action_prerequisites) == TYPE_ARRAY:
		for action in action_prerequisites:
			if action not in _completed_actions:
				return false
		return true
	elif typeof(action_prerequisites) == TYPE_DICTIONARY:
		for prereqs_set in action_prerequisites.values():
			if are_action_prereqs_satisfied(prereqs_set):
				return true
		return false
	return false


func add_active_action(action: String, description: String):
	active_actions[action] = description


func add_completed_action(action: String, is_terminal: bool = false):
	_completed_actions[action] = true
	active_actions.erase(action)
	action_completed.emit()
	if is_terminal:
		completed = true
		quest_completed.emit()


func is_action_completed(action: String) -> bool:
	return _completed_actions.has(action)


func get_completed_actions() -> Array[String]:
	return _completed_actions.keys()


func start():
	started = true
	quest_started.emit()


func reset():
	started = false
	completed = false
	_completed_actions.clear()
	active_actions.clear()

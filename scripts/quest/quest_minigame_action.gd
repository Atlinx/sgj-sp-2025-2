@icon("res://assets/sprites/target.png")
class_name QuestMinigameAction
extends QuestAction


enum Mode {
	COMPLETE,
	LOST,
	WON,
}


# Stores interactables as its children
@export var mode: Mode
@export var minigame: String
@export_category("Dependencies")
@export var _interact_minigame: InteractMinigame


func _ready():
	super._ready()
	# visibility_changed.connect(_on_visibility_changed)
	# Query to see if our new minigame was completed
	_interact_minigame.minigame_scene = minigame


func enable_action():
	await get_tree().process_frame
	# Try reading our query if this isn't our first time loading the action
	var unique_name = quest_runner.name + "/" + action_name
	var result = MinigameManager.global.get_minigame_result_query(unique_name)
	if result.size() > 0:
		_check_completed(result[0]["minigame"], result[0]["win"])
	# Add listener to MinigameManager, if it doesn't exist
	MinigameManager.global.add_minigame_result_query(unique_name)


func _check_completed(_minigame: String, win: bool):
	if _minigame == minigame:
		if mode == Mode.WON and win:
			complete()
		elif mode == Mode.LOST and not win:
			complete()
		elif mode == Mode.COMPLETE:
			complete()

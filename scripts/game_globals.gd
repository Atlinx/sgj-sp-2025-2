extends Node


var game_manager: GameManager
var transition_manager: TransitionManager
var quest_manager: QuestManager


func _ready() -> void:
	game_manager = GameManager.global
	transition_manager = TransitionManager.global
	quest_manager = QuestManager.global


func transition_to(scene: String):
	transition_manager.transition_to(scene)
	transition_manager.on_transition_out.connect(Dialogic.end_timeline, CONNECT_ONE_SHOT)

class_name GameManager
extends Node


signal on_save_state()
signal on_load_state()


static var global: GameManager

# Persistent data
@export var map_player_tilepos: Vector2i
@export_category("Dependencies")
@export var _transition_manager: TransitionManager

var quests: Array[Quest]

var _initialized: bool


func _enter_tree() -> void:
	if _initialized:
		return
	_initialized = true
	if global != null:
		queue_free()
		return
	global = self


func _ready() -> void:
	reparent.call_deferred(get_tree().root)
	_transition_manager.on_transition_out.connect(on_save_state.emit)
	_transition_manager.on_transition_in.connect(on_load_state.emit)
	# Load default style
	Dialogic.Styles.load_style()
	Dialogic.Styles.get_layout_node().visible = false
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	
	for file_name in DirAccess.get_files_at("res://quests/"):
		if file_name.get_extension() == "import":
			file_name = file_name.replace('.import', '')
			var quest = load("res://quests/" + file_name)
			if quest is Quest:
				quests.append(quest)


func reset():
	map_player_tilepos = Vector2i(0, -1)
	for quest in quests:
		quest.reset()


func _on_timeline_started():
	Dialogic.Styles.get_layout_node().visible = true


func _on_timeline_ended():
	await Dialogic.clear(DialogicGameHandler.ClearFlags.FULL_CLEAR)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if global == self:
			global = null

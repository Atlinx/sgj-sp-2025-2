class_name GameManager
extends Node


signal on_save_state()
signal on_load_state()


static var global: GameManager

# Persistent data
@export var map_player_tilepos: Vector2i
@export_category("Dependencies")
@export var _transition_manager: TransitionManager

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


func _on_timeline_started():
	Dialogic.Styles.get_layout_node().visible = true


func _on_timeline_ended():
	await Dialogic.clear(DialogicGameHandler.ClearFlags.FULL_CLEAR)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if global == self:
			global = null

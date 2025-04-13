class_name MinigameManager
extends Node


signal minigame_completed(minigame: String, win: bool)

static var global: MinigameManager

var last_minigame: String
var last_minigame_win: bool

# Map id -> Array of results
var _minigame_result_queries: Dictionary[String, Array] = {}
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
	if global != self:
		return
	reparent.call_deferred(get_tree().root)
	# Load default style
	Dialogic.Styles.load_style()
	Dialogic.Styles.get_layout_node().visible = false


# If result, return this array of results
# [{
#   "minigame": "minigame_1",
# 	"win": true
# }]
# If no result, return empty array
# []
func get_minigame_result_query(id: String) -> Array:
	if id in _minigame_result_queries:
		var res = _minigame_result_queries[id]
		_minigame_result_queries.erase(id)
		return res
	else:
		return []


func add_minigame_result_query(id: String):
	if id in _minigame_result_queries:
		return
	_minigame_result_queries[id] = []


func minigame_complete(win: bool = true):
	if TransitionManager.global.is_transitioning:
		# Bail if we are already transitioning
		return
	last_minigame = TransitionManager.global.current_scene
	last_minigame_win = win
	for id in _minigame_result_queries:
		_minigame_result_queries[id].append({
			"minigame": last_minigame,
			"win": last_minigame_win	
		})
	minigame_completed.emit(last_minigame, win)
	TransitionManager.global.transition_to("map")


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if global == self:
			global = null

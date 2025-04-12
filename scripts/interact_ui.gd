class_name InteractUI
extends Label


static var global: InteractUI

var _initialized: bool
var _in_dialogue: bool
var _visible: bool


func _enter_tree() -> void:
	if _initialized:
		return
	_initialized = true
	if global != null:
		queue_free()
		return
	global = self
	visible = false


func _ready() -> void:
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)


func _on_timeline_started():
	_in_dialogue = true
	_update_visuals()


func _on_timeline_ended():
	_in_dialogue = false
	await get_tree().create_timer(0.2).timeout
	_update_visuals()


func set_interact(interact_text: String):
	interact_text = interact_text.strip_edges()
	if interact_text.length() == 0:
		interact_text = "interact"
	text = "Press E to " + interact_text
	_visible = true
	_update_visuals()


func _update_visuals():
	visible = _visible and not _in_dialogue


func hide_interact():
	_visible = false
	_update_visuals()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if global == self:
			global = null

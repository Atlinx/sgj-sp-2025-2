class_name TransitionManager
extends Node


static var global: TransitionManager


@export var _overlay_texture: OverlayTexture
@export var _transition_in_sfx: RandomAudioStreamPlayer
@export var _transition_out_sfx: RandomAudioStreamPlayer
@export var _loading_label: Control
@export var _canvas_layer: CanvasLayer

var _initialized: bool
var _trans_tween: Tween


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
	_overlay_texture.set_fill_amount(0.0)
	_loading_label.modulate.a = 0.0
	_canvas_layer.visible = true


func _tween_bgm(amount: float):
	var bgm_idx = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_volume_db(bgm_idx, amount)


func transition_to(scene: PackedScene):
	if _trans_tween:
		_trans_tween.kill()
	_trans_tween = create_tween()
	_trans_tween.tween_method(_tween_bgm, 0.0, -999, 0.5)
	_trans_tween.tween_method(_overlay_texture.set_fill_amount, 0.0, 1.0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_trans_tween.tween_interval(0.2)
	_trans_tween.tween_property(_loading_label, "modulate", Color(Color.WHITE, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_transition_in_sfx.play_random(0.2)
	await _trans_tween.finished
	get_tree().change_scene_to_packed(scene)
	await get_tree().create_timer(0.25).timeout
	_trans_tween = create_tween()
	_trans_tween.tween_property(_loading_label, "modulate", Color(Color.WHITE, 0.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_trans_tween.tween_interval(0.2)
	_trans_tween.tween_method(_tween_bgm, -999, 0.0, 0.3)
	_trans_tween.tween_method(_overlay_texture.set_fill_amount, 1.0, 0.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_transition_out_sfx.play_random(0.4)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if global == self:
			global = null

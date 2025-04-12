class_name Interactable
extends Node2D


signal interact_finished()
signal interacted()


@export var interact_phrase: String
@export var is_oneshot: bool
@export_category("Dependencies")
@export var _collision_shape: CollisionShape2D

var is_interacting: bool


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed():
	_collision_shape.disabled = not visible


func interact():
	if is_interacting:
		return
	is_interacting = true
	interacted.emit()


func finish_interact():
	if is_interacting:
		is_interacting = false
		interact_finished.emit()
		if is_oneshot:
			visible = false

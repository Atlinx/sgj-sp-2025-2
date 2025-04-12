class_name Interact
extends Node2D


var interactable: Interactable


func _ready() -> void:
	var parent = get_parent() as Interactable
	assert(parent != null) 
	interactable = parent
	interactable.interacted.connect(_on_interact)


func _on_interact():
	pass

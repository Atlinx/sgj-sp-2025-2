class_name Interact
extends Node2D



func _ready() -> void:
	var parent = get_parent() as Interactable
	assert(parent != null) 
	parent.on_interact.connect(_on_interact)


func _on_interact():
	pass

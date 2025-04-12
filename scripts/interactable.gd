class_name Interactable
extends Node2D


signal on_interact()


func interact():
	on_interact.emit()

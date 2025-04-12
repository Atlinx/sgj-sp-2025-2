extends Node2D
class_name Litter

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("hand"):
		area.get_parent().get_parent().score +=1
		queue_free()

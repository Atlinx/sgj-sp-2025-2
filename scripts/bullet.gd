extends CharacterBody2D
class_name Bullet


func _physics_process(delta: float) -> void:
	position += velocity * delta



func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("hitbox"):
		queue_free()


func _on_dead_time_timeout() -> void:
	queue_free()

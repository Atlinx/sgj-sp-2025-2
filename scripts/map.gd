class_name Map
extends Node2D


static var global: Map


@export var _bg_layer: TileMapLayer 


func map_to_local(cell: Vector2) -> Vector2:
	return Vector2(_bg_layer.tile_set.tile_size) * cell


func map_to_local_center(cell: Vector2i) -> Vector2:
	return _bg_layer.map_to_local(cell)


func local_to_map(pos: Vector2) -> Vector2i:
	return _bg_layer.local_to_map(pos)


func _enter_tree() -> void:
	if global != null:
		queue_free()
		return
	global = self


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if global == self:
			global = null

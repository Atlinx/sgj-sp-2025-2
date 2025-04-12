class_name Map
extends Node2D


static var global: Map


@export var _bg_layer: TileMapLayer 
@export var _invisible_wall_layer: TileMapLayer


func _ready() -> void:
	_invisible_wall_layer.visible = false


func map_to_local(cell: Vector2) -> Vector2:
	return Vector2(_bg_layer.tile_set.tile_size) * cell


func map_to_local_center(cell: Vector2i) -> Vector2:
	return _bg_layer.map_to_local(cell)


# Returns whether a tile is empty and the player 
# can move onto the tile
func is_tile_empty(cell: Vector2i):
	return _invisible_wall_layer.get_cell_source_id(cell) == -1


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

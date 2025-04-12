extends Node
class_name PickUpLitterGame

@export var level_layer : TileMapLayer
@export var litter_scenes : Array[PackedScene]
@export var litter_amounts : int

func _ready() -> void:
	var used_cells = level_layer.get_used_cells_by_id(0)
	used_cells.shuffle()
	
	var spawn_count = min(litter_amounts, used_cells.size())
	
	# 获取图块尺寸并转换为浮点向量
	var tile_size := Vector2(level_layer.tile_set.tile_size) if level_layer.tile_set else Vector2.ZERO
	
	for i in range(spawn_count):
		var cell_pos = used_cells[i]
		var litter_scene = litter_scenes.pick_random()
		var litter = litter_scene.instantiate()
		
		# 转换坐标并添加偏移
		var local_pos = level_layer.map_to_local(cell_pos)
		var world_pos = level_layer.to_global(local_pos)
		
		# 正确类型转换（Vector2 + Vector2）
		litter.global_position = world_pos + (tile_size / 2)
		
		add_child(litter)

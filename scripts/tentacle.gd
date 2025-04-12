class_name Tentacle
extends Line2D

# 配置参数
@export var max_length: float = 500.0
@export var fade_time: float = 0.5
@export var retract_speed_multiplier: float = 1.2
@export var collision_shape: CollisionShape2D
@export var sprite2D: Sprite2D

# 运行时变量
var target_pos: Vector2
var _tween: Tween

func _ready():
	# 初始化线段
	clear_points()
	add_point(Vector2.ZERO)
	add_point(Vector2.ZERO)
	width = 8.0
	default_color = Color(0.8, 0.2, 0,0)
	
	# 初始化碰撞体
	if collision_shape:
		collision_shape.shape = SegmentShape2D.new()
		
	
	# 配置精灵默认参数
	if sprite2D:
		sprite2D.centered = true
		sprite2D.rotation_degrees = 0

func init_tentacle(start_pos: Vector2, end_pos: Vector2, speed: float):
	global_position = start_pos
	var direction = (end_pos - start_pos).normalized()
	var distance = min(start_pos.distance_to(end_pos), max_length)
	target_pos = start_pos + direction * distance
	
	var extend_time = distance / speed
	var retract_time = distance / (speed * retract_speed_multiplier)
	
	# 创建动画序列
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_method(_update_tentacle.bind(extend_time), 0.0, 1.0, extend_time)
	_tween.tween_method(_update_tentacle.bind(retract_time), 1.0, 0.0, retract_time)
	_tween.tween_property(self, "modulate:a", 0.0, fade_time)
	_tween.tween_callback(_on_animation_complete)

func _update_tentacle(progress: float, duration: float):
	# 更新线段终点
	var end_point = Vector2.ZERO.lerp(to_local(target_pos), progress)
	set_point_position(1, end_point)
	
	# 更新碰撞体
	_update_collision_shape(end_point)
	
	# 更新精灵
	_update_sprite(end_point)

func _update_collision_shape(end_point: Vector2):
	if collision_shape and collision_shape.shape is SegmentShape2D:
		collision_shape.shape.a = Vector2.ZERO
		collision_shape.shape.b = end_point
		collision_shape.position = end_point / 2

func _update_sprite(end_point: Vector2):
	if not sprite2D or not sprite2D.texture:
		return
	
	var length = end_point.length()
	if length <= 0:
		sprite2D.scale = Vector2.ZERO
		return
	
	# 计算方向参数
	var direction = end_point.normalized()
	var angle = end_point.angle()
	
	# 设置精灵变换
	sprite2D.position = end_point / 2
	sprite2D.rotation = angle
	
	# 计算缩放比例
	var tex_size = sprite2D.texture.get_size()
	if tex_size.x <= 0 or tex_size.y <= 0:
		return
	
	var target_width = length
	var target_height = width  # 使用Line2D的粗细值
	
	var scale_x = target_width / tex_size.x
	var scale_y = target_height / tex_size.y
	
	# 保持原始宽高比（如需拉伸可去掉这行）
	#scale_y = scale_x if sprite2D.region_rect.size.y == 0 else scale_y
	
	sprite2D.scale = Vector2(scale_x, scale_y)

func _on_animation_complete():
	queue_free()

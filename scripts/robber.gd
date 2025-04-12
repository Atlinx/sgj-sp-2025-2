class_name Robber
extends Node2D

@export var _flip_sprite: Node2D
@export var _anim_player: AnimationPlayer
@export var fire_point: Marker2D  # 添加发射点节点

@export var horizontal_speed: float = 64
@export var vertical_speed: float = 80.0
@export var min_y: float = -100
@export var max_y: float = 100
@export var min_wait_time: float = 1.0
@export var max_wait_time: float = 3.0
@export var fire_interval: float = 2.0  # 新增射击间隔
@export var bullet_speed: float = 300.0  # 新增子弹速度

@export var bullet : PackedScene
@export var litter_scenes : Array[PackedScene]

var flip_tween: Tween
var move_tween: Tween
var tile_position: Vector2i
var facing_right: bool = true
@export var _player: Node2D  # 存储玩家引用

@onready var _timer: Timer = $Timer
@onready var shoot_timer: Timer = $ShootTimer  # 新增射击计时器
@export var throw_distance_range: Vector2 = Vector2(150, 300)  # 抛掷距离随机范围


# 新增控制参数
@export var throw_height: float = 100.0      # 最大抛射高度
@export var throw_duration_range: Vector2 = Vector2(0.8, 1.2) # 抛射持续时间范围
@export var rotation_speed_range: Vector2 = Vector2(2.0, 5.0) # 旋转速度范围（弧度/秒）

func _ready() -> void:
	$ShootTimer.wait_time = randf_range(0.6,1.4)
	$LitterTimer.wait_time = randf_range(0.6,1.4)
	
	
	
	#tile_position = Map.global.local_to_map(position)
	#position = Map.global.map_to_local_center(tile_position)
	_flip_sprite.scale.x = 1  
	randomize()
	_setup_timer()
	_anim_player.play("move")
	# 初始时设置一个随机目标Y
	_update_vertical_target()
	shoot_timer.wait_time = fire_interval
	shoot_timer.start()

func _process(delta: float) -> void:
	print(global_position.x)
	if global_position.x > 7500:
		return
	# 只处理水平移动
	position += Vector2.RIGHT * horizontal_speed * delta
	#tile_position = Map.global.local_to_map(position)



func _setup_timer():
	_timer.wait_time = randf_range(min_wait_time, max_wait_time)
	_timer.start()

func _update_vertical_target():
	var safe_min = min_y + (max_y - min_y) * 0.1
	var safe_max = max_y - (max_y - min_y) * 0.1
	var target_y = randf_range(safe_min, safe_max)
	
	# 创建垂直移动的Tween
	if move_tween:
		move_tween.kill()
	
	move_tween = create_tween()
	var duration = abs(target_y - position.y) / vertical_speed
	move_tween.tween_property(self, "position:y", target_y, duration)
	move_tween.set_ease(Tween.EASE_IN_OUT)

func _on_timer_timeout():
	_update_vertical_target()
	_setup_timer()

func _shoot():
	if !_player or !bullet:
		return
	var distance = _player.global_position - global_position
	
	if distance.length_squared() < 4000:
		return
	# 创建子弹实例
	var bullet_instance = bullet.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	
	# 设置子弹初始位置
	bullet_instance.global_position = fire_point.global_position
	

	# 计算射击方向
	var direction = (_player.global_position - global_position).normalized()
	
	# 设置子弹速度和旋转
	bullet_instance.velocity = direction * bullet_speed
	bullet_instance.rotation = direction.angle()

func _on_shoot_timer_timeout():
	var times : int = 0
	var ran_int : int = randi_range(2,5)
	while times < ran_int:
		_shoot()
		times += 1
		await get_tree().create_timer(0.2).timeout
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("hand"):
		queue_free()
		pass



func throw_litter():
	if !_player || litter_scenes.is_empty():
		return
	
	# 生成目标位置（玩家右侧随机点）
	var target_pos = Vector2(
		_player.global_position.x + randf_range(150, 300),
		clamp(_player.global_position.y + randf_range(-50, 50), min_y, max_y)
	)
	
	# 实例化垃圾
	var litter : Litter = litter_scenes.pick_random().instantiate()
	litter.add_to_group("litter")
	get_parent().add_child(litter)
	litter.global_position = fire_point.global_position
	
	# 创建Tween动画
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	var duration = randf_range(throw_duration_range.x, throw_duration_range.y)
	
	# 水平移动（X轴）
	tween.parallel().tween_property(litter, "position:x",
		litter.position.x + (target_pos.x - litter.global_position.x),
		duration
	)
	
	# 抛物线垂直移动（Y轴）
	var start_y = litter.position.y
	var peak_y = start_y - throw_height * randf_range(0.8, 1.2)
	var final_y = litter.position.y + (target_pos.y - litter.global_position.y)
	
	tween.parallel().tween_method(
		func(t: float):
			# 二次贝塞尔曲线模拟抛物线
			var current_y = start_y + (final_y - start_y) * t
			current_y += sin(t * PI) * (peak_y - start_y) * 1.5  # 增强曲线效果
			litter.position.y = current_y,
		0.0, 1.0, duration
	)
	
	# 随机旋转动画
	var rotation_speed = randf_range(rotation_speed_range.x, rotation_speed_range.y)
	var target_rotation = litter.rotation + randf_range(-PI, PI)
	tween.parallel().tween_property(litter, "rotation",
		target_rotation,
		duration
	).as_relative()
	
	# 动画完成后自动删除
	tween.tween_callback(litter.land)


func calculate_target_position() -> Vector2:
	# 确保目标在玩家右侧且y在范围内
	var base_x = _player.global_position.x + randf_range(throw_distance_range.x, throw_distance_range.y)
	var target_y = clamp(
		_player.global_position.y + randf_range(-50, 50),
		min_y,
		max_y
	)
	return Vector2(base_x, target_y)

func calculate_parabola_velocity(start: Vector2, end: Vector2, angle: float, speed: float) -> Vector2:
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	var delta = end - start
	
	# 计算水平距离
	var horizontal_distance = delta.x
	if abs(horizontal_distance) < 0.1:
		return Vector2.ZERO  # 防止除以零
	
	# 计算飞行时间
	var flight_time = (2 * speed * sin(angle)) / gravity
	
	# 分解速度分量
	var velocity_x = speed * cos(angle) * sign(delta.x)
	var velocity_y = -speed * sin(angle)
	
	# 调整水平速度确保到达目标
	velocity_x = horizontal_distance / flight_time
	
	return Vector2(velocity_x, velocity_y)


func _on_litter_timer_timeout() -> void:
	throw_litter()

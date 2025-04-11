class_name AutoNPC
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

var flip_tween: Tween
var move_tween: Tween
var tile_position: Vector2i
var facing_right: bool = true
@export var _player: Node2D  # 存储玩家引用

@onready var _timer: Timer = $Timer
@onready var shoot_timer: Timer = $ShootTimer  # 新增射击计时器

func _ready() -> void:
	tile_position = Map.global.local_to_map(position)
	position = Map.global.map_to_local_center(tile_position)
	_flip_sprite.scale.x = 1  
	randomize()
	_setup_timer()
	_anim_player.play("move")
	# 初始时设置一个随机目标Y
	_update_vertical_target()
	shoot_timer.wait_time = fire_interval
	shoot_timer.start()

func _process(delta: float) -> void:
	# 只处理水平移动
	position += Vector2.RIGHT * horizontal_speed * delta
	tile_position = Map.global.local_to_map(position)

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
	print(distance.x ** 2 + distance.y**2)
	if distance.x ** 2 + distance.y**2 < 2000:
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
	while times < 3:
		_shoot()
		times += 1
		await get_tree().create_timer(0.2).timeout
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("hitbox"):
		queue_free()

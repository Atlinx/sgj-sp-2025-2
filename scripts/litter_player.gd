# MapPlayer.gd
class_name LitterPlayer
extends CharacterBody2D

@export var _flip_sprite: Node2D
@export var _anim_player: AnimationPlayer
@export var tentacle_scene: PackedScene  # 触手预制场景
@export var inertia_factor: float = 0.2  # 惯性影响系数
@export var tentacle_speed: float = 800.0  # 触手伸展速度
var score : int
var flip_tween: Tween
var move_tween: Tween
var tile_position: Vector2i
var facing_right: bool
var is_moving: bool
var prev_input_dir: Vector2
var move_start_tile_position: Vector2i
var press_time: float
var extending_tenta : bool = false

# 新增速度跟踪相关变量

var _prev_position: Vector2 = Vector2.ZERO

const INPUT_DIRS = {
	"p1_up": Vector2.UP,
	"p1_down": Vector2.DOWN,
	"p1_left": Vector2.LEFT,
	"p1_right": Vector2.RIGHT,
}

const DEAD_ZONE = 0.01

func _ready() -> void:
	#tile_position = Map.global.local_to_map(position)
	#position = Map.global.map_to_local(tile_position)
	_anim_player.play("idle")
	_prev_position = position

func _process(delta: float) -> void:
	$"../../CanvasLayer/Label".text = "score: "+str(score)

	# 计算当前速度
	velocity = (position - _prev_position) 
	_prev_position = position
	
	# 原有移动逻辑
	var input_dir = Vector2.ZERO
	for input in INPUT_DIRS:
		if Input.is_action_pressed(input):
			input_dir += INPUT_DIRS[input]
	
	if input_dir.is_zero_approx():
		if is_moving:
			_anim_player.play("idle")
			is_moving = false
			if press_time <= 0.1:
				var axis_dir = Vector2i.ZERO
				if prev_input_dir.x > DEAD_ZONE:
					axis_dir += Vector2i.RIGHT
				elif prev_input_dir.x < -DEAD_ZONE:
					axis_dir += Vector2i.LEFT
				if prev_input_dir.y < -DEAD_ZONE:
					axis_dir += Vector2i.UP
				elif prev_input_dir.y > DEAD_ZONE:
					axis_dir += Vector2i.DOWN
				tile_position = move_start_tile_position + axis_dir
			if move_tween:
				move_tween.kill()
			move_tween = create_tween()
			#move_tween.tween_property(self, "position", Map.global.map_to_local_center(tile_position), 0.2) \
				#.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	else:
		if not is_moving:
			_anim_player.play("move")
			press_time = 0
			if move_tween:
				move_tween.kill()
			move_start_tile_position = tile_position
			is_moving = true
		else:
			position += input_dir.normalized() * delta * 128.0
		press_time += delta
		if (input_dir.x > 0 and not facing_right) or (input_dir.x < 0 and facing_right):
			facing_right = not facing_right
			if flip_tween:
				flip_tween.kill()
			flip_tween = create_tween()
			flip_tween.tween_property(_flip_sprite, "scale", Vector2(1, 1) if input_dir.x >= 0 else Vector2(-1, 1), 0.2) \
				.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		#tile_position = Map.global.local_to_map(position)
	prev_input_dir = input_dir
	
	# 鼠标输入检测
	if Input.is_action_just_pressed("p1_interact"):
		_spawn_tentacle()

	move_and_slide()


func _spawn_tentacle():
	if !tentacle_scene:
		push_warning("No tentacle scene assigned!")
		return
	if extending_tenta:
		return
	# 获取鼠标位置
	extending_tenta = true
	cool_down_tanta()
	
	var mouse_pos = get_global_mouse_position()
	
	# 计算惯性偏移（当前速度方向影响目标位置）
	var inertia_offset = velocity * inertia_factor
	var target_position = mouse_pos + inertia_offset
	
	# 创建触手实例
	var tentacle = tentacle_scene.instantiate()
	add_child(tentacle)
	
	# 初始化触手
	tentacle.init_tentacle(global_position,target_position)

func cool_down_tanta():
	if extending_tenta:
		await get_tree().create_timer(tentacle_scene.instantiate().extend_duration*2).timeout
		extending_tenta = false

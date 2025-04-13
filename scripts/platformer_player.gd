extends CharacterBody2D
class_name PlatformerPlayer

@export var speed: float = 300.0
@export var jump_force: float = -400.0
@export var air_control: float = 0.6
@export var gravity_scale: float = 1.0
@export var max_fall_speed: float = 800.0

@export var _flip_sprite: Node2D
@export var _anim_player: AnimationPlayer

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right: bool = true
var can_double_jump: bool = true

func _ready():
	_anim_player.play("idle")

func _physics_process(delta):
	# 应用重力
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
		velocity.y = min(velocity.y, max_fall_speed)

	# 跳跃输入处理
	var jump_pressed = Input.is_action_just_pressed("p1_jump")
	var jump_released = Input.is_action_just_released("p1_jump")
	
	# 地面跳跃
	if jump_pressed and is_on_floor():
		velocity.y = jump_force
		#_anim_player.play("jump")
		can_double_jump = true
	# 二段跳
	elif jump_pressed and can_double_jump and not is_on_floor():
		velocity.y = jump_force * 0.8
		#_anim_player.play("double_jump")
		can_double_jump = false
	# 短按跳跃
	if jump_released and velocity.y < jump_force * 0.5:
		velocity.y = jump_force * 0.5

	# 水平移动输入
	var input_dir = Input.get_axis("p1_left", "p1_right")
	
	# 翻转控制
	if input_dir != 0:
		facing_right = (input_dir > 0)
		_flip_sprite.scale.x = abs(_flip_sprite.scale.x) * (1 if facing_right else -1)

	# 加速度控制
	var target_speed = input_dir * speed
	if is_on_floor():
		velocity.x = lerp(velocity.x, target_speed, delta * 10.0)
	else:
		velocity.x = lerp(velocity.x, target_speed, delta * 5.0 * air_control)

	# 动画状态机
	#if is_on_floor():
		#if abs(velocity.x) > 10.0:
			#_anim_player.play("run")
		#else:
			#_anim_player.play("idle")
	#else:
		#if velocity.y < 0:
			#_anim_player.play("jump")
		#else:
			#_anim_player.play("fall")

	# 执行物理运动
	move_and_slide()


func _on_the_end_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var manager = MinigameManager.global
		manager.minigame_complete()

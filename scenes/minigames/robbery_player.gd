class_name RobberyPlayer
extends CharacterBody2D


@export var _flip_sprite: Node2D
@export var _anim_player: AnimationPlayer
@export var defualt_speed : float = 128
var speed : float
@export var slow_down_speed : float = 64
@export var slow_down_time : float = 2
var flip_tween: Tween
var move_tween: Tween
var tile_position: Vector2i

var facing_right: bool
var is_moving: bool
var prev_input_dir: Vector2
var move_start_tile_position: Vector2i
var press_time: float

var slow_down : bool 

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
	$Hand.hide()
	_anim_player.play("idle")
	speed = defualt_speed

func _process(delta: float) -> void:
	if Input.is_action_pressed("p1_interact"):
		_anim_player.play("stab")
	var input_dir = Vector2.ZERO
	for input in INPUT_DIRS:
		if Input.is_action_pressed(input):
			input_dir += INPUT_DIRS[input]
	if input_dir.is_zero_approx():
		if is_moving:
			_anim_player.play("idle")
			# Just released
			is_moving = false
			if press_time <= 0.1:
				# If it's a quick press, then move tile position by dir
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
			# Just pressed
			press_time = 0
			if move_tween:
				move_tween.kill()
			move_start_tile_position = tile_position
			is_moving = true
		else:
			# Continually moving
			position += input_dir.normalized() * delta * speed
		press_time += delta
		# Flip
		if (input_dir.x > 0 and not facing_right) or (input_dir.x < 0 and facing_right):
			facing_right = not facing_right
			if flip_tween:
				flip_tween.kill()
			flip_tween = create_tween()
			flip_tween.tween_property(_flip_sprite, "scale", Vector2(1, 1) if input_dir.x >= 0 else Vector2(-1, 1), 0.2) \
				.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		# Update tile position
		#tile_position = Map.global.local_to_map(position)
	prev_input_dir = input_dir
	
	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("litter"):
		on_slow_down()
		area.get_parent().queue_free()
	if area.get_parent().is_in_group("bullet"):
		_anim_player.play("demege")
		var tween = create_tween()
		var bu_volocity = area.get_parent().velocity
		tween.tween_property(self,"position:x",position.x + bu_volocity.x*0.1,0.1 )

func on_slow_down():
	speed = slow_down_speed
	slow_down = true
	_anim_player.play("slow_down")
	await get_tree().create_timer(slow_down_time).timeout
	speed = defualt_speed
	slow_down = false
	_anim_player.play("stop_slow_down")

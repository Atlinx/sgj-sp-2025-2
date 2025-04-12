class_name RandomAudioStreamPlayer
extends AudioStreamPlayer


@export var clips: Array[AudioStream]
@export var volume_offset: float = 0
@export var volume_range: Vector2 = Vector2(-0.5, 0.5)
@export var pitch_range: Vector2 = Vector2(0.9, 1.1)
@export var delay_range: Vector2 = Vector2(0, 0)


func play_random(delay: float = 0):
	stream = clips.pick_random()
	volume_db = randf_range(volume_range.x, volume_range.y) + volume_offset
	pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	await get_tree().create_timer(delay + randf_range(delay_range.x, delay_range.y)).timeout
	play()

@tool
class_name OverlayTexture
extends TextureRect


func _ready() -> void:
	if not Engine.is_editor_hint():
		material = material.duplicate()


func _process(delta: float) -> void:
	var mat = material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("size", size)


func set_fill_amount(amount: float):
	var mat = material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("fill_amount", amount)


func get_fill_amount() -> float:
	var mat = material as ShaderMaterial
	if mat:
		return mat.get_shader_parameter("fill_amount")
	return 0.0

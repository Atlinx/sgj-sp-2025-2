@tool
@icon("res://assets/sprites/target_quest.png")
class_name QuestRunner
extends Node2D


var actions: Array[QuestAction]


@export var quest: Quest :
	set(value):
		quest = value
		if Engine.is_editor_hint():
			if quest:
				name = (quest.resource_path.get_file().get_basename() + "_runner").to_pascal_case()
			else:
				name = "(EMPTY) Runner"


func _ready() -> void:
	if Engine.is_editor_hint():
		quest = quest
		return
	quest.action_completed.connect(_on_action_completed)
	for child in get_children():
		if child is QuestAction:
			child.completed.connect(_on_quest_completed_action.bind(child.name)) # Add completed actions to quest
			actions.append(child)
			child.reparent(Map.global.content)
	_on_action_completed()


func _on_quest_completed_action(quest: QuestAction):
	quest.add_completed_action(quest.name, quest.is_terminal)


func _on_action_completed():
	# Update the visibility of any actions that now have all their prereqs satisfied
	# TODO: Make this more efficient if necessary
	for action in actions:
		if quest.is_action_completed(action.name):
			action.visible = false
		else:
			action.visible = quest.are_action_prereqs_satisfied(action.prereq_sets)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if visible:
			queue_redraw()

const PREREQ_SET_COLORS = [
	Color.RED,
	Color.ORANGE,
	Color.YELLOW,
	Color.GREEN,
	Color.CYAN,
	Color.BLUE,
	Color.PURPLE,
	Color.MAGENTA,
]

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var global_to_local = global_transform.affine_inverse()
	for child in get_children():
		if child is QuestAction:
			var child_pos = global_to_local * child.global_position
			draw_string_outline(preload("res://assets/fonts/pixy/PIXY.otf"), child_pos + Vector2(-8, -10), child.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, 4, Color.ORANGE)
			draw_string(preload("res://assets/fonts/pixy/PIXY.otf"), child_pos + Vector2(-8, -10), child.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
			
			var prereq_sets = {}
			for action in child.prereq_actions:
				var res = action.split(":")
				var set_name = ""
				if res.size() >= 2:
					set_name = res[1]
				if not set_name in prereq_sets:
					prereq_sets[set_name] = []
				prereq_sets[set_name].append(res[0])
			
			var i = 0
			for prereq_actions in prereq_sets.values():
				for prev_action in prereq_actions:
					var prev_action_child = get_node_or_null(prev_action)
					if prev_action_child:
						_draw_arrow(prev_action_child, child, PREREQ_SET_COLORS[i])
				i += 1
				if i >= PREREQ_SET_COLORS.size():
					i = 0


const LINE_WIDTH = 1.5

func _draw_arrow(from: Node2D, to: Node2D, color: Color = Color.ORANGE):
	var global_to_local = global_transform.affine_inverse()
	var from_pos = global_to_local * from.global_position
	var to_pos = global_to_local * to.global_position
	
	from_pos += (to_pos - from_pos).normalized() * 8
	to_pos += (from_pos - to_pos).normalized() * 8
	draw_line(from_pos, to_pos, color, LINE_WIDTH)
	
	var arrow_side_root_pos = to_pos + (from_pos - to_pos).normalized() * 6
	draw_line(arrow_side_root_pos + (from_pos - to_pos).normalized().rotated(90) * 3, to_pos, color, LINE_WIDTH)
	draw_line(arrow_side_root_pos + (from_pos - to_pos).normalized().rotated(-90) * 3, to_pos, color, LINE_WIDTH)

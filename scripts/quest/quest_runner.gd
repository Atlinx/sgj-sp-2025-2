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
@export var reparent_children: bool


# Maps action names to all the QuestActions 
# that use a given action as a choice.
#
# NOTE: There can be multiple actions
# that point to one action as a choice,
# therefore we have to use an array
var choices_to_root_action: Dictionary[String, Array]


func _ready() -> void:
	if Engine.is_editor_hint():
		quest = quest
		return
	quest.quest_started.connect(_on_quest_started)
	quest.quest_completed.connect(_on_action_completed)
	quest.action_completed.connect(_on_action_completed)
	for child in get_children():
		if child is QuestAction:
			for choice in child.choice_actions:
				if choice not in choices_to_root_action:
					choices_to_root_action[choice] = [] 
				choices_to_root_action[choice].append(child)
			child.completed.connect(_on_quest_completed_action.bind(child)) # Add completed actions to quest
			actions.append(child)
			if reparent_children and Map.global:
				child.reparent(Map.global.content)
	_on_action_completed()


func _on_quest_started():
	_on_action_completed()


func _on_quest_completed_action(quest_action: QuestAction):
	quest._completed_actions[quest_action.action_name] = true
	quest.active_actions.erase(quest_action.action_name)
	# Remove any actions that are now disabled
	for action in actions:
		var another_choice_taken = false
		if action.action_name in choices_to_root_action:
			for _root_action in choices_to_root_action[action.action_name]:
				var root_action = _root_action as QuestAction
				for choice_action in root_action.choice_actions:
					if quest.is_action_completed(choice_action):
						another_choice_taken = true
						break
		action.disabled = another_choice_taken
		if action.disabled:
			quest.active_actions.erase(action.action_name)
	quest.add_completed_action(quest_action.action_name, quest_action.is_terminal)


func _on_action_completed():
	# Update the visibility of any actions that now have all their prereqs satisfied
	# TODO: Make this more efficient if necessary
	for action in actions:
		if quest.completed or (not quest.started) or action.disabled or quest.is_action_completed(action.action_name):
			action.visible = false
		else:
			var active = quest.are_action_prereqs_satisfied(action.prereq_sets)
			action.enable_action()
			action.visible = active
			if active:
				quest.add_active_action(action.action_name, action.description)


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
	color.a = 0.5
	
	from_pos += (to_pos - from_pos).normalized() * 8
	to_pos += (from_pos - to_pos).normalized() * 8
	draw_line(from_pos, to_pos, color, LINE_WIDTH)
	
	var arrow_side_root_pos = to_pos + (from_pos - to_pos).normalized() * 6
	draw_line(arrow_side_root_pos + (from_pos - to_pos).normalized().rotated(90) * 3, to_pos, color, LINE_WIDTH)
	draw_line(arrow_side_root_pos + (from_pos - to_pos).normalized().rotated(-90) * 3, to_pos, color, LINE_WIDTH)

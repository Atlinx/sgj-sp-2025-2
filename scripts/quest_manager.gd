class_name QuestManager
extends Node


static var global: QuestManager


@export var _hide_scenes: Array[String] = ["main_menu"]
@export var _quest_item_prefab: PackedScene
@export var _nothing_label: Control
@export var _quest_item_container: Control
@export var _canvas_layer: CanvasLayer
var quests: Array[Quest]
var completed_quests: Dictionary[Quest, bool] = {}
var quest_items: Dictionary[Quest, QuestListItem] = {}

var _initialized: bool


func _enter_tree() -> void:
	if _initialized:
		return
	_initialized = true
	if global != null:
		queue_free()
		return
	global = self
	for file_name in DirAccess.get_files_at("res://quests/"):
		if file_name.get_extension() in ["import", "tres"]:
			file_name = file_name.replace(".import", "").replace(".tres", "")
			var quest = load("res://quests/" + file_name + ".tres")
			if quest is Quest:
				quests.append(quest)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if global == self:
			global = null


func _ready():
	if global != self:
		return
	reparent.call_deferred(get_tree().root)
	for child in _quest_item_container.get_children():
		child.queue_free()
	TransitionManager.global.on_transition_in.connect(_on_transition_in)


func _on_transition_in():
	_canvas_layer.visible = TransitionManager.global.current_scene not in _hide_scenes
	

func reset():
	for quest in quests:
		quest.reset()
	for item in quest_items.values():
		item.queue_free()
	quest_items.clear()
	completed_quests.clear()
	_on_transition_in()
	_update_quests()


func _are_quest_prereqs_satisfied(quest: Quest):
	for prereq in quest.prerequisites:
		if prereq not in completed_quests:
			return false
	return true


func are_quest_prereqs_satisfied(quest: Quest) -> bool:
	for prereq in quest.prerequisites:
		if prereq not in completed_quests:
			return false
	return true


func _update_quests():
	for quest in quests:
		if not quest.completed and are_quest_prereqs_satisfied(quest):
			# Start the quest and create a quest item
			quest.start()
			var inst = _quest_item_prefab.instantiate() as QuestListItem
			_quest_item_container.add_child(inst)
			inst.construct(quest)
			inst.completed.connect(_on_quest_item_completed.bind(inst))
			quest_items[quest] = inst
	_update_visuals()


func _on_quest_item_completed(quest_item: QuestListItem):
	# Rest of code is handled in QuestRunner (it is a little jank :sob:)
	quest_items.erase(quest_item.quest)
	completed_quests[quest_item.quest] = true
	_update_quests()


func _update_visuals():
	_nothing_label.visible = quest_items.size() == 0
	_quest_item_container.visible = quest_items.size() > 0

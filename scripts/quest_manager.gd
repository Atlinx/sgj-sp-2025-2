class_name QuestManager
extends Node


static var global: QuestManager


@export var _quest_item_prefab: PackedScene
@export var _nothing_label: Control
@export var _quest_item_container: Control
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


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if global == self:
			global = null


func _ready():
	reparent.call_deferred(get_tree().root)
	for child in _quest_item_container.get_children():
		child.queue_free()
	for file_name in DirAccess.get_files_at("res://quests/"):
		if file_name.get_extension() == "import":
			file_name = file_name.replace('.import', '')
			var quest = load("res://quests/" + file_name)
			if quest is Quest:
				quests.append(quest)
	_update_quests()


func reset():
	for quest in quests:
		quest.reset()


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
		if are_quest_prereqs_satisfied(quest):
			# Create quest item
			var inst = _quest_item_prefab.instantiate() as QuestListItem
			_quest_item_container.add_child(inst)
			inst.construct(quest)
			inst.completed.connect(_on_quest_item_completed.bind(inst))
			quest_items[quest] = inst
	_update_visuals()


func _on_quest_item_completed(quest_item: QuestListItem):
	quest_items.erase(quest_item.quest)
	_update_quests()


func _update_visuals():
	_nothing_label.visible = quest_items.size() == 0
	_quest_item_container.visible = quest_items.size() > 0

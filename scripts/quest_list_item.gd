class_name QuestListItem
extends VBoxContainer


signal completed


@export var _title_label: Label
@export var _description_label: Label
@export var _checkbox: CheckBox
@export var _complete_sfx: RandomAudioStreamPlayer

var quest: Quest


func construct(quest: Quest):
	self.quest = quest
	quest.quest_completed.connect(_on_quest_completed)
	_title_label.text = quest.name
	_description_label.text = quest.description


func _on_quest_completed():
	_checkbox.button_pressed = true
	_complete_sfx.play_random()
	visible = false
	await get_tree().create_timer(3.0).timeout
	completed.emit()
	queue_free()

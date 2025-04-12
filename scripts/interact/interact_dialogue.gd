class_name InteractDialogue
extends Interact


@export var timeline: DialogicTimeline


func _on_interact():
	Dialogic.timeline_ended.connect(interactable.finish_interact, CONNECT_ONE_SHOT)
	Dialogic.start_timeline(timeline)

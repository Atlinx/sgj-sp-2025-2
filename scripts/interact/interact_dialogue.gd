class_name InteractDialogue
extends Interact


@export var timeline: DialogicTimeline


func _on_interact():
	# Load default style
	Dialogic.start_timeline(timeline)

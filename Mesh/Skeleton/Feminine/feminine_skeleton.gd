extends Node3D
class_name DollSkeleton

@onready var skeleton = $rig/Skeleton3D
@export var attachmentPoints:Dictionary = {}

func getSkeleton() -> Skeleton3D:
	return skeleton

func getBodypartSlotObject(bodypartSlot: String):
	if(attachmentPoints.has(bodypartSlot)):
		return get_node(attachmentPoints[bodypartSlot])
	return null

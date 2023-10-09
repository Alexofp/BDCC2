extends Node3D
class_name DollSkeleton

@onready var skeleton = $rig/Skeleton3D

func getSkeleton() -> Skeleton3D:
	return skeleton

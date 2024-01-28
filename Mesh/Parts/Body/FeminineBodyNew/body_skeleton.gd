extends Node3D

@onready var skeleton = $rig/Skeleton3D
@onready var animPlayer = $AnimationPlayer

func getSkeleton() -> Skeleton3D:
	return skeleton

func getAnimPlayer() -> AnimationPlayer:
	return animPlayer

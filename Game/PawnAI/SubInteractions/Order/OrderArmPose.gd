extends "res://Game/PawnAI/SubInteractions/Order/OrderPose.gd"

func _init() -> void:
	super._init()
	
	id = "OrderArmPose"
	socialActionName = "Change arms pose"
	poseType = DollPoseBase.PoseType.Arms
	poseHandlerType = PawnPoseHandler.POSE_ARMS

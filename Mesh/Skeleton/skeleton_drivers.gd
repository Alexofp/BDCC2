@tool
extends Node

@export_node_path("Button", "Skeleton3D") var skeletonPath:NodePath :
	set(value):
		if(has_node(value)):
			skeleton = get_node(value)
		else:
			skeleton = null
		skeletonPath = value
@onready var skeleton:Skeleton3D = get_node(skeletonPath)

func _ready():
	pass


func _process(_delta):
	if(skeleton == null):
		return
	
	var handBoneID = skeleton.find_bone("DEF-hand.L")
	var wristBoneID = skeleton.find_bone("DEF-forearmTwist.L")
	fixWrist(handBoneID, wristBoneID, 1.0)
	var handBoneID2 = skeleton.find_bone("DEF-hand.R")
	var wristBoneID2 = skeleton.find_bone("DEF-forearmTwist.R")
	fixWrist(handBoneID2, wristBoneID2, -1.0)

func fixWrist(handBoneID:int, wristBoneID:int, defaultX):
	if(handBoneID < 0 || wristBoneID < 0):
		return
	
	#var handRotation = (skeleton.get_bone_global_pose(handBoneID) * skeleton.get_bone_global_pose(skeleton.get_bone_parent(handBoneID)).inverse()).basis.get_rotation_quaternion()#skeleton.get_bone_pose_rotation(handBoneID)
	var handRotation = skeleton.get_bone_pose_rotation(handBoneID)
	handRotation = handRotation.inverse()
	#handRotation.x = 0.0
	#handRotation.z = 0.0
	var wristRotation = Quaternion.IDENTITY
	wristRotation.x = -handRotation.y
	wristRotation.y = 0.0
	wristRotation.z = handRotation.w
	wristRotation.w = 0.0
	wristRotation = wristRotation.normalized()
	var baseWristRotation = Quaternion.IDENTITY
	baseWristRotation.x = defaultX
	baseWristRotation.y = 0.0
	baseWristRotation.z = 0.0
	baseWristRotation.w = 0.0
	
	skeleton.set_bone_pose_rotation(wristBoneID, baseWristRotation.slerpni(wristRotation, 0.3).normalized())

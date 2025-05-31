extends Node3D

var bodies:Array[Node3D] = []
@onready var skeleton_3d: Skeleton3D = $NurbsCumStrand/CumRig/Skeleton3D
var stickyRigidBodyScene:PackedScene = preload("res://Mesh/Cum/NurbsCum/sticky_rigid.tscn")
#func _ready() -> void:
	##for boneID in range(skeleton_3d.get_bone_count()):
	#for node in get_children():
		#if(node is RigidBody3D):
			#bodies.append(node)
@onready var bone_follow_node_skeleton_modifier: BoneFollowNodeSkeletonModifier = $NurbsCumStrand/CumRig/Skeleton3D/BoneFollowNodeSkeletonModifier

var randomScales:Array = []
var speedFreq:float = 0.1

func _ready() -> void:
	#for boneID in range(skeleton_3d.get_bone_count()):
	for boneID in range(skeleton_3d.get_bone_count()):
		var newSticky:Node3D = stickyRigidBodyScene.instantiate()
		add_child(newSticky)
		bodies.append(newSticky)
		randomScales.append(randf_range(0.8, 1.2))
	#cum_strand_skeleton_modifier.bodies = bodies
	bone_follow_node_skeleton_modifier.bodies = bodies
	bone_follow_node_skeleton_modifier.randomScales = randomScales

func getBodies() -> Array[Node3D]:
	return bodies
	

var alignNode:Node3D
var shootSpeed:float = 0.0
var curBodyIndx:int = 0
var curBodyTime:float = 0.2



func startShoot(theNode:Node3D, theSpeed:float):
	alignNode = theNode
	shootSpeed = theSpeed
	curBodyTime = 0.0
	speedFreq = randf_range(0.001, 0.03)
	
	for bodyA in bodies:
		var body:RigidBody3D = bodyA
		body.freeze = true
		body.global_transform = alignNode.global_transform
	
func _process(delta: float) -> void:
	#updatePoses()
	if(!alignNode):
		return
	
	curBodyTime -= delta
	if(curBodyTime <= 0.0):
		curBodyTime += speedFreq
		
		var bodyAm:int = bodies.size()
		var thePos:float = float(curBodyIndx)/float(bodyAm-1)
		thePos = min(0.8, thePos)
		
		var body:RigidBody3D = bodies[curBodyIndx]
		body.freeze = false
		body.apply_central_impulse(Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))*0.5 + body.global_basis * Vector3.BACK * (shootSpeed)*(1.0 - randf_range(-0.1, 0.1) - thePos*0.9))
		#print(body," freeze = false")
		
		curBodyIndx += 1
		if(curBodyIndx >= bodies.size()):
			#set_process(false)
			alignNode = null
			return
	
	var _i:int = 0
	for bodyA in bodies:
		var body:RigidBody3D = bodyA
		if(body.freeze):
			body.global_transform = alignNode.global_transform
		_i += 1
	#print(_i)

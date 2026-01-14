extends Marker3D
class_name LeashPoint

@export var leashPointID:String = ""
@export var leashPointName:String = "Leash point"
@export var leashCanLeash:bool = true
@export var leashPointPriority:int = 0
@export var leashVector:Vector3 = Vector3(0.0, 0.0, 0.0)
@export var leashSag:float = -0.5

var physicsNode:PhysicsBody3D

func _ready() -> void:
	physicsNode = null
	var thePar := get_parent()
	while(thePar):
		if(thePar is PhysicsBody3D):
			physicsNode = thePar
			break
		thePar = thePar.get_parent()
	#physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON

func _exit_tree() -> void:
	physicsNode = null

func getLeashPointCenter() -> Vector3:
	if(physicsNode && physicsNode is DollController):
		return physicsNode.global_position
	return global_position

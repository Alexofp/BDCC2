@tool
extends Path3D

@export var shaftNode:Node3D
@export var holeNode:Node3D
@export var insideNode:Node3D

@export var blendDistance:float = 1.0
@export var straightness:float = 0.5


func _ready() -> void:
	#print("HUH?")
	pass

func _process(_delta: float) -> void:
	#print("MEOW")
	if(!holeNode || !insideNode || !shaftNode):
		#print("A")
		return
	#print("B")
	var holePos := holeNode.global_transform.origin
	var insidePos := insideNode.global_transform.origin
	var shaftPos := shaftNode.global_transform.origin
	#holeNode.global_transform.basis.get_scale()
	
	var shaftToInsideDistance:float = holePos.distance_to(shaftPos)
	var handleMult:float = 1.0
	if(shaftToInsideDistance < blendDistance):
		#handleMult *= max((shaftToInsideDistance-blendDistance/2.0)/(blendDistance/2.0), 0.0)
		handleMult *= max((shaftToInsideDistance)/(blendDistance), 0.0)
	handleMult /= sqrt(max(shaftNode.global_basis.get_scale().x, 0.01))
	#print(handleMult)
	
	var localHolePos := to_local(holePos)
	var localInsidePos := to_local(insidePos)
	var localShaftPos := to_local(shaftPos)
	
	curve.set_point_position(0, localShaftPos)
	curve.set_point_position(1, localHolePos)
	curve.set_point_position(2, localInsidePos)
	
	curve.set_point_out(0, getLocalCurveHandlePos(shaftNode.global_transform, -straightness*handleMult)) #/max(shaftNode.global_basis.get_scale().x, 0.01)
	
	curve.set_point_in(1, getLocalCurveHandlePos(holeNode.global_transform, 0.2*handleMult))
	curve.set_point_out(1, getLocalCurveHandlePos(holeNode.global_transform, -0.2*handleMult))
	
	curve.set_point_in(2, getLocalCurveHandlePos(insideNode.global_transform, 0.1))

func getLocalCurveHandlePos(theGlobalTransform:Transform3D, handlePos:float) -> Vector3:
	return (global_transform.inverse() * theGlobalTransform).basis.get_rotation_quaternion() * Vector3.FORWARD*handlePos

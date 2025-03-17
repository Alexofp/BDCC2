extends DollPart

@export var hornMat:MyMasterBodyMat
@export var hornMesh:MeshInstance3D
@export var isLeft:bool = false

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "hornColor"):
		if(hornMat):
			hornMat.set_shader_parameter("albedo", _value)
	if(_optionID == "hornScale"):
		if(hornMesh):
			hornMesh.scale = Vector3(_value, _value, _value)
	if(_optionID == "hornSideShift"):
		if(hornMesh):
			hornMesh.position.x = _value*0.1 * (-1.0 if !isLeft else 1.0)
	if(_optionID == "hornForwardShift"):
		if(hornMesh):
			hornMesh.position.z = _value*0.1

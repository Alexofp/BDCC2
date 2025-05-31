@tool
extends Node3D
class_name MarkerBlendshaped

@export var blendshapes:Dictionary[String, float] = {}
@export var mirrorX:bool = false

@export var calcBlendshapes:bool = false: set = onCalcBlendshapesButton
@export var applyBlendshapesTest:bool = false: set = onApplyBlendshapesButton


# name = vec3 offset
@export var blendshapesData:Dictionary[String, Vector3] = {}

@onready var blendshapes_markers: Node3D = %BlendshapesMarkers
@onready var target: Node3D = %Target

func onCalcBlendshapesButton(_val:bool):
	if(!_val):
		return
	calculateBlendshapes()


func onApplyBlendshapesButton(_val:bool):
	if(!_val):
		return
	applyBlendshapes()

var isUpdating:bool = false
func setBlendshape(_name:String, _val:float):
	if(!blendshapes.has(_name)):
		return
	blendshapes[_name] = _val
	if(isUpdating):
		return
	isUpdating = true
	applyBlendshapes.call_deferred()

func applyBlendshapes():
	var targetPos:Vector3 = Vector3(0.0, 0.0, 0.0)
	for blendshapeName in blendshapes:
		var blendVal:float = blendshapes[blendshapeName]
		if(blendVal != 0.0):
			targetPos += blendshapesData[blendshapeName] * blendVal
	target.position = targetPos
	if(mirrorX):
		target.position.x = -target.position.x
	isUpdating = false

func calculateBlendshapes():
	blendshapesData = {}
	blendshapes = blendshapes.duplicate()
	
	for theNode in blendshapes_markers.get_children():
		var nodeName:String = theNode.name
		var posDelta:Vector3 = theNode.position - blendshapes_markers.position
		blendshapesData[nodeName] = posDelta
	
	for blendshapeName in blendshapes.keys():
		if(!blendshapesData.has(blendshapeName)):
			blendshapes.erase(blendshapeName)
	
	for blendshapeName in blendshapesData:
		if(!blendshapes.has(blendshapeName)):
			blendshapes[blendshapeName] = 0.0

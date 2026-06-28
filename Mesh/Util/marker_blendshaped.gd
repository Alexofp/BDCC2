@tool
extends Node3D
class_name MarkerBlendshaped

@export var testMeshes:Array[MeshInstance3D] = []
@export var selectedShapekey:String = ""

func _validate_property(property: Dictionary) -> void:
	if property.name in ["selectedShapekey"]:
		var hintStrings:Array[String] = []
		hintStrings.append_array(blendshapesData.keys())
		for theMesh3D in testMeshes:
			if(!theMesh3D):
				continue
			var theMesh:ArrayMesh = theMesh3D.mesh
			if(!theMesh):
				continue
			for _i in theMesh.get_blend_shape_count():
				var theShapekeyName:String = theMesh.get_blend_shape_name(_i)
				if(!hintStrings.has(theShapekeyName)):
					hintStrings.append(theShapekeyName)
		
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = Util.join(hintStrings, ",")

@export var editShapekey:bool = false: set = onEditShapekey

@export var blendshapes:Dictionary[String, float] = {}
@export var mirrorX:bool = false

#@export var calcBlendshapes:bool = false: set = onCalcBlendshapesButton
@export var applyBlendshapesTest:bool = false: set = onApplyBlendshapesButton


# name = vec3 offset
@export var blendshapesData:Dictionary[String, Vector3] = {}
# name = vec3 scale
@export var blendshapesDataScale:Dictionary[String, Vector3] = {}
# name = vec3 rotation
@export var blendshapesDataRot:Dictionary[String, Vector3] = {}

@onready var blendshapes_markers: Node3D = %BlendshapesMarkers
@onready var target: Node3D = %Target

@export var copyDataMarker:MarkerBlendshaped = null
@export var doCopyDataFromMarker:bool = false: set = doCopyDataFromOtherMarker

func doCopyDataFromOtherMarker(_val:bool):
	if(!_val || !copyDataMarker):
		return
	blendshapesData = copyDataMarker.blendshapesData.duplicate()
	blendshapesDataScale = copyDataMarker.blendshapesDataScale.duplicate()
	blendshapesDataRot = copyDataMarker.blendshapesDataRot.duplicate()

func onEditShapekey(_val:bool):
	if(editShapekey == _val):
		return
	editShapekey = _val
	if(!_val):
		# Saving the selected shapekey from a marker
		#if(!blendshapes_markers.has_node(selectedShapekey)):
		#	return
		#var theMarker:Node3D = blendshapes_markers.get_node(selectedShapekey)
		#if(!theMarker):
		#	return
		if(!target.position.is_zero_approx()):
			blendshapesData[selectedShapekey] = target.position
		else:
			blendshapesData.erase(selectedShapekey)
		if(!target.scale.is_equal_approx(Vector3.ONE)):
			blendshapesDataScale[selectedShapekey] = target.scale
		else:
			blendshapesDataScale.erase(selectedShapekey)
		if(!target.rotation.is_zero_approx()):
			blendshapesDataRot[selectedShapekey] = target.rotation
		else:
			blendshapesDataRot.erase(selectedShapekey)
		
		target.position = Vector3.ZERO
		target.scale = Vector3.ONE
		target.rotation = Vector3.ZERO
		#theMarker.queue_free()
		
		for theMesh in testMeshes:
			if(!theMesh):
				continue
			var indx:int = theMesh.find_blend_shape_by_name(selectedShapekey)
			if(indx >= 0):
				theMesh.set_blend_shape_value(indx, 0.0)
		return
	# Adding the selected shapekey as a marker3D
	if(selectedShapekey.is_empty()):
		return
	#if(blendshapes_markers.has_node(selectedShapekey)):
	#	return
	#var newMarker:Marker3D = Marker3D.new()
	#newMarker.name = selectedShapekey
	#newMarker.position = blendshapesData.get(selectedShapekey, Vector3.ZERO)
	#newMarker.gizmo_extents = 0.02
	#blendshapes_markers.add_child(newMarker)
	#newMarker.owner = self
	target.position = blendshapesData.get(selectedShapekey, Vector3.ZERO)
	target.scale = blendshapesDataScale.get(selectedShapekey, Vector3.ONE)
	target.rotation = blendshapesDataRot.get(selectedShapekey, Vector3.ZERO)
	
	for theMesh in testMeshes:
		if(!theMesh):
			continue
		var indx:int = theMesh.find_blend_shape_by_name(selectedShapekey)
		if(indx >= 0):
			theMesh.set_blend_shape_value(indx, 1.0)
	

#func onCalcBlendshapesButton(_val:bool):
	#if(!_val):
		#return
	#calculateBlendshapes()


func onApplyBlendshapesButton(_val:bool):
	if(!_val):
		return
	applyBlendshapes()

var isUpdating:bool = false
func setBlendshape(_name:String, _val:float):
	if(!blendshapesData.has(_name)):
		return
	blendshapes[_name] = _val
	if(isUpdating):
		return
	isUpdating = true
	applyBlendshapes.call_deferred()

func applyBlendshapes():
	var targetPos:Vector3 = Vector3.ZERO
	var targetScale:Vector3 = Vector3.ONE
	var targetRot:Vector3 = Vector3.ZERO
	for blendshapeName in blendshapes:
		var blendVal:float = blendshapes[blendshapeName]
		if(blendVal != 0.0):
			targetPos += blendshapesData.get(blendshapeName, Vector3.ZERO) * blendVal
			targetScale += (blendshapesDataScale.get(blendshapeName, Vector3.ONE)-Vector3.ONE) * blendVal
			targetRot += blendshapesDataRot.get(blendshapeName, Vector3.ZERO) * blendVal
	target.position = targetPos
	target.scale = targetScale
	target.rotation = targetRot
	if(mirrorX):
		target.position.x = -target.position.x
		target.rotation.y = -target.rotation.y
		target.rotation.z = -target.rotation.z
	isUpdating = false

#func calculateBlendshapes():
	#blendshapesData = {}
	#blendshapes = blendshapes.duplicate()
	#
	#for theNode in blendshapes_markers.get_children():
		#var nodeName:String = theNode.name
		#var posDelta:Vector3 = theNode.position - blendshapes_markers.position
		#blendshapesData[nodeName] = posDelta
	#
	#for blendshapeName in blendshapes.keys():
		#if(!blendshapesData.has(blendshapeName)):
			#blendshapes.erase(blendshapeName)
	#
	#for blendshapeName in blendshapesData:
		#if(!blendshapes.has(blendshapeName)):
			#blendshapes[blendshapeName] = 0.0

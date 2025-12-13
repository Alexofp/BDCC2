@tool
extends LayeredAnimPlayer
class_name DollLayeredAnimPlayer

const LAYER_LOCOMOTION = 0
const LAYER_GESTURE_FULLBODY = 10
const LAYER_GESTURE = 20
const LAYER_ARMS_OVERRIDE = 30

var cacheID:String = "doll"

func doFullSetup() -> void:
	if(GlobalRegistry.dollAnimTreeCache.has(cacheID)):
		tree_root = GlobalRegistry.dollAnimTreeCache[cacheID]
		layers = GlobalRegistry.dollAnimTreeLayerCache[cacheID]
		#print("REUSED THE ANIMATION TREE SETUP!")
	else:
		layers.clear()
		defineLayers()
		setupTree()
		GlobalRegistry.dollAnimTreeCache[cacheID] = tree_root
		GlobalRegistry.dollAnimTreeLayerCache[cacheID] = layers

func defineLayers():
	if(true):
		var theLocomotionAnims:Dictionary[String, Dictionary] = {}
		for anim in GlobalRegistry.getDollAnimsByType(DollAnimBase.TYPE_IDLE):
			theLocomotionAnims[anim.id] = {L_ANIM: anim.animNameFinal}
		for anim in GlobalRegistry.getDollAnimsByType(DollAnimBase.TYPE_WALK):
			theLocomotionAnims[anim.id] = {L_ANIM: anim.animNameFinal}
		
		theLocomotionAnims["run"] = {L_ANIM: "LocomotionAnims/Run"}
		theLocomotionAnims["fall"] = {L_ANIM: "LocomotionAnims/Fall"}
		
		var LocomotionLayer := LayerBasic.new()
		LocomotionLayer.blendTimeIn = 0.0
		LocomotionLayer.blendTimeOut = 0.0
		LocomotionLayer.blendTimeBetween = 0.2
		LocomotionLayer.anims = theLocomotionAnims
		addLayer(LAYER_LOCOMOTION, LocomotionLayer)
	
	
	if(true):
		var gesturePartialFilter := BoneFilterSimple.new()#BoneFilter.new(self, skeleton_3d)
		gesturePartialFilter.enableBoneReqursive("upper_chest")
		
		var theGestureAnims:Dictionary[String, Dictionary] = {}
		for gestureID in GlobalRegistry.getDollGestures():
			var theGesture:DollGestureBase = GlobalRegistry.getDollGesture(gestureID)
			theGestureAnims[gestureID] = {L_ANIM: theGesture.getAnimName()}
		var GesturesLayer := LayerBasic.new()
		GesturesLayer.blendTimeIn = 0.5
		GesturesLayer.blendTimeOut = 0.5
		GesturesLayer.blendTimeBetween = 0.3
		GesturesLayer.anims = theGestureAnims
		GesturesLayer.bones = gesturePartialFilter.getBonesFinal()
		addLayer(LAYER_GESTURE, GesturesLayer)
	
	
	if(true):
		var theGestureAnims:Dictionary[String, Dictionary] = {}
		for gestureID in GlobalRegistry.getDollGestures():
			var theGesture:DollGestureBase = GlobalRegistry.getDollGesture(gestureID)
			if(!theGesture.playFullBody):
				continue
			theGestureAnims[gestureID] = {L_ANIM: theGesture.getAnimName()}
		var GesturesLayer := LayerBasic.new()
		GesturesLayer.blendTimeIn = 0.5
		GesturesLayer.blendTimeOut = 0.5
		GesturesLayer.blendTimeBetween = 0.3
		GesturesLayer.anims = theGestureAnims
		addLayer(LAYER_GESTURE_FULLBODY, GesturesLayer)
	
	var armsOnly := BoneFilterSimple.new()#BoneFilter.new(self, skeleton_3d)
	armsOnly.enableBoneReqursive("shoulder.L")
	armsOnly.enableBoneReqursive("shoulder.R")
	if(true):
		var theArmsAnims:Dictionary[String, Dictionary] = {}
		for anim in GlobalRegistry.getDollAnimsByType(DollAnimBase.TYPE_ARMS):
			theArmsAnims[anim.id] = {L_ANIM: anim.animNameFinal}
		var ArmsLayer := LayerBasic.new()
		ArmsLayer.blendTimeIn = 0.1
		ArmsLayer.blendTimeOut = 0.1
		ArmsLayer.blendTimeBetween = 0.2
		ArmsLayer.anims = theArmsAnims
		ArmsLayer.bones = armsOnly.getBonesFinal()
		addLayer(LAYER_ARMS_OVERRIDE, ArmsLayer)

func _enter_tree() -> void:
	if(!Engine.is_editor_hint()):
		ProcessBalancer.addAnimTree(self)

func _exit_tree() -> void:
	if(!Engine.is_editor_hint()):
		ProcessBalancer.removeAnimTree(self)

class BoneFilterSimple:
	var bones:Array[String] = []
	
	func _init() -> void:
		pass
	
	func enableBone(_bone:String):
		var theFinalPath := GlobalRegistry.mainSkeletonBoneData.SkeletonPathPrefix+":"+_bone
		bones.append(theFinalPath)
		#print(theFinalPath)
	
	func enableBoneReqursive(_bone:String):
		enableBone(_bone)
		if(!GlobalRegistry.mainSkeletonBoneData.boneNameToIndx.has(_bone)):
			return
		var theBoneIndx:int = GlobalRegistry.mainSkeletonBoneData.boneNameToIndx[_bone]
		var theChildBones:PackedInt32Array = GlobalRegistry.mainSkeletonBoneData.boneChildren[theBoneIndx]
		for _boneIndx in theChildBones:
			enableBoneReqursive(GlobalRegistry.mainSkeletonBoneData.bones[_boneIndx])
	
	func getBonesFinal() -> Array[String]:
		return bones.duplicate()

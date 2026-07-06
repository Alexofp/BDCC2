@tool
extends LayeredAnimPlayer
class_name DollLayeredAnimPlayer

const LAYER_LOCOMOTION = 0
const LAYER_COMBAT = 10
const LAYER_GESTURE_FULLBODY = 20
const LAYER_COUPLE = 30
const LAYER_GESTURE = 40
const LAYER_RIGHT_ARM_OVERRIDE = 50
const LAYER_ARMS_OVERRIDE = 60

var cacheID:String = "doll"

func doFullSetup() -> void:
	if(!GlobalRegistry.finishedInit):
		return
	
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

func createLayerAnimFromEntry(_entry:Dictionary, _finalAnimName:String) -> LayerAnimBase:
	var theLayerAnim := LayerAnimAdvance.create(_finalAnimName)
	if(_entry.has("loopLength")):
		theLayerAnim.setLength(_entry["loopLength"], true)
	if(_entry.has("looped")):
		theLayerAnim.setLooping(_entry["looped"])
	if(_entry.has("playBackwards")):
		theLayerAnim.setPlayBackwards(_entry["playBackwards"])
	return theLayerAnim

func defineLayers():
	if(true):
		var theLocomotionAnims:Dictionary[String, Variant] = {}
		for animType in [DollAnimBase.TYPE_IDLE, DollAnimBase.TYPE_WALK, DollAnimBase.TYPE_RUN]:
			for anim in GlobalRegistry.getDollAnimsByType(animType):
				for animID in anim.anims:
					theLocomotionAnims[animID] = createLayerAnimFromEntry(anim.anims[animID], anim.animNameFinal[animID])# LayerAnim.create(anim.animNameFinal[animID])
		
		const CombatWalkLen := 0.5
		#theLocomotionAnims["run"] = {L_ANIM: "LocomotionAnims/Run"}
		theLocomotionAnims["fall"] = {L_ANIM: "LocomotionAnims/Fall"}
		theLocomotionAnims["combat"] = LayerAnimBlend2D.create({
			Vector2(0.0, 0.0): LayerAnim.create("CombatAnims/CombatIdle"),
			Vector2(0.0, 1.0): LayerAnimAdvance.create("CombatAnims/CombatForward").setLength(CombatWalkLen, true),
			Vector2(0.0, -1.0): LayerAnimAdvance.create("CombatAnims/CombatForward").setLength(CombatWalkLen, true).setPlayBackwards(),
			Vector2(1.0, 0.0): LayerAnimAdvance.create("CombatAnims/CombatLeft").setLength(CombatWalkLen, true),
			Vector2(-1.0, 0.0): LayerAnimAdvance.create("CombatAnims/CombatLeft").setLength(CombatWalkLen, true).setPlayBackwards(),
		})
		theLocomotionAnims["block"] = LayerAnimBlend2D.create({
			Vector2(0.0, 0.0): LayerAnim.create("CombatAnims/CombatBlock"),
			Vector2(0.0, 1.0): LayerAnimAdvance.create("CombatAnims/CombatForwardBlock").setLength(CombatWalkLen, true),
			Vector2(0.0, -1.0): LayerAnimAdvance.create("CombatAnims/CombatForwardBlock").setLength(CombatWalkLen, true).setPlayBackwards(),
			Vector2(1.0, 0.0): LayerAnimAdvance.create("CombatAnims/CombatLeftBlock").setLength(CombatWalkLen, true),
			Vector2(-1.0, 0.0): LayerAnimAdvance.create("CombatAnims/CombatLeftBlock").setLength(CombatWalkLen, true).setPlayBackwards(),
		})
		#theLocomotionAnims["punch"] = LayerAnimAdvance.create("CombatAnims/Punch").setLength(1.0, false)

		var LocomotionLayer := LayerBasic.new()
		LocomotionLayer.blendTimeIn = 0.0
		LocomotionLayer.blendTimeOut = 0.0
		LocomotionLayer.blendTimeBetween = 0.2
		LocomotionLayer.anims = theLocomotionAnims
		LocomotionLayer.sync = false
		addLayer(LAYER_LOCOMOTION, LocomotionLayer)
	
	if(true):
		var theCombatAnims:Dictionary[String, Variant] = {}
		const DodgeLen := 0.8
		theCombatAnims["dodge"] = LayerAnimBlend2D.create({
			Vector2(0.0, 1.0): LayerAnimAdvance.create("CombatAnims/DodgeForward").setLength(DodgeLen, false),
			Vector2(0.0, -1.0): LayerAnimAdvance.create("CombatAnims/DodgeBack").setLength(DodgeLen, false),
			Vector2(1.0, 0.0): LayerAnimAdvance.create("CombatAnims/DodgeLeft").setLength(DodgeLen, false),
			Vector2(-1.0, 0.0): LayerAnimAdvance.create("CombatAnims/DodgeRight").setLength(DodgeLen, false),
		})
		for anim in GlobalRegistry.getDollAnimsByType(DollAnimBase.TYPE_COMBAT):
			for animID in anim.anims:
				theCombatAnims[animID] = createLayerAnimFromEntry(anim.anims[animID], anim.animNameFinal[animID])
		
		#theCombatAnims["punch"] = LayerAnimAdvance.create("CombatAnims/Punch").setLength(1.0, false)
		#theCombatAnims["punch2"] = LayerAnimAdvance.create("CombatAnims/Punch").setLength(0.5, false)
		var CombatLayer := LayerBasic.new()
		CombatLayer.blendTimeIn = 0.1
		CombatLayer.blendTimeOut = 0.1
		CombatLayer.blendTimeBetween = 0.1
		CombatLayer.anims = theCombatAnims
		CombatLayer.comboLayers = 2
		CombatLayer.sync = true
		addLayer(LAYER_COMBAT, CombatLayer)
	
	if(true):
		var gesturePartialFilter := BoneFilterSimple.new()#BoneFilter.new(self, skeleton_3d)
		gesturePartialFilter.enableBoneReqursive("upper_chest")
		
		var theGestureAnims:Dictionary[String, Variant] = {}
		for gestureID in GlobalRegistry.getDollGestures():
			var theGesture:DollGestureBase = GlobalRegistry.getDollGesture(gestureID)
			theGestureAnims[gestureID] = {L_ANIM: theGesture.getAnimName()}
		var GesturesLayer := LayerBasic.new()
		GesturesLayer.blendTimeIn = 0.2
		GesturesLayer.blendTimeOut = 0.2
		GesturesLayer.blendTimeBetween = 0.2
		GesturesLayer.anims = theGestureAnims
		GesturesLayer.bones = gesturePartialFilter.getBonesFinal()
		addLayer(LAYER_GESTURE, GesturesLayer)
	
	
	if(true):
		var theGestureAnims:Dictionary[String, Variant] = {}
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
	
	if(true):
		var theCoupleAnims:Dictionary[String, Variant] = {}
		for anim in GlobalRegistry.getDollAnimsByType(DollAnimBase.TYPE_COUPLE):
			for animID in anim.anims:
				theCoupleAnims[animID] = createLayerAnimFromEntry(anim.anims[animID], anim.animNameFinal[animID])
		var CoupleLayer := LayerBasic.new()
		CoupleLayer.blendTimeIn = 0.5
		CoupleLayer.blendTimeOut = 0.5
		CoupleLayer.blendTimeBetween = 0.3
		CoupleLayer.anims = theCoupleAnims
		addLayer(LAYER_COUPLE, CoupleLayer)
	
	var rightArmOnly := BoneFilterSimple.new()#BoneFilter.new(self, skeleton_3d)
	#armsOnly.enableBoneReqursive("shoulder.L")
	rightArmOnly.enableBoneReqursive("shoulder.R")
	if(true):
		var theArmsAnims:Dictionary[String, Variant] = {}
		theArmsAnims["holdLeash"] = LayerAnimAdvance.create("Poses/HoldLeash")
		#for anim in GlobalRegistry.getDollAnimsByType(DollAnimBase.TYPE_ARMS):
		#	for animID in anim.anims:
		#		theArmsAnims[animID] = createLayerAnimFromEntry(anim.anims[animID], anim.animNameFinal[animID])
		var ArmsLayer := LayerBasic.new()
		ArmsLayer.blendTimeIn = 0.2
		ArmsLayer.blendTimeOut = 0.2
		ArmsLayer.blendTimeBetween = 0.2
		ArmsLayer.anims = theArmsAnims
		ArmsLayer.bones = rightArmOnly.getBonesFinal()
		addLayer(LAYER_RIGHT_ARM_OVERRIDE, ArmsLayer)
	
	var armsOnly := BoneFilterSimple.new()#BoneFilter.new(self, skeleton_3d)
	armsOnly.enableBoneReqursive("shoulder.L")
	armsOnly.enableBoneReqursive("shoulder.R")
	if(true):
		var theArmsAnims:Dictionary[String, Variant] = {}
		for anim in GlobalRegistry.getDollAnimsByType(DollAnimBase.TYPE_ARMS):
			for animID in anim.anims:
				theArmsAnims[animID] = createLayerAnimFromEntry(anim.anims[animID], anim.animNameFinal[animID])
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

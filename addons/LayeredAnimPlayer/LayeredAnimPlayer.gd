@tool
extends AnimationTree
class_name LayeredAnimPlayer

# https://forum.godotengine.org/t/journal-samples-how-to-setup-animationtree-by-code/110728

const L_ANIM = "anim"

var layers:Dictionary[int, ILayerBase] = {}

const CURVE_EASE_IN = preload("res://addons/LayeredAnimPlayer/XFadeCurves/EaseIn.tres")
const CURVE_EASE_OUT = preload("res://addons/LayeredAnimPlayer/XFadeCurves/EaseOut.tres")
const CURVE_SMOOTH = preload("res://addons/LayeredAnimPlayer/XFadeCurves/Smooth.tres")
const CURVE_SMOOTH_VERY = preload("res://addons/LayeredAnimPlayer/XFadeCurves/SmoothVery.tres")

func defineLayers():
	pass

func playLayer(_layerID:int, _anim:String, _speed:float = 1.0, _resetIfSame:bool = false):
	if(!layers.has(_layerID)):
		printerr("playLayer() LAYER DOESN'T EXIST: "+str(_layerID))
		return
	var theLayer:ILayerBase = layers[_layerID]
	theLayer.playLayer(self, _layerID, _anim, _speed, _resetIfSame)
	
func stopLayer(_layerID:int, _instantStop:bool = false):
	if(!layers.has(_layerID)):
		printerr("stopLayer() LAYER DOESN'T EXIST: "+str(_layerID))
		return
	var theLayer:ILayerBase = layers[_layerID]
	theLayer.stopLayer(self, _layerID, _instantStop)

func isPlayingLayer(_layerID:int) -> bool:
	if(!layers.has(_layerID)):
		printerr("isPlayingLayer() LAYER DOESN'T EXIST: "+str(_layerID))
		return false
	var theLayer:ILayerBase = layers[_layerID]
	return theLayer.isPlayingLayer(self, _layerID)

func getCurrentAnimationLayer(_layerID:int) -> String:
	if(!layers.has(_layerID)):
		printerr("getCurrentAnimationLayer() LAYER DOESN'T EXIST: "+str(_layerID))
		return ""
	var theLayer:ILayerBase = layers[_layerID]
	return theLayer.getCurrentAnimationLayer(self, _layerID)

class BoneFilter:
	var bones:Array[String] = []
	var animTree:AnimationTree
	var skeleton:Skeleton3D
	
	func _init(_animTree:AnimationTree, _skeleton:Skeleton3D) -> void:
		animTree = _animTree
		skeleton = _skeleton
	
	func enableBone(_bone:String):
		var thePath := animTree.get_node(animTree.root_node).get_path_to(skeleton)
		var theFinalPath := thePath.get_concatenated_names()+":"+_bone
		bones.append(theFinalPath)
		#print(theFinalPath)
	
	func enableBoneReqursive(_bone:String):
		enableBone(_bone)
		for _boneIndx in skeleton.get_bone_children(skeleton.find_bone(_bone)):
			enableBoneReqursive(skeleton.get_bone_name(_boneIndx))
	
	func getBonesFinal() -> Array[String]:
		return bones.duplicate()


class ILayerBase:
	func playLayer(_animPlayer:LayeredAnimPlayer, _layerID:int, _anim:String, _speed:float = 1.0, _resetIfSame:bool = false):
		printerr("playLayer() LAYER WITH THIS TYPE DOESN'T SUPPORT PLAYING ANIMS: "+str(_layerID))
	
	func stopLayer(_animPlayer:LayeredAnimPlayer, _layerID:int, _instantStop:bool = false):
		printerr("stopLayer() LAYER WITH THIS TYPE DOESN'T SUPPORT STOPPING ANIMS: "+str(_layerID))
	
	func isPlayingLayer(_animPlayer:LayeredAnimPlayer, _layerID:int) -> bool:
		printerr("isPlayingLayer() LAYER WITH THIS TYPE DOESN'T SUPPORT CHECKING ANIMS: "+str(_layerID))
		return false
	
	func getCurrentAnimationLayer(_animPlayer:LayeredAnimPlayer, _layerID:int) -> String:
		printerr("getCurrentAnimationLayer() LAYER WITH THIS TYPE DOESN'T SUPPORT GETTING ANIMS: "+str(_layerID))
		return ""
	
class LayerBasic extends ILayerBase:
	var blendTimeIn:float = 0.2
	var blendTimeOut:float = 0.2
	var blendTimeBetween:float = 0.0
	var blendCurve:Curve = CURVE_SMOOTH
	
	var anims:Dictionary[String, Dictionary] = {}
	var bones:Array[String] = []
	
	func playLayer(_animPlayer:LayeredAnimPlayer, _layerID:int, _anim:String, _speed:float = 1.0, _resetIfSame:bool = false):
		if(!anims.has(_anim)):
			printerr("playLayer() LAYER "+str(_layerID)+" DOESN'T HAVE ANIMATION: "+str(_anim))
			return
		var layerStr:String = str(_layerID)
		var transitionLayerName:String = layerStr+"_"+_anim
		
		var shouldDoIt:bool = true
		#print(get("parameters/"+layerStr+"_oneshot/active"))
		#print("parameters/"+layerStr+"_oneshot/active")
		var _isActive:bool = (_animPlayer.get("parameters/"+layerStr+"_oneshot/active"))
		if(!_resetIfSame):
			if(_isActive && _animPlayer.get("parameters/"+layerStr+"/current_state") == transitionLayerName):
				shouldDoIt = false
		
		if(shouldDoIt):
			if(!_isActive):
				_animPlayer.set("parameters/"+layerStr+"_oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			_animPlayer.set("parameters/"+layerStr+"/transition_request", transitionLayerName)
			#_animPlayer.set("parameters/"+layerStr+"/current_state", layerStr+"_"+_anim) # doesn't work :(
		_animPlayer.set("parameters/"+layerStr+"_timescale/scale", _speed)
	
	func stopLayer(_animPlayer:LayeredAnimPlayer, _layerID:int, _instantStop:bool = false):
		var layerStr:String = str(_layerID)
		_animPlayer.set("parameters/"+layerStr+"_oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT if !_instantStop else AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

	func isPlayingLayer(_animPlayer:LayeredAnimPlayer, _layerID:int) -> bool:
		var layerStr:String = str(_layerID)
		var _isActive:bool = (_animPlayer.get("parameters/"+layerStr+"_oneshot/active"))
		return _isActive
	
	func getCurrentAnimationLayer(_animPlayer:LayeredAnimPlayer, _layerID:int) -> String:
		if(!isPlayingLayer(_animPlayer, _layerID)):
			return ""
		var layerStr:String = str(_layerID)
		var currentAnimRaw:String = _animPlayer.get("parameters/"+layerStr+"/current_state")
		var splitA := currentAnimRaw.split("_")
		var finalAnimName:String = ""
		for _i in range(splitA.size()-1):
			if(!finalAnimName.is_empty()):
				finalAnimName += "_"
			finalAnimName += splitA[_i+1]
		return finalAnimName
	
func addLayer(_layerID:int, _layer:ILayerBase):
	layers[_layerID] = _layer

func generateTree() -> AnimationNode:
	var rootBlendTree := AnimationNodeBlendTree.new()
	
	var layersOrder:Array[int] = layers.keys()
	layersOrder.sort()
	
	# Empty node as first element
	var emptyFirstNode := AnimationNodeTransition.new()
	var emptyFirstName:String = "LayeredAnimPlayerStart"
	rootBlendTree.add_node(emptyFirstName, emptyFirstNode)
	
	var currentNodeName:String = emptyFirstName
	var currentPosition:Vector2 = Vector2(600.0, 0.0)
	
	for orderID in layersOrder:
		var theLayer:ILayerBase = layers[orderID]
		
		if(theLayer is LayerBasic):
			var theSelectorNode := AnimationNodeTransition.new()
			theSelectorNode.allow_transition_to_self = true
			theSelectorNode.xfade_time = theLayer.blendTimeBetween
			theSelectorNode.xfade_curve = theLayer.blendCurve
			var theSelectorName:String = str(orderID)
			rootBlendTree.add_node(theSelectorName, theSelectorNode, currentPosition)
			
			var theTimeScaleNode := AnimationNodeTimeScale.new()
			var theTimeScaleName:String = str(orderID)+"_timescale"
			rootBlendTree.add_node(theTimeScaleName, theTimeScaleNode, currentPosition+Vector2(250.0, 0.0))
			
			rootBlendTree.connect_node(theTimeScaleName, 0, theSelectorName)
			
			if(!currentNodeName.is_empty()):
				var theBlendNode := AnimationNodeOneShot.new()
				theBlendNode.fadein_time = theLayer.blendTimeIn
				theBlendNode.fadeout_time = theLayer.blendTimeOut
				
				theBlendNode.fadein_curve = theLayer.blendCurve
				theBlendNode.fadeout_curve = theLayer.blendCurve
				
				if(!theLayer.bones.is_empty()):
					theBlendNode.filter_enabled = true
					var theBones:Array[String] = theLayer["bones"]
					for theBone in theBones:
						theBlendNode.set_filter_path(theBone, true)
				var theBlendName:String = str(orderID)+"_oneshot"
				currentPosition.x += 400.0
				rootBlendTree.add_node(theBlendName, theBlendNode, currentPosition+Vector2(0.0, -100.0))
				
				#rootBlendTree.connect_node(theSelectorName, 0, currentNodeName)
				rootBlendTree.connect_node(theBlendName, 0, currentNodeName)
				rootBlendTree.connect_node(theBlendName, 1, theTimeScaleName)
				currentNodeName = theBlendName
			else:
				currentNodeName = theTimeScaleName
			
			var theAnims:Dictionary[String, Dictionary] = theLayer.anims
			var _i:int = 0
			for animID in theAnims:
				var animEntry:Dictionary = theAnims[animID]
				
				var theAnimNode := AnimationNodeAnimation.new()
				theAnimNode.animation = animEntry[L_ANIM]
				var theAnimNodeName:String = str(orderID)+"_"+animID
				rootBlendTree.add_node(theAnimNodeName, theAnimNode, currentPosition + Vector2(-600.0, _i*160.0))
				
				theSelectorNode.add_input(theAnimNodeName)
				
				rootBlendTree.connect_node(theSelectorName, _i, theAnimNodeName)
				_i += 1
			
			currentPosition.x += 400.0
		else:
			printerr("UNKNOWN LAYER TYPE, CAN'T GENERATE")
		
	if(!currentNodeName.is_empty()):
		rootBlendTree.connect_node("output", 0, currentNodeName)
	rootBlendTree.set_node_position("output", currentPosition)
	
	return rootBlendTree

func setupTree():
	tree_root = generateTree()

func doFullSetup() -> void:
	layers.clear()
	defineLayers()
	setupTree()

func _ready() -> void:
	if(!Engine.is_editor_hint()):
		doFullSetup()

@export_tool_button("GENERATE TREE", "Callable") var doFullSetup_action = doFullSetup

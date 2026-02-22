@tool
extends AnimationTree
class_name LayeredAnimPlayer

# https://forum.godotengine.org/t/journal-samples-how-to-setup-animationtree-by-code/110728

const L_ANIM = "anim"

var layers:Dictionary[int, ILayerBase] = {}

var currentComboIndex:Dictionary[int, int] # layer indx -> current combo indx
const COMBO_SUFFIX := "_C"

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

func setBlend1DPos(_layerID:int, _anim:String, _pos:float):
	if(!layers.has(_layerID)):
		printerr("setBlend1DPos() LAYER DOESN'T EXIST: "+str(_layerID))
		return
	var theLayer:ILayerBase = layers[_layerID]
	theLayer.setBlend1DPos(self, _layerID, _anim, _pos)

func setBlend2DPos(_layerID:int, _anim:String, _pos:Vector2):
	if(!layers.has(_layerID)):
		printerr("setBlend1DPos() LAYER DOESN'T EXIST: "+str(_layerID))
		return
	var theLayer:ILayerBase = layers[_layerID]
	theLayer.setBlend2DPos(self, _layerID, _anim, _pos)

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
	func onAdd(_animPlayer:LayeredAnimPlayer, _layerID:int):
		pass
	
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

	func setBlend1DPos(_animPlayer:LayeredAnimPlayer, _layerID:int, _anim:String, _pos:float):
		printerr("setBlend1DPos() LAYER WITH THIS TYPE DOESN'T SUPPORT BLEND1D: "+str(_layerID))

	func setBlend2DPos(_animPlayer:LayeredAnimPlayer, _layerID:int, _anim:String, _pos:Vector2):
		printerr("setBlend2DPos() LAYER WITH THIS TYPE DOESN'T SUPPORT BLEND2D: "+str(_layerID))

class LayerAnimBase:
	pass

class LayerAnim extends LayerAnimBase:
	var animName:String
	static func create(_animName:String) -> LayerAnim:
		var newLayer := LayerAnim.new()
		newLayer.animName = _animName
		return newLayer

class LayerAnimAdvance extends LayerAnimBase:
	var animName:String
	var loop:int = -1
	var customLength:float = -1.0
	var playBackwards:bool = false
	static func create(_animName:String) -> LayerAnimAdvance:
		var newLayer := LayerAnimAdvance.new()
		newLayer.animName = _animName
		return newLayer
	func setLooping(_loop:bool) -> LayerAnimAdvance:
		loop = Animation.LOOP_LINEAR if _loop else Animation.LOOP_NONE
		return self
	func setLength(_len:float, _isLooping:bool) -> LayerAnimAdvance:
		customLength = _len
		loop = Animation.LOOP_LINEAR if _isLooping else Animation.LOOP_NONE
		return self
	func setPlayBackwards(_back:bool = true) -> LayerAnimAdvance:
		playBackwards = _back
		return self

class LayerAnimBlend1D extends LayerAnimBase:
	var anims:Dictionary[float, LayerAnimBase]
	var sync:bool = true
	var maxRange:float = 1.0
	static func create(_theAnims:Dictionary[float, LayerAnimBase] = {}) -> LayerAnimBlend1D:
		var newLayer := LayerAnimBlend1D.new()
		newLayer.anims = _theAnims
		for theFloat in _theAnims:
			var theAbsFloat:float = abs(theFloat)
			if(theAbsFloat > newLayer.maxRange): # Auto-expand the max range
				newLayer.maxRange = theAbsFloat
		return newLayer
	func addAnim(_pos:float, _anim:LayerAnimBase) -> LayerAnimBlend1D:
		anims[_pos] = _anim
		var theAbsFloat:float = abs(_pos)
		if(theAbsFloat > maxRange): # Auto-expand the max range
			maxRange = theAbsFloat
		return self
	func setSync(_s:bool) -> LayerAnimBlend1D:
		sync = _s
		return self

class LayerAnimBlend2D extends LayerAnimBase:
	var anims:Dictionary[Vector2, LayerAnimBase]
	var sync:bool = true
	var maxRange:float = 1.0
	static func create(_theAnims:Dictionary[Vector2, LayerAnimBase] = {}) -> LayerAnimBlend2D:
		var newLayer := LayerAnimBlend2D.new()
		newLayer.anims = _theAnims
		for theFloat in _theAnims:
			var theAbsFloatX:float = abs(theFloat.x)
			var theAbsFloatY:float = abs(theFloat.y)
			if(theAbsFloatX > newLayer.maxRange):
				newLayer.maxRange = theAbsFloatX
			if(theAbsFloatY > newLayer.maxRange):
				newLayer.maxRange = theAbsFloatY
		return newLayer
	func addAnim(_pos:Vector2, _anim:LayerAnimBase) -> LayerAnimBlend2D:
		anims[_pos] = _anim
		var theAbsFloatX:float = abs(_pos.x)
		var theAbsFloatY:float = abs(_pos.y)
		if(theAbsFloatX > maxRange):
			maxRange = theAbsFloatX
		if(theAbsFloatY > maxRange):
			maxRange = theAbsFloatY
		return self
	func setSync(_s:bool) -> LayerAnimBlend2D:
		sync = _s
		return self

class LayerBasic extends ILayerBase:
	var blendTimeIn:float = 0.2
	var blendTimeOut:float = 0.2
	var blendTimeBetween:float = 0.0
	var blendCurve:Curve = CURVE_SMOOTH
	
	var comboLayers:int = 0 # How many extra layers to spawn. playLayer will cycle through these combo layers to help avoid animation glitches
	
	var anims:Dictionary[String, Variant] = {}
	var bones:Array[String] = []
	
	func onAdd(_animPlayer:LayeredAnimPlayer, _layerID:int):
		for theKey in anims:
			var theVal:Variant = anims[theKey]
			if(theVal is Dictionary):
				anims[theKey] = LayerAnim.create(theVal[L_ANIM])
		if(comboLayers > 0):
			_animPlayer.currentComboIndex[_layerID] = 0
	
	func playLayer(_animPlayer:LayeredAnimPlayer, _layerID:int, _anim:String, _speed:float = 1.0, _resetIfSame:bool = false):
		if(!anims.has(_anim)):
			printerr("playLayer() LAYER "+str(_layerID)+" DOESN'T HAVE ANIMATION: "+str(_anim))
			return
		if(comboLayers > 0): # Cycling the combo layers
			stopLayer(_animPlayer, _layerID, false)
			if(!_animPlayer.currentComboIndex.has(_layerID)):
				_animPlayer.currentComboIndex[_layerID] = 1
			else:
				_animPlayer.currentComboIndex[_layerID] += 1
			if(_animPlayer.currentComboIndex[_layerID] > comboLayers):
				_animPlayer.currentComboIndex[_layerID] = 0
		
		var layerStr:String = getCurrentLayerID(_animPlayer, _layerID)
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
		var layerStr:String = getCurrentLayerID(_animPlayer, _layerID)
		_animPlayer.set("parameters/"+layerStr+"_oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT if !_instantStop else AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

	func isPlayingLayer(_animPlayer:LayeredAnimPlayer, _layerID:int) -> bool:
		var layerStr:String = getCurrentLayerID(_animPlayer, _layerID)
		var _isActive:bool = (_animPlayer.get("parameters/"+layerStr+"_oneshot/active"))
		return _isActive
	
	func getCurrentAnimationLayer(_animPlayer:LayeredAnimPlayer, _layerID:int) -> String:
		if(!isPlayingLayer(_animPlayer, _layerID)):
			return ""
		var layerStr:String = getCurrentLayerID(_animPlayer, _layerID)
		var currentAnimRaw:String = _animPlayer.get("parameters/"+layerStr+"/current_state")
		var splitA := currentAnimRaw.split("_")
		var finalAnimName:String = ""
		for _i in range(splitA.size()-1):
			if(!finalAnimName.is_empty()):
				finalAnimName += "_"
			finalAnimName += splitA[_i+1]
		return finalAnimName
	
	func getCurrentLayerID(_animPlayer:LayeredAnimPlayer, _layerID:int) -> String:
		return internal_getLayerID(_layerID, _animPlayer.currentComboIndex.get(_layerID, 0))
	
	func internal_getLayerID(_layerIndx:int, _comboIndx:int) -> String:
		if(_comboIndx <= 0):
			return str(_layerIndx)
		return str(_layerIndx)+COMBO_SUFFIX+str(_comboIndx)
	
	func setBlend1DPos(_animPlayer:LayeredAnimPlayer, _layerID:int, _anim:String, _pos:float):
		if(!anims.has(_anim)):
			printerr("setBlend1DPos() LAYER "+str(_layerID)+" DOESN'T HAVE ANIMATION: "+str(_anim))
			return
		var theLayerAnim:LayerAnimBase = anims[_anim]
		if(!(theLayerAnim is LayerAnimBlend1D)):
			printerr("setBlend1DPos() ANIM "+_anim+" FROM LAYER "+str(_layerID)+" DOESN'T SUPPORT BLEND1D")
			return
		
		var layerStr:String = getCurrentLayerID(_animPlayer, _layerID)#str(_layerID)
		var transitionLayerName:String = layerStr+"_"+_anim
		_animPlayer.set("parameters/"+transitionLayerName+"/blend_position", _pos)
			
	func setBlend2DPos(_animPlayer:LayeredAnimPlayer, _layerID:int, _anim:String, _pos:Vector2):
		if(!anims.has(_anim)):
			printerr("setBlend2DPos() LAYER "+str(_layerID)+" DOESN'T HAVE ANIMATION: "+str(_anim))
			return
		var theLayerAnim:LayerAnimBase = anims[_anim]
		if(!(theLayerAnim is LayerAnimBlend2D)):
			printerr("setBlend2DPos() ANIM "+_anim+" FROM LAYER "+str(_layerID)+" DOESN'T SUPPORT BLEND2D")
			return
		
		var layerStr:String = getCurrentLayerID(_animPlayer, _layerID)#str(_layerID)
		var transitionLayerName:String = layerStr+"_"+_anim
		_animPlayer.set("parameters/"+transitionLayerName+"/blend_position", _pos)

func addLayer(_layerID:int, _layer:ILayerBase):
	layers[_layerID] = _layer
	_layer.onAdd(self, _layerID)

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
			for _comboIndx in (theLayer.comboLayers+1):
				var theSelectorNode := AnimationNodeTransition.new()
				theSelectorNode.allow_transition_to_self = true
				theSelectorNode.xfade_time = theLayer.blendTimeBetween
				theSelectorNode.xfade_curve = theLayer.blendCurve
				var orderIDStr:String = theLayer.internal_getLayerID(orderID, _comboIndx)#str(orderID)
				var theSelectorName:String = orderIDStr
				rootBlendTree.add_node(theSelectorName, theSelectorNode, currentPosition)
				
				var theTimeScaleNode := AnimationNodeTimeScale.new()
				var theTimeScaleName:String = orderIDStr+"_timescale"
				rootBlendTree.add_node(theTimeScaleName, theTimeScaleNode, currentPosition+Vector2(250.0, 0.0))
				
				rootBlendTree.connect_node(theTimeScaleName, 0, theSelectorName)
				
				if(!currentNodeName.is_empty()):
					var theBlendNode := AnimationNodeOneShot.new()
					theBlendNode.abort_on_reset = true
					theBlendNode.fadein_time = theLayer.blendTimeIn
					theBlendNode.fadeout_time = theLayer.blendTimeOut
					
					theBlendNode.fadein_curve = theLayer.blendCurve
					theBlendNode.fadeout_curve = theLayer.blendCurve
					
					if(!theLayer.bones.is_empty()):
						theBlendNode.filter_enabled = true
						var theBones:Array[String] = theLayer["bones"]
						for theBone in theBones:
							theBlendNode.set_filter_path(theBone, true)
					var theBlendName:String = orderIDStr+"_oneshot"
					currentPosition.x += 400.0
					rootBlendTree.add_node(theBlendName, theBlendNode, currentPosition+Vector2(0.0, -100.0))
					
					#rootBlendTree.connect_node(theSelectorName, 0, currentNodeName)
					rootBlendTree.connect_node(theBlendName, 0, currentNodeName)
					rootBlendTree.connect_node(theBlendName, 1, theTimeScaleName)
					currentNodeName = theBlendName
				else:
					currentNodeName = theTimeScaleName
				
				var theAnims:Dictionary[String, Variant] = theLayer.anims
				var _i:int = 0
				for animID in theAnims:
					var animEntry:LayerAnimBase = theAnims[animID]
					var theAnimNodePos:Vector2 = currentPosition + Vector2(-600.0, _i*160.0)
					
					var theAnimNode := addAnimEntry(animEntry, theAnimNodePos)
					var theAnimNodeName:String = orderIDStr+"_"+animID
					rootBlendTree.add_node(theAnimNodeName, theAnimNode, theAnimNodePos)
					
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

func addAnimEntry(layerAnim:LayerAnimBase, _animPos:Vector2) -> AnimationNode:
	if(layerAnim is LayerAnim):
		var theAnimNode := AnimationNodeAnimation.new()
		theAnimNode.animation = layerAnim.animName
		return theAnimNode
	if(layerAnim is LayerAnimAdvance):
		var theAnimNode := AnimationNodeAnimation.new()
		theAnimNode.animation = layerAnim.animName
		if(layerAnim.playBackwards):
			theAnimNode.play_mode = AnimationNodeAnimation.PLAY_MODE_BACKWARD
		if(layerAnim.loop >= 0):
			theAnimNode.loop_mode = layerAnim.loop
			theAnimNode.use_custom_timeline = true
		if(layerAnim.customLength >= 0): # Probably doesn't work unless you set the loop mode as well
			theAnimNode.timeline_length = layerAnim.customLength
			theAnimNode.stretch_time_scale = true
			
		return theAnimNode
	if(layerAnim is LayerAnimBlend1D):
		var theAnimNode := AnimationNodeBlendSpace1D.new()
		theAnimNode.max_space = layerAnim.maxRange
		theAnimNode.min_space = -layerAnim.maxRange
		for thePos in layerAnim.anims:
			theAnimNode.add_blend_point(addAnimEntry(layerAnim.anims[thePos], Vector2.ZERO), thePos)
		theAnimNode.sync = layerAnim.sync
		return theAnimNode
	if(layerAnim is LayerAnimBlend2D):
		var theAnimNode := AnimationNodeBlendSpace2D.new()
		theAnimNode.max_space = Vector2(layerAnim.maxRange, layerAnim.maxRange)
		theAnimNode.min_space = Vector2(-layerAnim.maxRange, -layerAnim.maxRange)
		for thePos in layerAnim.anims:
			theAnimNode.add_blend_point(addAnimEntry(layerAnim.anims[thePos], Vector2.ZERO), thePos)
		theAnimNode.sync = layerAnim.sync
		return theAnimNode

	var theAnimNode := AnimationNodeAnimation.new()
	theAnimNode.animation = "ERROR_SPECIFY_ANIMATION"
	return theAnimNode

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

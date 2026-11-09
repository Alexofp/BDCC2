extends DATLayerRun
class_name DATAnimRun

#const NODE_AM:int = 2
#
#var animNodes:Array[AnimationNodeAnimation]
#var timeScaleNodes:Array[AnimationNodeTimeScale]
#var curNode:int = 0
#var mainNode:AnimationNodeOneShot
#var transNode:AnimationNodeTransition
#var disableTimer:float = 0.0
#var currentAnim:String = ""

var dynAnimHandler:DynAnimHandlerAlt

func _init() -> void:
	dynAnimHandler = DynAnimHandlerAlt.new()
	dynAnimHandler.datAnimRun = self

func onCreated(_layer:DATLayer):
	dynAnimHandler.instantEnable = (_layer as DATAnim).instantEnable

func onEnable():
	dynAnimHandler.onEnable()
	#if(!mainNode):
	#	mainNode = AnimationNodeOneShot.new()
	#	mainNode.fadein_curve = SMOOTH
	#	mainNode.fadeout_curve = SMOOTH
	#	filterBonesForAnimNode(mainNode, fileteredBonePaths)
	#	var theTrans:AnimationNodeTransition = AnimationNodeTransition.new()
	#	theTrans.input_count = NODE_AM
	#	theTrans.xfade_curve = SMOOTH
	#	transNode = theTrans
	#	for _i:int in NODE_AM:
	#		var theAnimNode:AnimationNodeAnimation = AnimationNodeAnimation.new()
	#		theAnimNode.animation = EMPTY_ANIM_NAME
	#		animNodes.append(theAnimNode)
	#		var theTimeScaleNode:AnimationNodeTimeScale = AnimationNodeTimeScale.new()
	#		timeScaleNodes.append(theTimeScaleNode)
	#	
	#setMyNode(mainNode)
	#addAnimNode(transNode, "trans")
	#
	#for _i:int in NODE_AM:
	#	var theAnimNode:AnimationNodeAnimation = animNodes[_i]
	#	theAnimNode.animation = EMPTY_ANIM_NAME
	#	addAnimNode(theAnimNode, str(_i))
	#	#animNodes.append(theAnimNode)
	#	#connectNodes("trans", _i, str(_i))
	#for _i:int in NODE_AM:
	#	var theTimeScaleNode:AnimationNodeTimeScale = timeScaleNodes[_i]
	#	addAnimNode(theTimeScaleNode, str(_i)+"_t")
	#	#animNodes.append(theAnimNode)
	#	connectNodes("trans", _i, str(_i)+"_t")
	#	connectNodes(str(_i)+"_t", 0, str(_i))
	#
	#connectNodes("", 1, "trans")

func onDisable():
	dynAnimHandler.onDisable()
	##mainNode = null
	##transNode = null
	##animNodes.clear()
	#disableTimer = 0.0
	#curNode = 0

func stop(_fade:float = -1.0):
	dynAnimHandler.stop(_fade)
	#
	#if(enabled):
	#	currentAnim = ""
	#	if(_fade >= 0.0):
	#		mainNode.fadeout_time = _fade
	#	tree["parameters/"+str(layerIndx)+"/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
	#	disableTimer = _fade
	#	startProcessingMe()

func getCurrent() -> String:
	return dynAnimHandler.getCurrent()

func play(_anim:String, _speed:float = 1.0, _fade:float = 0.25, _resetIfSame:bool = false, _backwards:bool = false):
	dynAnimHandler.play(_anim, _speed, _fade, _resetIfSame, _backwards)
	#
	#if(_anim.is_empty()):
	#	stop(_fade)
	#	return
	#if(curNode >= NODE_AM):
	#	curNode = 0
	#if(!_resetIfSame && currentAnim == _anim):
	#	tree["parameters/"+str(layerIndx)+"_"+str(curNode)+"_t/scale"] = _speed
	#	return
	#currentAnim = _anim
	#var wasEnabled:bool = enabled
	#setEnabled(true)
	#mainNode.fadein_time = _fade
	#mainNode.fadeout_time = _fade
	#transNode.xfade_time = _fade
	#
	#var theAnimNode:AnimationNodeAnimation = animNodes[curNode]
	#theAnimNode.animation = _anim
	#theAnimNode.play_mode = AnimationNodeAnimation.PLAY_MODE_BACKWARD if _backwards else AnimationNodeAnimation.PLAY_MODE_FORWARD
	#
	#tree["parameters/"+str(layerIndx)+"_"+str(curNode)+"_t/scale"] = _speed
	#
	#tree["parameters/"+str(layerIndx)+"_trans/transition_request"] = "state_"+str(curNode)
	#if(!wasEnabled || disableTimer > 0.0 || !tree["parameters/"+str(layerIndx)+"/active"]):
	#	tree["parameters/"+str(layerIndx)+"/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	#curNode += 1
	#disableTimer = 0.0

func processLayer(_dt:float) -> bool:
	return dynAnimHandler.processLayer(_dt)
	#
	#var shouldContinue:bool = false
	#if(disableTimer > 0.0):
	#	shouldContinue = true
	#	disableTimer -= _dt
	#	if(disableTimer <= 0.0):
	#		setEnabled(false)
	#
	#return shouldContinue

extends RefCounted
class_name DynAnimHandler

const NODE_AM:int = 2

var animNodes:Array[AnimationNodeAnimation]
var timeScaleNodes:Array[AnimationNodeTimeScale]
var curNode:int = 0
var mainNode:AnimationNodeOneShot
var transNode:AnimationNodeTransition
var disableTimer:float = 0.0
var currentAnim:String = ""

var datAnimRun:DATLayerRun
var customBlendTree:AnimationNodeBlendTree
var customParStr:String

var enabled:bool = false
var instantEnable:bool = true

func onEnable():
	if(!mainNode):
		mainNode = AnimationNodeOneShot.new()
		mainNode.fadein_curve = DATAnimRun.SMOOTH
		mainNode.fadeout_curve = DATAnimRun.SMOOTH
		datAnimRun.filterBonesForAnimNode(mainNode, datAnimRun.fileteredBonePaths)
		var theTrans:AnimationNodeTransition = AnimationNodeTransition.new()
		theTrans.input_count = NODE_AM
		theTrans.xfade_curve = DATAnimRun.SMOOTH
		transNode = theTrans
		for _i:int in NODE_AM:
			var theAnimNode:AnimationNodeAnimation = AnimationNodeAnimation.new()
			theAnimNode.animation = DATAnimRun.EMPTY_ANIM_NAME
			animNodes.append(theAnimNode)
			var theTimeScaleNode:AnimationNodeTimeScale = AnimationNodeTimeScale.new()
			timeScaleNodes.append(theTimeScaleNode)
	
	if(customBlendTree):
		#customBlendTree.add_node("main", mainNode)
		customBlendTree.add_node("trans", transNode)
		
		for _i:int in NODE_AM:
			var theAnimNode:AnimationNodeAnimation = animNodes[_i]
			theAnimNode.animation = DATAnimRun.EMPTY_ANIM_NAME
			customBlendTree.add_node(str(_i), theAnimNode)
		for _i:int in NODE_AM:
			var theTimeScaleNode:AnimationNodeTimeScale = timeScaleNodes[_i]
			customBlendTree.add_node(str(_i)+"_t", theTimeScaleNode)
			customBlendTree.connect_node("trans", _i, str(_i)+"_t")
			customBlendTree.connect_node(str(_i)+"_t", 0, str(_i))
		
	else:
		datAnimRun.setMyNode(mainNode)
		datAnimRun.addAnimNode(transNode, "trans")
	
		for _i:int in NODE_AM:
			var theAnimNode:AnimationNodeAnimation = animNodes[_i]
			theAnimNode.animation = DATAnimRun.EMPTY_ANIM_NAME
			datAnimRun.addAnimNode(theAnimNode, str(_i))
		for _i:int in NODE_AM:
			var theTimeScaleNode:AnimationNodeTimeScale = timeScaleNodes[_i]
			datAnimRun.addAnimNode(theTimeScaleNode, str(_i)+"_t")
			#animNodes.append(theAnimNode)
			datAnimRun.connectNodes("trans", _i, str(_i)+"_t")
			datAnimRun.connectNodes(str(_i)+"_t", 0, str(_i))
	
	if(!customBlendTree):
		datAnimRun.connectNodes("", 1, "trans")
	else:
		customBlendTree.connect_node("output", 0, "trans")
	enabled = true

func onDisable():
	#mainNode = null
	#transNode = null
	#animNodes.clear()
	disableTimer = 0.0
	curNode = 0
	enabled = false

func stop(_fade:float = -1.0):
	if(enabled):
		currentAnim = ""
		if(_fade >= 0.0):
			mainNode.fadeout_time = _fade
		if(customBlendTree):
			#datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
			pass
		else:
			datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
		disableTimer = _fade
		datAnimRun.startProcessingMe()

func play(_anim:String, _speed:float = 1.0, _fade:float = 0.25, _resetIfSame:bool = false, _backwards:bool = false):
	if(_anim.is_empty()):
		stop(_fade)
		return
	if(curNode >= NODE_AM):
		curNode = 0
	if(!_resetIfSame && currentAnim == _anim):
		if(customBlendTree):
			datAnimRun.tree["parameters/"+customParStr+"/"+str(curNode)+"_t/scale"] = _speed
		else:
			datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"_"+str(curNode)+"_t/scale"] = _speed
		return
	currentAnim = _anim
	var wasEnabled:bool = enabled
	if(customBlendTree):
		if(!enabled):
			onEnable()
	else:
		datAnimRun.setEnabled(true)
	if(!wasEnabled && instantEnable):
		mainNode.fadein_time = 0.0
		mainNode.fadeout_time = _fade
		transNode.xfade_time = 0.0
	else:
		mainNode.fadein_time = _fade
		mainNode.fadeout_time = _fade
		transNode.xfade_time = _fade
	
	var theAnimNode:AnimationNodeAnimation = animNodes[curNode]
	theAnimNode.animation = _anim
	theAnimNode.play_mode = AnimationNodeAnimation.PLAY_MODE_BACKWARD if _backwards else AnimationNodeAnimation.PLAY_MODE_FORWARD
	
	if(customBlendTree):
		datAnimRun.tree["parameters/"+customParStr+"/"+str(curNode)+"_t/scale"] = _speed
		datAnimRun.tree["parameters/"+customParStr+"/trans/transition_request"] = "state_"+str(curNode)
	else:
		datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"_"+str(curNode)+"_t/scale"] = _speed
		datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"_trans/transition_request"] = "state_"+str(curNode)
	
	if(!customBlendTree && (!wasEnabled || disableTimer > 0.0 || !datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"/active"])):
		datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	curNode += 1
	disableTimer = 0.0

func rerunTransition():
	var theNode:int = curNode - 1
	if(theNode < 0):
		theNode = NODE_AM - 1
	datAnimRun.tree["parameters/"+customParStr+"/trans/transition_request"] = "state_"+str(theNode)

func processLayer(_dt:float) -> bool:
	var shouldContinue:bool = false
	if(disableTimer > 0.0):
		shouldContinue = true
		disableTimer -= _dt
		if(disableTimer <= 0.0):
			if(!customBlendTree):
				datAnimRun.setEnabled(false)
			else:
				onDisable()
	
	return shouldContinue

func getCurrent() -> String:
	return currentAnim

extends RefCounted
class_name DynAnimHandlerAlt

var animNodes:Array[AnimationNodeAnimation]
#var timeScaleNodes:Array[AnimationNodeTimeScale]
#var subBlendTrees:Array[AnimationNodeBlendTree]
var curNode:int = 0
#var mainNode:AnimationNodeOneShot
var mainNode:AnimationNodeBlend2
var blendNode:AnimationNodeBlendSpace1D
#var transNode:AnimationNodeTransition
var oldAnim:String = ""
var currentAnim:String = ""
var curPos:float = 0.0
var switching:bool = false
var enableBlend:float = 0.0
var playTime:float = -1.0
var fadeInOut:float = 0.25
var stopping:bool = false

var datAnimRun:DATLayerRun
var customBlendTree:AnimationNodeBlendTree
var customParStr:String

var enabled:bool = false
var instantEnable:bool = true

func onEnable():
	if(!mainNode):
		mainNode = AnimationNodeBlend2.new()
		datAnimRun.filterBonesForAnimNode(mainNode, datAnimRun.fileteredBonePaths)
		var theBlend:AnimationNodeBlendSpace1D = AnimationNodeBlendSpace1D.new()
		blendNode = theBlend
		for _i:int in 2:
			var theAnimNode:AnimationNodeAnimation = AnimationNodeAnimation.new()
			theAnimNode.animation = DATAnimRun.EMPTY_ANIM_NAME
			animNodes.append(theAnimNode)
			var theTimeScaleNode:AnimationNodeTimeScale = AnimationNodeTimeScale.new() #parameters/TimeScale/scale
			var theTimeSeekNode:AnimationNodeTimeSeek = AnimationNodeTimeSeek.new() #parameters/TimeSeek/seek_request
			#timeScaleNodes.append(theTimeScaleNode)
			
			var theSubBlendTree:AnimationNodeBlendTree = AnimationNodeBlendTree.new()
			theSubBlendTree.add_node("a", theAnimNode)
			theSubBlendTree.add_node("s", theTimeSeekNode)
			theSubBlendTree.add_node("t", theTimeScaleNode)
			theSubBlendTree.connect_node("s", 0, "a")
			theSubBlendTree.connect_node("t", 0, "s")
			theSubBlendTree.connect_node("output", 0, "t")
			#subBlendTrees.append(theSubBlendTree)
			
			theBlend.add_blend_point(theSubBlendTree, 0.0 if (_i==0) else 1.0, _i, str(_i))
	
		if(customBlendTree):
			customBlendTree.add_node("blend", blendNode)
			customBlendTree.connect_node("output", 0, "blend")
			
	if(!customBlendTree):
		datAnimRun.setMyNode(mainNode)
		datAnimRun.addAnimNode(blendNode, "blend")
		datAnimRun.connectNodes("", 1, "blend")
		
	enabled = true

func onDisable():
	stopping = false
	curNode = 0
	enabled = false
	curPos = 0.0
	currentAnim = ""
	oldAnim = ""
	switching = false

func stop(_fade:float = -1.0):
	if(enabled):
		currentAnim = ""
		oldAnim = ""
		if(_fade >= 0.0):
			fadeInOut = _fade
		stopping = true
		datAnimRun.startProcessingMe()

func play(_anim:String, _speed:float = 1.0, _fade:float = 0.25, _resetIfSame:bool = false, _backwards:bool = false):
	if(_anim.is_empty()):
		stop(_fade)
		return
	if(!_resetIfSame && currentAnim == _anim):
		if(customBlendTree):
			datAnimRun.tree["parameters/"+customParStr+"/blend/"+str(curNode)+"/t/scale"] = _speed
		else:
			# blendspace(0_blend) / point(0) / a or t
			datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"_blend/"+str(curNode)+"/t/scale"] = _speed
		return

	curNode += 1
	if(curNode >= 2):
		curNode = 0
	
	var sameAsOld:bool = (oldAnim == _anim) && !_resetIfSame
	oldAnim = currentAnim
	currentAnim = _anim
	var wasEnabled:bool = enabled
	if(customBlendTree):
		if(!enabled):
			onEnable()
	else:
		datAnimRun.setEnabled(true)
	if(!wasEnabled && instantEnable):
		fadeInOut = _fade
	else:
		fadeInOut = _fade
	#if(!wasEnabled && instantEnable):
	#	mainNode.fadein_time = 0.0
	#	mainNode.fadeout_time = _fade
	#	#transNode.xfade_time = 0.0
	#else:
	#	mainNode.fadein_time = _fade
	#	mainNode.fadeout_time = _fade
	#	#transNode.xfade_time = _fade
	
	var theAnimNode:AnimationNodeAnimation = animNodes[curNode]
	theAnimNode.animation = _anim
	theAnimNode.play_mode = AnimationNodeAnimation.PLAY_MODE_BACKWARD if _backwards else AnimationNodeAnimation.PLAY_MODE_FORWARD
	
	var theAnim:Animation = datAnimRun.tree.getAnimation(_anim)
	playTime = theAnim.length/_speed if theAnim.loop_mode == Animation.LoopMode.LOOP_NONE else -1.0
	
	if(!sameAsOld):
		curPos = (1.0-float(curNode)) if wasEnabled else float(curNode)
		if(!wasEnabled && instantEnable):
			curPos = (1.0-float(curNode)) if !wasEnabled else float(curNode)
		
	if(customBlendTree):
		datAnimRun.tree["parameters/"+customParStr+"/blend/blend_position"] = DATLayerRun.SMOOTH.sample_baked(curPos)
		datAnimRun.tree["parameters/"+customParStr+"/blend/"+str(curNode)+"/t/scale"] = _speed
		datAnimRun.tree["parameters/"+customParStr+"/blend/"+str(curNode)+"/s/seek_request"] = 0.0
	else:
		datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"_blend/blend_position"] = DATLayerRun.SMOOTH.sample_baked(curPos)
		datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"_blend/"+str(curNode)+"/t/scale"] = _speed
		datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"_blend/"+str(curNode)+"/s/seek_request"] = 0.0
	
	stopping = false
	switching = true
	datAnimRun.startProcessingMe()

func rerunTransition():
	pass

func processLayer(_dt:float) -> bool:
	var shouldContinue:bool = false
	
	if(playTime > 0.0):
		playTime -= _dt
		if(playTime <= fadeInOut):
			stop(0.25)
	
	#if(disableTimer > 0.0):
	#	shouldContinue = true
	#	disableTimer -= _dt
	#	if(disableTimer <= 0.0):
	#		if(!customBlendTree):
	#			datAnimRun.setEnabled(false)
	#		else:
	#			onDisable()
	#		curPos = float(curNode)
	
	var theEffectiveFadeSpeed:float = (_dt/fadeInOut) if fadeInOut != 0.0 else 10000.0
	
	if(switching):
		var theTargetPos:float = float(curNode)
		curPos = moveValueTo(curPos, theTargetPos, theEffectiveFadeSpeed)
		if(absf(curPos-theTargetPos) < 0.00001):
			curPos = theTargetPos
			switching = false
		if(customBlendTree):
			datAnimRun.tree["parameters/"+customParStr+"/blend/blend_position"] = DATLayerRun.SMOOTH.sample_baked(curPos)
		else:
			datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"_blend/blend_position"] = DATLayerRun.SMOOTH.sample_baked(curPos)
	
	var theIsEnabled:bool = !stopping
	if(theIsEnabled && enabled && enableBlend < 1.0):
		shouldContinue = true
		enableBlend += theEffectiveFadeSpeed
		if(enableBlend > 1.0):
			enableBlend = 1.0
	elif(!theIsEnabled):
		shouldContinue = true
		enableBlend -= theEffectiveFadeSpeed
		if(enableBlend < 0.0):
			enableBlend = 0.0
			if(!customBlendTree):
				datAnimRun.setEnabled(false)
			else:
				onDisable()
			return false
	if(!customBlendTree && enabled):
		datAnimRun.tree["parameters/"+str(datAnimRun.layerIndx)+"/blend_amount"] = DATLayerRun.SMOOTH.sample_baked(enableBlend)
	
	return shouldContinue || switching || (playTime > 0.0)

func getCurrent() -> String:
	return currentAnim

func moveValueTo(_val:float, _to:float, _speed:float) -> float:
	var _diff:float = _to - _val
	if(_diff > 0.0):
		_diff = minf(_diff, _speed)
		_val += _diff
		if(_val > _to):
			_val = _to
		return _val
	if(_diff < 0.0):
		_diff = maxf(_diff, _speed)
		_val -= _diff
		if(_val < _to):
			_val = _to
		return _val
	return _val

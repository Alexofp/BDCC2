extends DATLayerRun
class_name DATBlend2DRun

var handlers:Dictionary[int, DynAnimHandlerAlt]
var mainNode:AnimationNodeBlend2
var blendNode:AnimationNodeBlendSpace2D
var blendTrees:Dictionary[int, AnimationNodeBlendTree]
var shouldDisable:bool = false
var currentEnable:float = 0.0
var blendInOut:float = 0.25
var targetPos:Vector2
var currentPos:Vector2
var smoothEnabled:bool = true
var smoothSpeed:float = 1.0

func onCreated(_layer:DATLayer):
	#dynAnimHandler.instantEnable = (_layer as DATAnim).instantEnable
	if(_layer is DATBlend2D):
		for theIndex:int in _layer.points:
			var theBlendpoint:DATBlend2D.BlendPoint = _layer.points[theIndex]
			#theBlendpoint.
			var newHandler:DynAnimHandlerAlt = DynAnimHandlerAlt.new()
			handlers[theIndex] = newHandler
			
			#var theCustomBlendTree:AnimationNodeBlendTree = AnimationNodeBlendTree.new()
			
			newHandler.datAnimRun = self
			#if(!theBlendpoint.defaultAnim.is_empty()):
			#	newHandler.play(theBlendpoint.defaultAnim, theBlendpoint.defaultSpeed, 0.0, false, theBlendpoint.defaultBackwards)

func play(_fade:float = 0.25):
	if(enabled):
		return
	blendInOut = _fade
	setEnabled(true)
	#mainNode.fadein_time = _fade
	#mainNode.fadeout_time = _fade
	
	#if(disableTimer > 0.0 || !tree["parameters/"+str(layerIndx)+"/active"]):
	#	tree["parameters/"+str(layerIndx)+"/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	tree["parameters/"+str(layerIndx)+"/blend_amount"] = 1.0
	
	#transNode.xfade_time = _fade

func playAnim(_index:int, _newAnim:String, _speed:float = 1.0, _fade:float = 0.25, _resetIfSame:bool = false, _playBackwards:bool = false):
	#setEnabled(true)
	var theHandler:DynAnimHandlerAlt = handlers[_index]
	theHandler.play(_newAnim, _speed, _fade, _resetIfSame, _playBackwards)
	

func stop(_fade:float = -1.0):
	if(enabled):
		#currentAnim = ""
		if(_fade >= 0.0):
			blendInOut = _fade
		#	mainNode.fadeout_time = _fade
		#tree["parameters/"+str(layerIndx)+"/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
		
		#tree["parameters/"+str(layerIndx)+"/blend_amount"] = 0.0
		#disableTimer = _fade
		shouldDisable = true
		startProcessingMe()

func setPos(_pos:Vector2, _enableIfNot:bool = true, _fade:float = 0.25):
	if(_enableIfNot && !enabled):
		play(_fade)
	targetPos = _pos
	if(!smoothEnabled):
		tree["parameters/"+str(layerIndx)+"_blend/blend_position"] = _pos
		currentPos = _pos
		#print(tree["parameters/"+str(layerIndx)+"_blend/blend_position"])
	else:
		startProcessingMe()
		pass
	
	

func onEnable():
	if(!mainNode):
		mainNode = AnimationNodeBlend2.new()
		#mainNode.fadein_curve = SMOOTH
		#mainNode.fadeout_curve = SMOOTH
		
		#mainNode.sync = true
		filterBonesForAnimNode(mainNode, fileteredBonePaths)
		
		blendNode = AnimationNodeBlendSpace2D.new()
		blendNode.max_space = Vector2(3.0, 3.0)
		blendNode.min_space = Vector2(-3.0, -3.0)
		for _index:int in handlers:
			var theDynHandler:DynAnimHandlerAlt = handlers[_index]
			var theBlendpoint:DATBlend2D.BlendPoint = (layer as DATBlend2D).points[_index]
			var newBlendTree:AnimationNodeBlendTree = AnimationNodeBlendTree.new()
			blendTrees[_index] = newBlendTree
			theDynHandler.customBlendTree = newBlendTree
			
			blendNode.add_blend_point(newBlendTree, theBlendpoint.point, _index, str(_index))
			
			theDynHandler.customParStr = str(layerIndx)+"_blend/"+str(_index)
			
			#if(!theBlendpoint.defaultAnim.is_empty()):
			#	theDynHandler.play(theBlendpoint.defaultAnim, theBlendpoint.defaultSpeed, 0.0, false, theBlendpoint.defaultBackwards)
			#else:
			#	theDynHandler.onEnable()
			
	setMyNode(mainNode)
	addAnimNode(blendNode, "blend")
	connectNodes("", 1, "blend")
	
	for _index:int in handlers:
		var theDynHandler:DynAnimHandlerAlt = handlers[_index]
		var theBlendpoint:DATBlend2D.BlendPoint = (layer as DATBlend2D).points[_index]
		if(!theBlendpoint.defaultAnim.is_empty()):
			theDynHandler.play(theBlendpoint.defaultAnim, theBlendpoint.defaultSpeed, 0.0, false, theBlendpoint.defaultBackwards)
		else:
			theDynHandler.onEnable()
	#	if(!theBlendpoint.defaultAnim.is_empty()):
	#		theDynHandler.play(theBlendpoint.defaultAnim, theBlendpoint.defaultSpeed, 0.0, false, theBlendpoint.defaultBackwards)
	for _index:int in handlers:
		var theDynHandler:DynAnimHandlerAlt = handlers[_index]
		theDynHandler.rerunTransition()
	#	theDynHandler.onEnable()

func onDisable():
	#disableTimer = 0.0
	shouldDisable = false
	targetPos = Vector2.ZERO
	currentPos = Vector2.ZERO
	for _index:int in handlers:
		var theDynHandler:DynAnimHandlerAlt = handlers[_index]
		theDynHandler.onDisable()

func processLayer(_dt:float) -> bool:
	var shouldProcess:bool = false
	for _index:int in handlers:
		var theHandler:DynAnimHandlerAlt = handlers[_index]
		if(theHandler.processLayer(_dt)):
			shouldProcess = true
	if(shouldDisable):
		shouldProcess = true
		if(blendInOut != 0.0):
			currentEnable -= _dt/blendInOut
		else:
			currentEnable = 0.0
		#disableTimer = 0.0#-= _dt
		if(currentEnable <= 0.0):
			setEnabled(false)
			return false
		#tree["parameters/"+str(layerIndx)+"/blend_amount"] = (currentEnable / blendInOut) if blendInOut != 0.0 else 1.0
	elif(currentEnable < 1.0):
		shouldProcess = true
		if(blendInOut != 0.0):
			currentEnable += _dt/blendInOut
		else:
			currentEnable = 1.0
		if(currentEnable > 1.0):
			currentEnable = 1.0
	tree["parameters/"+str(layerIndx)+"/blend_amount"] = SMOOTH.sample_baked(currentEnable)
	
	if(smoothEnabled && enabled):
		var theCurPos:Vector2 = currentPos#tree["parameters/"+str(layerIndx)+"_blend/blend_position"]
		if(targetPos.distance_squared_to(theCurPos) < 0.00001):
			theCurPos = targetPos
		else:
			theCurPos = moveVec2To(theCurPos, targetPos, _dt*smoothSpeed)
			#print(theCurPos)
			shouldProcess = true
		tree["parameters/"+str(layerIndx)+"_blend/blend_position"] = theCurPos
		currentPos = theCurPos
	
	return shouldProcess

func moveVec2To(_origValue:Vector2, _targetValue:Vector2, _speed:float) -> Vector2:
	var theDiff:Vector2 = _targetValue - _origValue
	var theLen:float = theDiff.length()
	
	if(theLen <= 0.00001):
		return _targetValue
	if(theLen < _speed):
		_speed = theLen
	var newDiff:Vector2 = theDiff / theLen * _speed
	return _origValue + newDiff
	
func getCurrent(_index:int) -> String:
	if(!handlers.has(_index)):
		return ""
	return handlers[_index].getCurrent()

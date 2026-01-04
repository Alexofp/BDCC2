extends AnimSceneBaseFuncs
class_name AnimSceneBase

signal onAnimUpdate

func calculateStateAnimData():
	animData.clear()
	
	var seatID:String = sitters.keys()[0]
	var seatInfo:Sitter = sitters[seatID]
	var animPlayer:AnimationPlayer = seatInfo.anim
	
	for stateID in states:
		var stateInfo:AnimSceneState = states[stateID]
		var animName:String = stateInfo.anims[seatID]
		var theAnimation:Animation = animPlayer.get_animation(animName)
		
		animData[stateID] = {
			len = theAnimation.length,
			loop = theAnimation.loop_mode,
			step = theAnimation.step,
		}
	
	for extraLayer in extraLayers:
		var theType:int = extraLayer.getType()
		var layerID:String = extraLayer.id
		
		if(theType == LAYER_ONESHOT):
			var oneshotID:String = layerID
			var oneshotData :AnimSceneExtraLayerOneshot= extraLayer
			
			var oneshotAnimName:String = oneshotData.anims[seatID]
			var theAnimation:Animation = animPlayer.get_animation(oneshotAnimName)
			
			animData[oneshotID] = {
				len = theAnimation.length,
				loop = theAnimation.loop_mode,
				step = theAnimation.step,
			}
		elif(theType == LAYER_ADD3):
			var theAnimName:String = extraLayer.animsPlus[seatID]
			var theAnimation:Animation = animPlayer.get_animation(theAnimName)
			animData[layerID] = {
				len = theAnimation.length,
				loop = theAnimation.loop_mode,
				step = theAnimation.step,
			}

func updateAllAnimTrees():
	#Only needed for sitters (dolls)
	for seatID in sitters:
		updateAnimPlayerFor(seatID)
	for propID in props:
		var thePropInfo:PropSlot = props[propID]
		var theAnimPlayer:AnimationPlayer = thePropInfo.anim
		for animLibraryID in thePropInfo.animLibraries:
			theAnimPlayer.add_animation_library(animLibraryID, load(thePropInfo.animLibraries[animLibraryID]))
	
	calculateStateAnimData()
	updateMainAnimTree()
	
	for seatID in sitters:
		updateAnimTreeFor(seatID, UPDATE_SITTER)
	for propID in props:
		updateAnimTreeFor(propID, UPDATE_PROP)

func updateMainAnimTree():
	if(mainAnimPlayer):
		mainAnimPlayer.queue_free()
		mainAnimPlayer = null
	if(mainAnimTree):
		mainAnimTree.queue_free()
		mainAnimTree = null
	
	mainAnimPlayer = AnimationPlayer.new()
	mainAnimPlayer.name = "MainAnimPlayer"
	mainAnimPlayer.root_node = NodePath("..")
	add_child(mainAnimPlayer)
	mainAnimTree = AnimationTree.new()
	mainAnimTree.name = "MainAnimTree"
	mainAnimTree.root_node = NodePath("..")
	add_child(mainAnimTree)
	mainAnimTree.anim_player = mainAnimTree.get_path_to(mainAnimPlayer)
	
	var mainAnimationLibrary:AnimationLibrary = AnimationLibrary.new()
	
	for stateID in states:
		var stateInfo:AnimSceneState = states[stateID]
		var newAnim:Animation = Animation.new()
		
		newAnim.step = animData[stateID]["step"]
		newAnim.length = animData[stateID]["len"]
		newAnim.loop_mode = animData[stateID]["loop"]
		
		var newTrack = newAnim.add_track(Animation.TYPE_METHOD)
		newAnim.track_set_path(newTrack, NodePath("."))
		
		for theAnimEvent in stateInfo.animEvents:
			var theTime:float = float(theAnimEvent[0])
			var theArg:String = theAnimEvent[1]
			
			newAnim.track_insert_key(newTrack, theTime, {
				method = "sendAnimationEvent",
				args = [theArg],
			})
		#newAnim.track_set_key_value()
		
		mainAnimationLibrary.add_animation(stateID, newAnim)
	
	for extraLayer in extraLayers:
		var layerType:int = extraLayer.getType()
		var layerID:String = extraLayer.id
		if(layerType == LAYER_ONESHOT):
			var oneshotID:String = layerID
			var oneShotInfo:AnimSceneExtraLayerOneshot = extraLayer
			
			var newAnim:Animation = Animation.new()
			
			newAnim.step = animData[oneshotID]["step"]
			newAnim.length = animData[oneshotID]["len"]
			newAnim.loop_mode = animData[oneshotID]["loop"]
			
			var newTrack = newAnim.add_track(Animation.TYPE_METHOD)
			newAnim.track_set_path(newTrack, NodePath("."))
			
			var animEvents:Array = oneShotInfo.animEvents
			
			for theAnimEvent in animEvents:
				var theTime:float = float(theAnimEvent[0])
				var theArg:String = theAnimEvent[1]
				
				newAnim.track_insert_key(newTrack, theTime, {
					method = "sendAnimationEvent",
					args = [theArg],
				})
			
			mainAnimationLibrary.add_animation(oneshotID, newAnim)
		elif(layerType == LAYER_ADD3):
			var newAnim:Animation = Animation.new()
			newAnim.step = animData[layerID]["step"]
			newAnim.length = animData[layerID]["len"]
			newAnim.loop_mode = animData[layerID]["loop"]
			mainAnimationLibrary.add_animation(layerID, newAnim)
		
	mainAnimPlayer.add_animation_library("main", mainAnimationLibrary)
	
	updateAnimTreeFor("MAIN", UPDATE_MAIN)

func setAdd3ValueGlobal(_id:String, _val:float):
	setAdd3Value(_id, _val)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(setAdd3Value_RPC.bind(_id, _val))

@rpc("authority", "call_remote", "reliable")
func setAdd3Value_RPC(_id:String, _val:float):
	setAdd3Value(_id, _val)

func playOneShotGlobal(oneshotID:String):
	playOneShot(oneshotID)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(playOneShot_RPC.bind(oneshotID))

@rpc("authority", "call_remote", "reliable")
func playOneShot_RPC(oneshotID:String):
	playOneShot(oneshotID)

# Networked version of playState
func playStateGlobal(newState:String, setToState:bool=false, theAnimArgs:Dictionary = {}):
	playState(newState, setToState, theAnimArgs)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(playState_RPC.bind(newState, setToState, theAnimArgs))

@rpc("authority", "call_remote", "reliable")
func playState_RPC(newState:String, setToState:bool, theAnimArgs:Dictionary):
	playState(newState, setToState, theAnimArgs)

func playState(newState:String, setToState:bool=false, theAnimArgs:Dictionary = {}):
	setStateSpeed(state, 1.0)
	
	state = newState
	
	setStateSpeed(state, 1.0)
	startSpeedSwitchTimer()
	
	if(setToState):
		updateAnim()
		onPlayState(newState, theAnimArgs)
		return
	for sitterID in sitters:
		var theSpot := getSpot(sitterID)
		if(theSpot):
			theSpot.dollAnimKey = id+"_"+state+"_"+sitterID
		var sitterInfo:Sitter = sitters[sitterID]
		var animTree:AnimationTree = sitterInfo.tree
		
		var animTreePlayback:AnimationNodeStateMachinePlayback = animTree["parameters/blendtree/statemachine/playback"]
		animTreePlayback.travel(newState)
	for propID in props:
		var propInfo:PropSlot = props[propID]
		var animTree:AnimationTree = propInfo.tree
		
		var animTreePlayback:AnimationNodeStateMachinePlayback = animTree["parameters/blendtree/statemachine/playback"]
		animTreePlayback.travel(newState)
	
	
	
	var mainAnimTreePlayback:AnimationNodeStateMachinePlayback = mainAnimTree["parameters/blendtree/statemachine/playback"]
	mainAnimTreePlayback.travel(newState)
	onPlayState(newState, theAnimArgs)
	doCharChecksAfterPlay()
	afterAnyAnimPlay()#updateAnimWhenDollsChange()

func afterAnyAnimPlay():
	updateAnimWhenDollsChange()
	
	var stateInfo:= getCurrentStateData()
	if(stateInfo):
		for sitterID in sitters:
			var theDoll := getSitterDoll(sitterID)
			if(!theDoll):
				continue
			var theFlags:Dictionary = stateInfo.flags.get(sitterID, {})
			theDoll.getDoll().setAnimationPartFlags(theFlags)

const UPDATE_SITTER = 0
const UPDATE_MAIN = 1
const UPDATE_PROP = 2

func updateAnimTreeFor(seatID:String, _mode:int):
	var animTree:AnimationTree
	#var isMain:bool = (_mode == UPDATE_MAIN)
	
	if(_mode == UPDATE_MAIN):
		seatID = "MAIN"
		animTree = mainAnimTree
		#isMain = true
	elif(_mode == UPDATE_SITTER):
		var seatInfo:Sitter = sitters[seatID]
		animTree = seatInfo.tree
	elif(_mode == UPDATE_PROP):
		var propInfo:PropSlot = props[seatID]
		animTree = propInfo.tree
	else:
		assert(false, "UNKNOWN UPDATE MODE")
	
	var supportsCache:bool = !id.is_empty()
	var cacheKey:String = id+"_"+seatID
	
	if(!supportsCache || !GlobalRegistry.dollAnimTreeCache.has(cacheKey)):
		var theStateMachine := AnimationNodeStateMachine.new()
		for stateID in states:
			var stateInfo:AnimSceneState = states[stateID]
			
			var blendTreeNode := AnimationNodeBlendTree.new()
			theStateMachine.add_node(stateID, blendTreeNode)
			
			var timeScaleNode := AnimationNodeTimeScale.new()
			blendTreeNode.add_node("timeScale", timeScaleNode)
			
			var animNode := AnimationNodeAnimation.new()
			
			var theAnimName:String = ""
			if(_mode == UPDATE_SITTER):
				theAnimName = stateInfo.anims[seatID]
			elif(_mode == UPDATE_MAIN):
				theAnimName = "main/"+stateID
			elif(_mode == UPDATE_PROP):
				# propAnims?
				theAnimName = stateInfo.anims[seatID]
			
			animNode.animation = theAnimName
			blendTreeNode.add_node("anim", animNode)
			
			blendTreeNode.connect_node("timeScale", 0, "anim")
			blendTreeNode.connect_node("output", 0, "timeScale")
			#theStateMachine.add_node(stateID, animNode)
		
		var startTrans := AnimationNodeStateMachineTransition.new()
		startTrans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
		theStateMachine.add_transition("Start", startState, startTrans)
		
		for stateID in states:
			var stateInfo:AnimSceneState = states[stateID]
			var stateConnections:Dictionary = stateInfo.connections
			
			for otherStateID in stateConnections:
				var connectionInfo:Dictionary = stateConnections[otherStateID]
				var interpolationTime:float = connectionInfo["time"]
				var autoAdvanceAtEnd:bool = connectionInfo["auto"] if connectionInfo.has("auto") else false
				var stateTrans := AnimationNodeStateMachineTransition.new()
				stateTrans.xfade_time = interpolationTime
				stateTrans.xfade_curve = preload("res://AnimScenes/SmoothInterpolation.tres")
				if(autoAdvanceAtEnd):
					stateTrans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
					stateTrans.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
				#stateTrans.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_SYNC
				theStateMachine.add_transition(stateID, otherStateID, stateTrans)
		
		var finalBlendTree:AnimationNodeBlendTree = AnimationNodeBlendTree.new()
		
		finalBlendTree.add_node("statemachine", theStateMachine)
		
		var currentStateName:String = "statemachine"
		
		for extraLayer in extraLayers:
			var layerType:int = extraLayer.getType()
			var layerID:String = extraLayer.id
			
			if(layerType == LAYER_ADD3):
				if(_mode == UPDATE_MAIN):
					var theAnimName:String = "main/"+layerID
					if(true):
						var animNode := AnimationNodeAnimation.new()
						animNode.animation = theAnimName
						finalBlendTree.add_node(layerID+"_animPlus", animNode)
					if(true):
						var animNode := AnimationNodeAnimation.new()
						animNode.animation = theAnimName
						finalBlendTree.add_node(layerID+"_animMinus", animNode)
					var theAdd3Node := AnimationNodeAdd3.new()
					finalBlendTree.add_node(layerID, theAdd3Node)
					finalBlendTree.connect_node(layerID, 1, currentStateName)
					finalBlendTree.connect_node(layerID, 0, layerID+"_animPlus")
					finalBlendTree.connect_node(layerID, 2, layerID+"_animMinus")
				else:
					var add3AnimNamePlus:String = extraLayer.animsPlus[seatID]
					var add3AnimNameMinus:String = extraLayer.animsMinus[seatID]
					var add3BaseAnimName:String = extraLayer.baseAnims[seatID]
					
					if(true):
						var animNode := AnimationNodeAnimation.new()
						animNode.animation = add3AnimNamePlus
						finalBlendTree.add_node(layerID+"_animPlus", animNode)
					if(true):
						var animNode := AnimationNodeAnimation.new()
						animNode.animation = add3AnimNameMinus
						finalBlendTree.add_node(layerID+"_animMinus", animNode)
					if(true):
						var animNode := AnimationNodeAnimation.new()
						animNode.animation = add3BaseAnimName
						finalBlendTree.add_node(layerID+"_basePlus", animNode)
					if(true):
						var animNode := AnimationNodeAnimation.new()
						animNode.animation = add3BaseAnimName
						finalBlendTree.add_node(layerID+"_baseMinus", animNode)
					
					if(true):
						var subNode := AnimationNodeSub2.new()
						finalBlendTree.add_node(layerID+"_subPlus", subNode)
						finalBlendTree.connect_node(layerID+"_subPlus", 0, layerID+"_animPlus")
						finalBlendTree.connect_node(layerID+"_subPlus", 1, layerID+"_basePlus")
					if(true):
						var subNode := AnimationNodeSub2.new()
						finalBlendTree.add_node(layerID+"_subMinus", subNode)
						finalBlendTree.connect_node(layerID+"_subMinus", 0, layerID+"_animMinus")
						finalBlendTree.connect_node(layerID+"_subMinus", 1, layerID+"_baseMinus")
			
					var add3Node := AnimationNodeAdd3.new()
					finalBlendTree.add_node(layerID, add3Node)
					
					finalBlendTree.connect_node(layerID, 2, layerID+"_subPlus")
					finalBlendTree.connect_node(layerID, 1, currentStateName)
					finalBlendTree.connect_node(layerID, 0, layerID+"_subMinus")
					
				currentStateName = layerID
			
			if(layerType == LAYER_ONESHOT):
				var oneshotID:String = layerID
				var oneshotData:AnimSceneExtraLayerOneshot = extraLayer
				
				if(_mode == UPDATE_MAIN):
					var oneshotAnimName:String = "main/"+oneshotID
					if(true):
						var animNode := AnimationNodeAnimation.new()
						animNode.animation = oneshotAnimName
						finalBlendTree.add_node(oneshotID+"_anim", animNode)
					var oneshotNode := AnimationNodeOneShot.new()
					oneshotNode.mix_mode = AnimationNodeOneShot.MIX_MODE_ADD
					finalBlendTree.add_node(oneshotID, oneshotNode)
					finalBlendTree.connect_node(oneshotID, 0, currentStateName)
					finalBlendTree.connect_node(oneshotID, 1, oneshotID+"_anim")
				else:
					#var oneshotData:Dictionary = oneShots[oneshotID]
					var oneshotAnimName:String = oneshotData.anims[seatID]
					var oneshotBaseAnimName:String = oneshotData.baseAnims[seatID]
					#var _settings:Dictionary = oneshotData["settings"]
					
					if(true):
						var animNode := AnimationNodeAnimation.new()
						animNode.animation = oneshotAnimName
						finalBlendTree.add_node(oneshotID+"_anim", animNode)
					if(true):
						var animNode := AnimationNodeAnimation.new()
						animNode.animation = oneshotBaseAnimName
						finalBlendTree.add_node(oneshotID+"_base", animNode)
					
					var subNode := AnimationNodeSub2.new()
					finalBlendTree.add_node(oneshotID+"_sub", subNode)
					finalBlendTree.connect_node(oneshotID+"_sub", 0, oneshotID+"_anim")
					finalBlendTree.connect_node(oneshotID+"_sub", 1, oneshotID+"_base")
					#finalBlendTree.connect_node(oneshotID+"_sub", 1, "statemachine")
					
					var oneshotNode := AnimationNodeOneShot.new()
					oneshotNode.mix_mode = AnimationNodeOneShot.MIX_MODE_ADD
					finalBlendTree.add_node(oneshotID, oneshotNode)
					
					finalBlendTree.connect_node(oneshotID, 0, currentStateName)
					finalBlendTree.connect_node(oneshotID, 1, oneshotID+"_sub")
					
				currentStateName = oneshotID
				
		finalBlendTree.connect_node("output", 0, currentStateName)
		
		var finalFinalBlendTree:AnimationNodeBlendTree
		if(_mode == UPDATE_SITTER):
			finalFinalBlendTree = animTree.tree_root.duplicate(true)
			finalFinalBlendTree.add_node("blendtree", finalBlendTree)
			finalFinalBlendTree.get_node("LayeredAnimPlayerStart").add_input("SEX")
			finalFinalBlendTree.connect_node("LayeredAnimPlayerStart", 0, "blendtree")
		else:
			finalFinalBlendTree = AnimationNodeBlendTree.new()
			finalFinalBlendTree.add_node("blendtree", finalBlendTree)
			finalFinalBlendTree.connect_node("output", 0, "blendtree")
		
		if(supportsCache):
			GlobalRegistry.dollAnimTreeCache[cacheKey] = finalFinalBlendTree
			#GlobalRegistry.dollAnimTreeLayerCache[cacheKey] = extraLayersByID
		
		#animTree.tree_root = theStateMachine
		animTree.tree_root = finalFinalBlendTree
	else:
		#print("REUSED ANIM TREE FOR CACHE KEY: "+str(cacheKey))
		animTree.tree_root = GlobalRegistry.dollAnimTreeCache[cacheKey]
		#extraLayersByID = GlobalRegistry.dollAnimTreeLayerCache[cacheKey]
	
	if(_mode != UPDATE_MAIN):
		if(_mode == UPDATE_SITTER):
			animTree["parameters/LayeredAnimPlayerStart/transition_request"] = "SEX"
		for extraLayer in extraLayers:
			var layerType:int = extraLayer.getType()
			var layerID:String = extraLayer.id
			
			if(layerType == LAYER_ONESHOT):
				var oneshotID:String = layerID
				animTree["parameters/blendtree/"+oneshotID+"_sub/sub_amount"] = 1.0
			elif(layerType == LAYER_ADD3):
				animTree["parameters/blendtree/"+layerID+"_subPlus/sub_amount"] = 1.0
				animTree["parameters/blendtree/"+layerID+"_subMinus/sub_amount"] = 1.0
		#for oneshotID in oneShots:
		#	animTree["parameters/blendtree/"+oneshotID+"_sub/sub_amount"] = 1.0
		
	for stateID in states:
		var stateInfo:AnimSceneState = states[stateID]
		animTree["parameters/blendtree/statemachine/"+stateID+"/timeScale/scale"] = stateInfo.baseSpeed

func updateAnim():
	for sitterID in sitters:
		var theSpot := getSpot(sitterID)
		if(theSpot):
			theSpot.dollAnimKey = id+"_"+state+"_"+sitterID
		deferUpdateAnimSitter.call_deferred(sitterID)
	for propID in props:
		#var theSpot := getSpotProp(propID)
		#if(theSpot):
		#	theSpot.dollAnimKey = id+"_"+state+"_"+sitterID
		deferUpdateAnimProp.call_deferred(propID)
		
	deferUpdateMainAnimTree.call_deferred()
	
	onAnimUpdate.emit()
	doCharChecksAfterPlay()
	afterAnyAnimPlay()

func deferUpdateMainAnimTree():
	mainAnimTree["parameters/blendtree/statemachine/playback"].start(state, true)

func deferUpdateAnimProp(propID:String):
	var propInfo:PropSlot = props[propID]
	var animTree:AnimationTree = propInfo.tree
	
	var theProp := propInfo.spot.getProp()
	
	if(theProp):
#func applyAnimPlayerToProp(user: DollController, theAnimPlayer:AnimationMixer):
		var theSkeleton:Skeleton3D = theProp.getPropSkeleton()
		theSkeleton.reset_bone_poses()
		animTree.root_node = animTree.get_path_to(theProp)#animTree.get_path_to(theSkeleton)
		#user.getBodySkeleton().resetBones()
		#theAnimPlayer.root_node = theAnimPlayer.get_path_to(user.getBodySkeleton())

		animTree.active = true
		animTree["parameters/blendtree/statemachine/playback"].start(state, true)
	else:
		animTree.active = false
		animTree.root_node = NodePath("")

func deferUpdateAnimSitter(sitterID:String):
	var sitterInfo:Sitter = sitters[sitterID]
	var animTree:AnimationTree = sitterInfo.tree
	
	var sitDoll:DollController = getSitterDoll(sitterID)
	
	if(sitDoll):
		applyAnimPlayer(sitDoll, animTree)
		animTree.active = true
		animTree["parameters/blendtree/statemachine/playback"].start(state, true)
	else:
		animTree.active = false
		animTree.root_node = NodePath("")
	
	updatePenisTargetFor(sitterID)

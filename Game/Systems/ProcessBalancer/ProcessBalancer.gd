extends Node

## This node attempts to reduce the overall amount of _process calls that get called every frame.

var ticks:int = 0

const MAX_LAYERED_TEXTURE_UPDATES_PER_FRAME = 1
var layeredTextures:Array[MyLayeredTexture] = []
var curLayeredTextures:int = 0

var dollsToUpdate:Array[Doll] = []
var thingsToUpdate:Array[Node] = []

var wiggleModifiers:Array[DMWBWiggleRotationModifier3D] = []

var updateTimer:float = 0.0

func _ready() -> void:
	LoadSpreader.register(self)
	LoadSpreader.register(self, 0.016, 1)

#func processScheduled(_dt:float, _key:int):
#	pass

#func _process(_delta: float) -> void:
#	processThings(_delta)
	
func processScheduled(_delta:float, _key:int):
	if(_key == 1):
		processThings(_delta)
		return
	
	ticks += 1
	var camera:Camera3D = get_viewport().get_camera_3d()
	
	if(!camera):
		return
	
	for wiggleMod in wiggleModifiers:
		var theDist:float = wiggleMod.global_position.distance_squared_to(camera.global_position)
		wiggleMod.manualTurnOff = (theDist > 30.0)
		
		#TODO: Do the influence calculation here
		#wiggleMod.active = (wiggleMod.influence > 0.0 && wiggleMod.is_visible_in_tree())
		wiggleMod.active = wiggleMod.is_visible_in_tree()
	
	#for animTree in animTrees:
		#var animNode = animTree.get_parent()
		#while(animNode && !(animNode is Node3D)):
			#animNode = animNode.get_parent()
		#if(!animNode || !camera):
			#continue
			
		#var howOft:int = 1
		#var theDist:float = animNode.global_position.distance_squared_to(camera.global_position)
		#if(theDist > 100.0):
			#howOft = 2
		#if(theDist > 200.0):
			#howOft = 3
		#if(theDist > 500.0):
			#howOft = 5
		#if(theDist > 1000.0):
			#howOft = 10
		#howOft = 1 #TODO: FIX THIS?
		
		#if(true):
			#animTree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
			#var animPlayer:AnimationPlayer = animTree.get_node(animTree.anim_player)
			#if(animPlayer):
				#animPlayer.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
		#if(howOft <= 1 || ((hash(animTree)+ticks) % howOft)==0):
		#	animTree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		#	animTree.advance(_delta*howOft)
			#var animPlayer:AnimationPlayer = animTree.get_node(animTree.anim_player)
			#if(animPlayer):
			#	animPlayer.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
			#	animPlayer.advance(_delta)
				
# LAYERED TEXTURES UPDATE
func updateLayeredTexturesAlways(_delta:float):
	if(layeredTextures.is_empty()):
		return
	var camera:Camera3D = get_viewport().get_camera_3d()
	if(!camera):
		return
	
	var toUpdate:int = MAX_LAYERED_TEXTURE_UPDATES_PER_FRAME
	var didUpdate:int = 0
	var theAmount:int = layeredTextures.size()
	while(toUpdate > 0 && didUpdate < theAmount):
		if(curLayeredTextures >= theAmount):
			curLayeredTextures = 0
		
		var theTexture:MyLayeredTexture = layeredTextures[curLayeredTextures]
		var theCamera:Camera3D = theTexture.get_viewport().get_camera_3d()
		curLayeredTextures += 1
		didUpdate += 1
		toUpdate -= 1
		
		var theParent:Node = theTexture.get_parent()
		if(!theParent || !(theParent is Node3D)):
			continue
		#var camera:Camera3D = get_viewport().get_camera_3d()
		if(!theCamera):
			continue
		var distSqr:float = theCamera.global_position.distance_squared_to(theParent.global_position)
		
		if(distSqr < 1000.0):
			theTexture.farTimer = 5.0
		else:
			theTexture.farTimer -= _delta
		
		if(theTexture.textureSpawned && theTexture.farTimer <= 0.0):
			theTexture.textureSpawned = false
			theTexture.markDirty()
		elif(!theTexture.textureSpawned && theTexture.farTimer > 0.0):
			theTexture.textureSpawned = true
			theTexture.markDirty()
	# LAYERED TEXTURES UPDATE END

func addLayeredTexture(_texture:MyLayeredTexture):
	layeredTextures.append(_texture)

func removeLayeredTexture(_texture:MyLayeredTexture):
	layeredTextures.erase(_texture)

class AnimTreeEntry:
	var animTree:AnimationMixer
	var skeleton:Skeleton3D
	var skippedDelta:float = 0.0
	#var virtualFinishTime:float = 0.0 # lower = more overdue
	var needProcessing:float = 0.0
	var distance:float = 0.0
	var priority:float = 1.0

var animTrees:Array[AnimTreeEntry] = []

# Skeleton only matters if it has skeletonModifiers attached to it.
# Higher priority = updates more often against others
func addAnimTree(_tree:AnimationMixer, _skeleton:Skeleton3D = null, _priority:float = 1.0):
	if(Engine.is_editor_hint()):
		return
	if((!_tree || !_tree.is_inside_tree()) && (!_skeleton || !_skeleton.is_inside_tree())):
		Log.Printerr("Bad addAnimTree() call. Tree:"+str(_tree)+" skeleton:"+str(_skeleton))
		return
	var newEntry:AnimTreeEntry = AnimTreeEntry.new()
	newEntry.animTree = _tree
	newEntry.skeleton = _skeleton
	newEntry.priority = _priority
	animTrees.append(newEntry)
	if(_tree):
		_tree.tree_exiting.connect(internal_removeAnimTree.bind(newEntry))
		_tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	if(_skeleton):
		if(!_tree):
			_skeleton.tree_exiting.connect(internal_removeAnimTree.bind(newEntry))
		_skeleton.modifier_callback_mode_process = Skeleton3D.MODIFIER_CALLBACK_MODE_PROCESS_MANUAL
	#var animPlayer:AnimationPlayer = _tree.get_node(_tree.anim_player)
	#if(animPlayer):
		#animPlayer.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		#
func internal_removeAnimTree(_entry:AnimTreeEntry):
	animTrees.erase(_entry)
	#treeToDist.erase(_entry)

#const AMOUNT_FULL:int = 10
#const AMOUNT_SKIP_1_FRAME:int = 6
#const AMOUNT_SKIP_2_FRAMES:int = 6

const HAIR_PRIORITY:float = 0.6
const EAR_PRIORITY:float = 0.4
const TAIL_PRIORITY:float = 0.8
const PENIS_PRIORITY:float = 0.5
const FACE_PRIORITY:float = 0.6

const UPDATES_BUDGET: int = 20
#const DIST_SCALE_SQ: float = 100.0
const MIN_WEIGHT: float = 0.001

#var treeToDist:Dictionary[AnimTreeEntry, float]
#var processFrameCounter: int = 0
func _process(_delta: float) -> void:
	#processFrameCounter += 1
	var theCamera:Camera3D = get_viewport().get_camera_3d()
	if(!theCamera):
		fallbackProcessAllAnimTrees(_delta)
		return
	var theCameraPos:Vector3 = theCamera.global_position
	for theTree:AnimTreeEntry in animTrees:
		var thePos:Vector3 = theTree.skeleton.global_position if (theTree.skeleton) else internal_findPos(theTree.animTree)
		#treeToDist[theTree] = theCameraPos.distance_squared_to(thePos)
		theTree.distance = theCameraPos.distance_squared_to(thePos)
		theTree.skippedDelta += _delta
		theTree.needProcessing += _delta / maxf(theTree.distance, MIN_WEIGHT) * theTree.priority
	
	#animTrees.sort_custom(internal_sortAnimTreesAscending)
	#animTrees.sort_custom(internal_sortAnimTreesVirtFinishAscending)
	animTrees.sort_custom(internal_sortAnimTreesNeedProcessingFinishAscending)
	
	var theBudget:int = int(float(UPDATES_BUDGET) * OPTIONS.graphics.getAnimationBudgetMult())
	theBudget = maxi(theBudget, 1)
	var theUpdateCount: int = mini(theBudget, animTrees.size())
	for _i:int in theUpdateCount:
		var theEntry:AnimTreeEntry = animTrees[_i]
		#var theWeight: float = maxf(DIST_SCALE_SQ / (DIST_SCALE_SQ + theEntry.distance), MIN_WEIGHT)
		
		if(theEntry.animTree):
			theEntry.animTree.advance(theEntry.skippedDelta)
		if(theEntry.skeleton):
			theEntry.skeleton.advance(theEntry.skippedDelta)
		theEntry.skippedDelta = 0.0
		#theEntry.virtualFinishTime += 1.0 / theWeight
		theEntry.needProcessing = 0.0
		
	#var theTotal: int = animTrees.size()
	#var theTier1End: int = mini(AMOUNT_FULL + AMOUNT_SKIP_1_FRAME, theTotal)
	#var theTier2End: int = mini(theTier1End + AMOUNT_SKIP_2_FRAMES, theTotal)
	#
	#var _amProccessed:int = 0
	#var _amSkipped:int = 0
	#for _i:int in theTotal:
	#	var theTreeEntry: AnimTreeEntry = animTrees[_i]
	#	var theTree: AnimationMixer = theTreeEntry.animTree
	#	var interval: int
	#	if _i < AMOUNT_FULL:
	#		interval = 1
	#	elif _i < theTier1End:
	#		interval = 2
	#	elif _i < theTier2End:
	#		interval = 3
	#	else:
	#		interval = 4
#
	#	if processFrameCounter % interval == 0:
	#		var toProcess:float = theTreeEntry.skippedDelta + _delta
	#		if(theTree):
	#			theTree.advance(toProcess)
	#		if(theTreeEntry.skeleton):
	#			theTreeEntry.skeleton.advance(toProcess)
	#		theTreeEntry.skippedDelta = 0.0
	#		_amProccessed += 1
	#	else:
	#		_amSkipped += 1
	#		theTreeEntry.skippedDelta += _delta
	
	#print(_amProccessed, "\t", _amSkipped)

#func internal_sortAnimTreesAscending(a:AnimTreeEntry, b:AnimTreeEntry):
#	if treeToDist[a] < treeToDist[b]:
#		return true
#	return false

#func internal_sortAnimTreesVirtFinishAscending(a:AnimTreeEntry, b:AnimTreeEntry):
#	if a.virtualFinishTime < b.virtualFinishTime:
#		return true
#	return false

func internal_sortAnimTreesNeedProcessingFinishAscending(a:AnimTreeEntry, b:AnimTreeEntry):
	if a.needProcessing > b.needProcessing:
		return true
	return false

func fallbackProcessAllAnimTrees(_delta:float):
	for theTreeEntry:AnimTreeEntry in animTrees:
		theTreeEntry.animTree.advance(_delta)

func internal_findPos(_node:Node) -> Vector3:
	while(_node && !(_node is Node3D)):
		_node = _node.get_parent()
	if(_node && (_node is Node3D)):
		return _node.global_position
	return Vector3.ZERO

func addWiggleModifier(_mod):
	wiggleModifiers.append(_mod)

func removeWiggleModifier(_mod):
	wiggleModifiers.erase(_mod)

func addDollToUpdate(_doll:Doll):
	if(!_doll || dollsToUpdate.has(_doll)):
		return
	dollsToUpdate.append(_doll)
	_doll.tree_exiting.connect(removeDollToUpdate.bind(_doll))
	
func removeDollToUpdate(_doll:Doll):
	dollsToUpdate.erase(_doll)
	_doll.tree_exiting.disconnect(removeDollToUpdate.bind(_doll))

func updateDolls(_delta: float):
	var theDoll:Doll = dollsToUpdate.front()
	var newUpdateTimer := theDoll.doDollUpdate()
	if(newUpdateTimer < 0.0):
		theDoll.tree_exiting.disconnect(removeDollToUpdate.bind(theDoll))
		dollsToUpdate.pop_front()
	else:
		updateTimer = newUpdateTimer

func processThings(_delta: float) -> void:
	if(updateTimer > 0.0):
		updateTimer -= _delta
	else:
		if(!thingsToUpdate.is_empty()):
			updateThings(_delta)
			return
		if(!dollsToUpdate.is_empty()):
			updateDolls(_delta)
			return
		updateLayeredTexturesAlways(_delta)

func addThingToUpdate(_thing:Node):
	if(!_thing || thingsToUpdate.has(_thing)):
		return
	thingsToUpdate.append(_thing)
	_thing.tree_exiting.connect(removeThingToUpdate.bind(_thing))
	
func removeThingToUpdate(_thing:Node):
	thingsToUpdate.erase(_thing)
	_thing.tree_exiting.disconnect(removeThingToUpdate.bind(_thing))

func updateThings(_delta: float):
	var theThing:Node = thingsToUpdate.front()
	var newUpdateTimer:float = theThing.doThingUpdate()
	if(newUpdateTimer < 0.0):
		theThing.tree_exiting.disconnect(removeThingToUpdate.bind(theThing))
		thingsToUpdate.pop_front()
	else:
		updateTimer = newUpdateTimer

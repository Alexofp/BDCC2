extends Node

## This node attempts to reduce the overall amount of _process calls that get called every frame.

var ticks:int = 0

const MAX_LAYERED_TEXTURE_UPDATES_PER_FRAME = 1
var layeredTextures:Array[MyLayeredTexture] = []
var curLayeredTextures:int = 0

var animTrees:Array[AnimationTree] = []

var dollsToUpdate:Array[Doll] = []
var thingsToUpdate:Array[Node] = []

var wiggleModifiers:Array[DMWBWiggleRotationModifier3D] = []

var updateTimer:float = 0.0

func _process(_delta: float) -> void:
	processThings(_delta)
	
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
		curLayeredTextures += 1
		didUpdate += 1
		toUpdate -= 1
		
		var theParent:Node = theTexture.get_parent()
		if(!theParent || !(theParent is Node3D)):
			continue
		#var camera:Camera3D = get_viewport().get_camera_3d()
		if(!camera):
			continue
		var distSqr:float = camera.global_position.distance_squared_to(theParent.global_position)
		
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

func addAnimTree(_tree:AnimationTree):
	animTrees.append(_tree)
	#_tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	#var animPlayer:AnimationPlayer = _tree.get_node(_tree.anim_player)
	#if(animPlayer):
		#animPlayer.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		#
func removeAnimTree(_tree:AnimationTree):
	animTrees.erase(_tree)

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

extends Node

## This node attempts to reduce the overall amount of _process calls that get called every frame.

var ticks:int = 0

const MAX_LAYERED_TEXTURE_UPDATES_PER_FRAME = 1
var layeredTextures:Array[MyLayeredTexture] = []
var curLayeredTextures:int = 0

var animTrees:Array[AnimationTree] = []

var wiggleModifiers:Array[DMWBWiggleRotationModifier3D] = []

func _process(_delta: float) -> void:
	ticks += 1
	var camera:Camera3D = get_viewport().get_camera_3d()
	
	if(!camera):
		return
	
	for wiggleMod in wiggleModifiers:
		var theDist:float = wiggleMod.global_position.distance_squared_to(camera.global_position)
		wiggleMod.manualTurnOff = (theDist > 30.0)
	
	for animTree in animTrees:
		var animNode = animTree.get_parent()
		while(animNode && !(animNode is Node3D)):
			animNode = animNode.get_parent()
		if(!animNode || !camera):
			continue
		var howOft:int = 1
		var theDist:float = animNode.global_position.distance_squared_to(camera.global_position)
		if(theDist > 30.0):
			howOft = 2
		if(theDist > 50.0):
			howOft = 3
		if(theDist > 100.0):
			howOft = 5
		if(theDist > 300.0):
			howOft = 10
		
		#if(true):
			#animTree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
			#var animPlayer:AnimationPlayer = animTree.get_node(animTree.anim_player)
			#if(animPlayer):
				#animPlayer.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
		if(howOft <= 1 || ((hash(animTree)+ticks) % howOft)==0):
			animTree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
			animTree.advance(_delta*howOft)
			#var animPlayer:AnimationPlayer = animTree.get_node(animTree.anim_player)
			#if(animPlayer):
			#	animPlayer.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
			#	animPlayer.advance(_delta)
				
	# LAYERED TEXTURES UPDATE
	if(!layeredTextures.is_empty()):
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

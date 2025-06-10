extends Node
class_name MyLayeredTexture

@export var resolution:Vector2i = Vector2i(512, 512)
@export var clearColor:Color = Color.TRANSPARENT

enum GraphicsOptionAutoScale {
	Disabled,
	Character,
}
@export var graphicsOptionAutoScale:GraphicsOptionAutoScale = GraphicsOptionAutoScale.Disabled
@export var bakeTexture:bool = true
@export var autoUnload:bool = true

@onready var sub_viewport: SubViewport = %SubViewport
@onready var color_rect: ColorRect = %ColorRect
@onready var cache_timer: Timer = %CacheTimer

var resDivider:int = 1
var dirty:bool = false
var inProcess:bool = false

var layers:Array = []
const LAYER_SIMPLE = 0
const LAYER_COLORMASK = 1
const LAYER_BLENDADD = 2
const LAYER_SMOOTHREVEAL = 3

var colorMaskTextureRect = preload("res://Mesh/Materials/MyLayeredTexture/color_mask_texture_rect.tscn")
var addModeTextureRect = preload("res://Mesh/Materials/MyLayeredTexture/add_mode_texture_rect.tscn")
var smoothRevealRect = preload("res://Mesh/Materials/MyLayeredTexture/SmoothRevealTextureRect.tscn")

var cachedTexture:Texture2D
signal onTextureUpdated(newTexture)

func _ready():
	if(graphicsOptionAutoScale == GraphicsOptionAutoScale.Character):
		OPTIONS.changedCharTextureQuality.connect(characterTextureOptionChanged)
		characterTextureOptionChanged()
	set_process(autoUnload)

var farTimer:float = 0.0
var textureSpawned:bool = true
func _process(_delta: float) -> void:
	var theParent:Node = get_parent()
	if(!theParent || !(theParent is Node3D)):
		return
	var camera:Camera3D = get_viewport().get_camera_3d()
	if(!camera):
		return
	var distSqr:float = camera.global_position.distance_squared_to(theParent.global_position)
	
	if(distSqr < 1000.0):
		farTimer = 5.0
	else:
		farTimer -= _delta
	
	if(textureSpawned && farTimer <= 0.0):
		textureSpawned = false
		markDirty()
	elif(!textureSpawned && farTimer > 0.0):
		textureSpawned = true
		markDirty()

func markDirty():
	if(dirty):
		return
	dirty = true
	if(!inProcess):
		updateTexture.call_deferred()

func loadThreaded(_path:String):
	return load(_path)

func updateTexture(): # TODO make this process threaded somehow? The texture loading takes up time
	if(!dirty):
		return
	inProcess = true
	dirty = false
	
	#if(bakeTexture):
	#	cache_timer.stop()
	#	if(!cachedTexture):
	#		_on_cache_timer_timeout()
	
	sub_viewport.size = (resolution / resDivider) if textureSpawned else Vector2i(32, 32)
	color_rect.color = clearColor
	
	Util.delete_children(color_rect)
	for layerEntry in layers:
		var layerType:int = layerEntry[0]
		var theTexture = layerEntry[1]
		if(theTexture is String):
			var theFuture := ThreadedResourceLoader.getThreadPool().submit_task(self, "loadThreaded", theTexture)
			await theFuture.task_completed
			theTexture = theFuture.get_result()
			#theTexture = load(theTexture)
		
		if(layerType == LAYER_SIMPLE):
			var newRect:TextureRect = TextureRect.new()
			color_rect.add_child(newRect)
			newRect.anchor_top = 0.0
			newRect.anchor_left = 0.0
			newRect.anchor_right = 1.0
			newRect.anchor_bottom = 1.0
			newRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			newRect.texture = theTexture
			newRect.self_modulate = layerEntry[2]
		
		elif(layerType == LAYER_COLORMASK):
			var newRect: = colorMaskTextureRect.instantiate()
			color_rect.add_child(newRect)
			#newRect.anchor_top = 0.0
			#newRect.anchor_left = 0.0
			#newRect.anchor_right = 1.0
			#newRect.anchor_bottom = 1.0
			#newRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			newRect.setTexture(theTexture)
			newRect.setColors(layerEntry[2], layerEntry[3], layerEntry[4])
			
		elif(layerType == LAYER_BLENDADD):
			var newRect: = addModeTextureRect.instantiate()
			color_rect.add_child(newRect)
			newRect.anchor_top = 0.0
			newRect.anchor_left = 0.0
			newRect.anchor_right = 1.0
			newRect.anchor_bottom = 1.0
			newRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			newRect.texture = theTexture
			newRect.self_modulate = layerEntry[2]
			
		elif(layerType == LAYER_SMOOTHREVEAL):
			var newRect: = smoothRevealRect.instantiate()
			color_rect.add_child(newRect)
			newRect.anchor_top = 0.0
			newRect.anchor_left = 0.0
			newRect.anchor_right = 1.0
			newRect.anchor_bottom = 1.0
			#newRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			var theTexture2 = layerEntry[2]
			if(theTexture2 is String):
				var theFuture := ThreadedResourceLoader.getThreadPool().submit_task(self, "loadThreaded", theTexture2)
				await theFuture.task_completed
				theTexture2 = theFuture.get_result()
				#theTexture2 = load(theTexture2)
			newRect.setRevealTexture(theTexture)
			newRect.setAlphaMaskTexture(theTexture2)
			newRect.setRevealAndSmooth(layerEntry[3], layerEntry[4])
			newRect.setScroll(layerEntry[5])
			
			
		await get_tree().create_timer(0.2/layers.size()).timeout
		
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	#dirty = false
	
	await RenderingServer.frame_post_draw
	
	cachedTexture = null
	
	onTextureUpdated.emit(sub_viewport.get_texture())
	#if(!bakeTexture):
		#onTextureUpdated.emit(sub_viewport.get_texture())
	#else:
		#cachedTexture = ImageTexture.create_from_image(sub_viewport.get_texture().get_image())
		#onTextureUpdated.emit(cachedTexture)
		#onTextureUpdated.emit(sub_viewport.get_texture())
	if(bakeTexture):
		cache_timer.start()
	
	if(!dirty):
		Util.delete_children(color_rect)
	
	inProcess = false
	if(dirty):
		updateTexture.call_deferred()

func getTexture() -> ViewportTexture:
	#if(dirty && !inProcess):
	#	updateTexture()
	if(bakeTexture && cachedTexture):
		return cachedTexture
	else:
		return sub_viewport.get_texture()

func clearLayers():
	layers = []
	markDirty()

func addSimpleLayer(theTexture, theColor:Color = Color.WHITE):
	layers.append([LAYER_SIMPLE, theTexture, theColor])
	markDirty()

func addColorMaskLayer(theTexture, colorR:Color = Color.BLACK, colorG:Color = Color.BLACK, colorB:Color = Color.BLACK):
	layers.append([LAYER_COLORMASK, theTexture, colorR, colorG, colorB])
	markDirty()

func addBlendAddLayer(theTexture, theColor:Color = Color.WHITE):
	layers.append([LAYER_BLENDADD, theTexture, theColor])
	markDirty()

func addSmoothRevealLayer(theRevealTexture, theAlphaMask, revealAmount:float, smoothAmount:float, scroll:float = 0.0):
	layers.append([LAYER_SMOOTHREVEAL, theRevealTexture, theAlphaMask, clamp(1.0-revealAmount, 0.0, 1.0), smoothAmount, scroll])
	markDirty()

func characterTextureOptionChanged():
	if(OPTIONS.graphics.texturesChar == GraphicsSettings.TEXTURESCHARACTERS.MEDIUM):
		resDivider = 2
	elif(OPTIONS.graphics.texturesChar == GraphicsSettings.TEXTURESCHARACTERS.LOW):
		resDivider = 4
	else:
		resDivider = 1
	markDirty()

var cacheIndx:int = 0
func _on_cache_timer_timeout() -> void:
	#TODO: Make a threadpool that would create compressed textures? They use way less VRAM
	#cachedTexture = PortableCompressedTexture2D.new()
	#cachedTexture.create_from_image(sub_viewport.get_texture().get_image(), PortableCompressedTexture2D.COMPRESSION_MODE_BASIS_UNIVERSAL)
	cacheIndx += 1
	var savedIndx:int = cacheIndx
	var theFuture := ThreadedResourceLoader.getThreadPool2().submit_task(self, "doCachedTextureThreaded", sub_viewport.get_texture().get_image(), cacheIndx)
	await theFuture.task_completed
	if(savedIndx != cacheIndx):
		return
	
	if(!cachedTexture && theFuture.result):
		cachedTexture = theFuture.result
		onTextureUpdated.emit(cachedTexture)
	
	#cachedTexture = ImageTexture.create_from_image(sub_viewport.get_texture().get_image())
	#onTextureUpdated.emit(cachedTexture)
	sub_viewport.size = Vector2i(32, 32)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func doCachedTextureThreaded(_image:Image):
	var newCachedTexture = PortableCompressedTexture2D.new()
	newCachedTexture.create_from_image(_image, PortableCompressedTexture2D.COMPRESSION_MODE_BASIS_UNIVERSAL)
	#newCachedTexture.create_from_image(_image, PortableCompressedTexture2D.COMPRESSION_MODE_LOSSLESS)
	return newCachedTexture

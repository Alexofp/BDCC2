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
const LAYER_SIMPLE_PART = 4

var textureVersion:int = 0 # For baking

var colorMaskTextureRect = preload("res://Mesh/Materials/MyLayeredTexture/color_mask_texture_rect.tscn")
var addModeTextureRect = preload("res://Mesh/Materials/MyLayeredTexture/add_mode_texture_rect.tscn")
var smoothRevealRect = preload("res://Mesh/Materials/MyLayeredTexture/SmoothRevealTextureRect.tscn")

var cachedTexture:Texture2D
signal onTextureUpdated(newTexture)

func _enter_tree() -> void:
	ProcessBalancer.addLayeredTexture(self)

func _exit_tree() -> void:
	ProcessBalancer.removeLayeredTexture(self)

func _ready():
	if(graphicsOptionAutoScale == GraphicsOptionAutoScale.Character):
		OPTIONS.changedCharTextureQuality.connect(characterTextureOptionChanged)
		characterTextureOptionChanged()
	set_process(autoUnload)

var farTimer:float = 0.0
var textureSpawned:bool = true

func markDirty():
	if(dirty):
		return
	dirty = true
	if(!inProcess):
		updateTexture.call_deferred()

func updateTexture():
	if(!dirty):
		return
	inProcess = true
	dirty = false
	
	#if(bakeTexture):
	#	cache_timer.stop()
	#	if(!cachedTexture):
	#		_on_cache_timer_timeout()
	@warning_ignore("integer_division")
	sub_viewport.size = (resolution / resDivider) if textureSpawned else Vector2i(32, 32)
	color_rect.color = clearColor
	
	Util.delete_children(color_rect)
	for layerEntry in layers:
		var layerType:int = layerEntry[0]
		var theTexture = layerEntry[1]
		if(theTexture is String):
			theTexture = await ThreadedResourceLoader.asyncLoadRequest(theTexture, 1)
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
		
		elif(layerType == LAYER_SIMPLE_PART):
			var newRect:TextureRect = TextureRect.new()
			color_rect.add_child(newRect)
			newRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			newRect.anchor_left = layerEntry[3].x
			newRect.anchor_top = layerEntry[3].y
			newRect.anchor_right = layerEntry[3].x + layerEntry[4].x
			newRect.anchor_bottom = layerEntry[3].y + layerEntry[4].y
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
				#theTexture2 = load(theTexture2)
				theTexture2 = await ThreadedResourceLoader.asyncLoadRequest(theTexture2, 1)
			newRect.setRevealTexture(theTexture)
			newRect.setAlphaMaskTexture(theTexture2)
			newRect.setRevealAndSmooth(layerEntry[3], layerEntry[4])
			newRect.setScroll(layerEntry[5])
			
			
		#await get_tree().create_timer(0.2/layers.size()).timeout
		
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	await RenderingServer.frame_post_draw
	
	cachedTexture = null
	
	textureVersion += 1
	onTextureUpdated.emit(sub_viewport.get_texture())

	if(bakeTexture && OPTIONS.graphics.texturesCompression == GraphicsSettings.TEXTURESCOMPRESSION.ENABLED):
		cache_timer.start()
	
	if(!dirty):
		Util.delete_children(color_rect)
	
	inProcess = false
	if(dirty):
		updateTexture.call_deferred()

func getTexture() -> Texture2D:
	if(bakeTexture && cachedTexture):
		return cachedTexture
	else:
		return sub_viewport.get_texture()

func clearLayers():
	layers = []
	markDirty()

func addSimpleLayer(theTexture, theColor:Color = Color.WHITE):
	if(theColor.a <= 0.0):
		return
	layers.append([LAYER_SIMPLE, theTexture, theColor])
	markDirty()

func addSimpleLayerAt(theTexture, theColor:Color = Color.WHITE, thePos:Vector2 = Vector2(1.0, 1.0), theSize:Vector2 = Vector2(1.0, 1.0)):
	layers.append([LAYER_SIMPLE_PART, theTexture, theColor, thePos, theSize])
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

func _on_cache_timer_timeout() -> void:
	#if(true):
	#	return
	var savedIndx:int = textureVersion
	var theFuture := ThreadedResourceLoader.getThreadPool2().submit_task(self, "doCachedTextureThreaded", sub_viewport.get_texture().get_image())
	await theFuture.task_completed
	if(savedIndx != textureVersion):
		return
	
	if(!cachedTexture && theFuture.result):
		cachedTexture = theFuture.result
		onTextureUpdated.emit(cachedTexture)
	
	if(!inProcess):
		await get_tree().process_frame
		if(!inProcess):
			sub_viewport.size = Vector2i(32, 32)
			sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func doCachedTextureThreaded(_image:Image):
	#var newCachedTexture = PortableCompressedTexture2D.new()
	#newCachedTexture.create_from_image(_image, PortableCompressedTexture2D.COMPRESSION_MODE_BPTC)
	##newCachedTexture.create_from_image(_image, PortableCompressedTexture2D.COMPRESSION_MODE_LOSSLESS)
	#return newCachedTexture
	_image.compress(Image.COMPRESS_BPTC)
	return ImageTexture.create_from_image(_image)

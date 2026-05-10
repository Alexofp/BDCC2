extends Node
class_name MyLayeredTextureNew

@export var resolution:Vector2i = Vector2i(512, 512)
@export var clearColor:Color = Color.TRANSPARENT

enum GraphicsOptionAutoScale {
	Disabled,
	Character,
}
@export var graphicsOptionAutoScale:GraphicsOptionAutoScale = GraphicsOptionAutoScale.Disabled

var resDivider:int = 1
var dirty:bool = false
var inProcess:bool = false
var resolutionFinal:Vector2i

var layers:Array = []
const LAYER_SIMPLE = 0
const LAYER_COLORMASK = 1
const LAYER_BLENDADD = 2
const LAYER_SMOOTHREVEAL = 3
const LAYER_SIMPLE_PART = 4

var cachedTexture:DrawableTexture2D
signal onTextureUpdated(newTexture:DrawableTexture2D)

const DRAW_TEXTURE_COLORMASK_MAT:ShaderMaterial = preload("res://Mesh/Materials/MyLayeredTexture/Mats/DrawTextureColormaskMat.tres")
const DRAW_TEXTURE_ADD_MAT:ShaderMaterial = preload("res://Mesh/Materials/MyLayeredTexture/Mats/DrawTextureAddMat.tres")
const DRAW_TEXTURE_SMOOTH_REVEAL_MAT:ShaderMaterial = preload("res://Mesh/Materials/MyLayeredTexture/Mats/DrawTextureSmoothRevealMat.tres")

#func _enter_tree() -> void:
#	ProcessBalancer.addLayeredTexture(self)

#func _exit_tree() -> void:
#	ProcessBalancer.removeLayeredTexture(self)

func _ready():
	cachedTexture = DrawableTexture2D.new()
	
	if(graphicsOptionAutoScale == GraphicsOptionAutoScale.Character):
		OPTIONS.changedCharTextureQuality.connect(characterTextureOptionChanged)
		characterTextureOptionChanged()
	else:
		setupTexture()
		
	#set_process(autoUnload)

func setupTexture():
	@warning_ignore("integer_division")
	resolutionFinal = resolution/resDivider
	#cachedTexture.setup(resolutionFinal.x, resolutionFinal.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBAH, clearColor)
	cachedTexture.setup(resolutionFinal.x, resolutionFinal.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBAH, clearColor)

# Submit to the queue that would eventually process us
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
	
	# Some way to clear it?
	setupTexture()
	
	for layerEntry in layers:
		var layerType:int = layerEntry[0]
		var theTexture = layerEntry[1]
		if(theTexture is String):
			theTexture = await ThreadedResourceLoader.asyncLoadRequest(theTexture, 1)
			#theTexture = load(theTexture)
		
		if(layerType == LAYER_SIMPLE):
			cachedTexture.blit_rect(Rect2i(Vector2i.ZERO, resolution), theTexture, layerEntry[2], 0, null)
		elif(layerType == LAYER_SIMPLE_PART):
			var thePos:Vector2 = layerEntry[3]
			var theSize:Vector2 = layerEntry[4]
			var thePosI:Vector2i = Vector2i(Vector2(resolutionFinal) * thePos)
			var theSizeI:Vector2i = Vector2i(Vector2(resolutionFinal) * theSize)
			cachedTexture.blit_rect(Rect2i(thePosI, theSizeI), theTexture, layerEntry[2], 0, null)
		elif(layerType == LAYER_COLORMASK):
			cachedTexture.blit_rect(Rect2i(Vector2i.ZERO, resolution), theTexture, Color.WHITE, 0, layerEntry[5])
		elif(layerType == LAYER_BLENDADD):
			cachedTexture.blit_rect(Rect2i(Vector2i.ZERO, resolution), theTexture, layerEntry[2], 0, DRAW_TEXTURE_ADD_MAT)
		elif(layerType == LAYER_SMOOTHREVEAL):
			cachedTexture.blit_rect(Rect2i(Vector2i.ZERO, resolution), theTexture, Color.WHITE, 0, layerEntry[6])

	await RenderingServer.frame_post_draw
	#textureVersion += 1
	#onTextureUpdated.emit(sub_viewport.get_texture())
	onTextureUpdated.emit(cachedTexture)

	#if(bakeTexture && OPTIONS.graphics.texturesCompression == GraphicsSettings.TEXTURESCOMPRESSION.ENABLED):
	#	cache_timer.start()
	
	inProcess = false
	if(dirty):
		updateTexture.call_deferred()

func getTexture() -> Texture2D:
	return cachedTexture

func clearLayers():
	layers.clear()
	markDirty()

func addSimpleLayer(theTexture, theColor:Color = Color.WHITE):
	if(theColor.a <= 0.0):
		return
	layers.append([LAYER_SIMPLE, theTexture, theColor])
	markDirty()

func addSimpleLayerAt(theTexture, theColor:Color = Color.WHITE, thePos:Vector2 = Vector2(0.0, 0.0), theSize:Vector2 = Vector2(1.0, 1.0)):
	layers.append([LAYER_SIMPLE_PART, theTexture, theColor, thePos, theSize])
	markDirty()

func addColorMaskLayer(theTexture, colorR:Color = Color.BLACK, colorG:Color = Color.BLACK, colorB:Color = Color.BLACK):
	var theMat := DRAW_TEXTURE_COLORMASK_MAT.duplicate()
	theMat.set_shader_parameter("colorR", colorR)
	theMat.set_shader_parameter("colorG", colorG)
	theMat.set_shader_parameter("colorB", colorB)
	layers.append([LAYER_COLORMASK, theTexture, colorR, colorG, colorB, theMat])
	markDirty()

func addBlendAddLayer(theTexture, theColor:Color = Color.WHITE):
	layers.append([LAYER_BLENDADD, theTexture, theColor])
	markDirty()

func addSmoothRevealLayer(theRevealTexture, theAlphaMask, revealAmount:float, smoothAmount:float, scroll:float = 0.0):
	var theCutoff:float = clampf(1.0-revealAmount, 0.0, 1.0)
	var theMat := DRAW_TEXTURE_SMOOTH_REVEAL_MAT.duplicate()
	theMat.set_shader_parameter("alpha_mask", theAlphaMask if !(theAlphaMask is String) else load(theAlphaMask))
	theMat.set_shader_parameter("cutoff", theCutoff)
	theMat.set_shader_parameter("smooth_size", smoothAmount)
	theMat.set_shader_parameter("alpha_mask_scroll", scroll)
	layers.append([LAYER_SMOOTHREVEAL, theRevealTexture, theAlphaMask, theCutoff, smoothAmount, scroll, theMat])
	markDirty()

func characterTextureOptionChanged():
	if(OPTIONS.graphics.texturesChar == GraphicsSettings.TEXTURESCHARACTERS.MEDIUM):
		resDivider = 2
	elif(OPTIONS.graphics.texturesChar == GraphicsSettings.TEXTURESCHARACTERS.LOW):
		resDivider = 4
	else:
		resDivider = 1
	setupTexture()
	markDirty()

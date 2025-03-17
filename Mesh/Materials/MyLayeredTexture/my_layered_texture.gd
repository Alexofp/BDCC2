extends Node
class_name MyLayeredTexture

@export var resolution:Vector2i = Vector2i(512, 512)
@export var clearColor:Color = Color.TRANSPARENT

enum GraphicsOptionAutoScale {
	Disabled,
	Character,
}
@export var graphicsOptionAutoScale:GraphicsOptionAutoScale = GraphicsOptionAutoScale.Disabled

@onready var sub_viewport: SubViewport = %SubViewport
@onready var color_rect: ColorRect = %ColorRect

var resDivider:int = 1
var dirty:bool = true

var layers:Array = []
const LAYER_SIMPLE = 0
const LAYER_COLORMASK = 1
const LAYER_BLENDADD = 2

var colorMaskTextureRect = preload("res://Mesh/Materials/MyLayeredTexture/color_mask_texture_rect.tscn")
var addModeTextureRect = preload("res://Mesh/Materials/MyLayeredTexture/add_mode_texture_rect.tscn")

func _ready():
	if(graphicsOptionAutoScale == GraphicsOptionAutoScale.Character):
		OPTIONS.changedCharTextureQuality.connect(characterTextureOptionChanged)
		characterTextureOptionChanged()

func markDirty():
	if(dirty):
		return
	dirty = true
	updateTexture.call_deferred()

func updateTexture():
	if(!dirty):
		return
	sub_viewport.size = resolution / resDivider
	color_rect.color = clearColor
	
	Util.delete_children(color_rect)
	for layerEntry in layers:
		var layerType:int = layerEntry[0]
		var theTexture = layerEntry[1]
		if(theTexture is String):
			theTexture = load(theTexture)
		
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
	
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	dirty = false
	
	await RenderingServer.frame_post_draw
	if(!dirty):
		Util.delete_children(color_rect)

func getTexture() -> ViewportTexture:
	if(dirty):
		updateTexture()
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

func characterTextureOptionChanged():
	if(OPTIONS.graphics.texturesChar == GraphicsSettings.TEXTURESCHARACTERS.MEDIUM):
		resDivider = 2
	elif(OPTIONS.graphics.texturesChar == GraphicsSettings.TEXTURESCHARACTERS.LOW):
		resDivider = 4
	else:
		resDivider = 1
	markDirty()

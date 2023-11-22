extends Node

@onready var subViewport = $SubViewport
@onready var control = $SubViewport/Control
@onready var colorRect = $SubViewport/Control/ColorRect

@export var textureSize:Vector2i = Vector2i(1024, 1024)
@export var defaultColor:Color = Color.TRANSPARENT

var alphaTextureRectScene = preload("res://Mesh/Materials/alpha_texture_rect.tscn")
var simpleTextureRectScene = preload("res://Mesh/Materials/simple_texture_rect.tscn")

var layers = []

func _ready():
	subViewport.size = textureSize
	colorRect.color = defaultColor

#func _process(_delta):
#	pass

func getTexture():
	return subViewport.get_texture()

func queueUpdate():
	subViewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func clear():
	for layer in layers:
		layer.queue_free()
	layers = []
	queueUpdate()

func addLayer(newNode):
	if(layers.has(newNode)):
		return
	layers.append(newNode)
	control.add_child(newNode)
	queueUpdate()

func addSimpleLayer(theTexture:Texture2D, theColor:Color = Color.WHITE):
	var newTextureRect:TextureRect = simpleTextureRectScene.instantiate()
	newTextureRect.texture = theTexture
	newTextureRect.self_modulate = theColor
	newTextureRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	addLayer(newTextureRect)

func addSimpleAlphaLayer(theTexture:Texture2D):
	var newTextureRect:TextureRect = alphaTextureRectScene.instantiate()
	newTextureRect.texture = theTexture
	newTextureRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	addLayer(newTextureRect)

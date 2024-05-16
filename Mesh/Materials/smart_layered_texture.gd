extends Node

@onready var subViewport = $SubViewport
@onready var control = $SubViewport/Control
@onready var colorRect = $SubViewport/Control/ColorRect

@export var textureSize:Vector2i = Vector2i(1024, 1024)
@export var defaultColor:Color = Color.TRANSPARENT

var alphaTextureRectScene = preload("res://Mesh/Materials/alpha_texture_rect.tscn")
var simpleTextureRectScene = preload("res://Mesh/Materials/simple_texture_rect.tscn")
var patternTextureRectScene = preload("res://Mesh/Materials/pattern_texture_rect.tscn")
var textureWithAlphaRectScene = preload("res://Mesh/Materials/texture_with_alpha_rect.tscn")

var layers = []

func _ready():
	subViewport.size = textureSize
	colorRect.color = defaultColor
	queueUpdate()

#func _process(_delta):
#	pass

func getTexture():
	return subViewport.get_texture()

func queueUpdate():
	subViewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func queueUpdateDelayed():
	subViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await get_tree().process_frame
	await get_tree().process_frame
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

func addPatternLayer(theTexture:Texture2D, rColor:Color, gColor:Color, bColor:Color):
	var newPatternRect = patternTextureRectScene.instantiate()
	newPatternRect.setColors(rColor, gColor, bColor)
	newPatternRect.setTexture(theTexture)
	addLayer(newPatternRect)

func addTextureWithAlphaLayer(theTexture:Texture2D, alphaTexture:Texture2D):
	var newRect = textureWithAlphaRectScene.instantiate()
	newRect.setTextures(theTexture, alphaTexture)
	addLayer(newRect)

func addLayers(theLayers:Array):
	for layerInfo in theLayers:
		var theTexture = load(layerInfo["id"])
		#var theTexture = GlobalRegistry.getTextureVariant(TextureType.PartSkin, TextureSubType.Generic, layerInfo["id"]).getTexture()
		
		if(layerInfo.has("isPattern") && layerInfo["isPattern"]):
			addPatternLayer(theTexture, layerInfo["color"], layerInfo["color2"], layerInfo["color3"])
		else:
			addSimpleLayer(theTexture, layerInfo["color"])

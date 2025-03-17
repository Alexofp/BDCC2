extends Control

func _ready():
	#$MyLayeredTexture.addColorMaskLayer(preload("res://Mesh/Parts/SharedTextures/BodyLayers/Belly.png"), Color.RED, Color.GREEN, Color.GREEN)
	$MyLayeredTexture.addColorMaskLayer(preload("res://Mesh/Parts/SharedTextures/BodyLayers/TestLayer.png"), Color.RED, Color.GREEN, Color.GREEN)
	
	$TextureRect.texture = $MyLayeredTexture.getTexture()

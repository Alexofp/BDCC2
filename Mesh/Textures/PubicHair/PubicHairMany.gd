extends TextureVariantMany

func _init():
	super._init()
	
	textureType = TextureType.PubicHair
	textureSubType = TextureSubType.Generic
	textures = [
		{id="shaved", name="Shaved", path="res://Mesh/Textures/PubicHair/shaved.png"},
		{id="cute", name="Cute", path="res://Mesh/Textures/PubicHair/cute.png"},
		{id="heart", name="Heart", path="res://Mesh/Textures/PubicHair/heart.png"},
		{id="line", name="Line", path="res://Mesh/Textures/PubicHair/line.png"},
		{id="longline", name="Long line", path="res://Mesh/Textures/PubicHair/longline.png"},
		{id="lush", name="Lush", path="res://Mesh/Textures/PubicHair/lush.png"},
		{id="paw", name="Paw", path="res://Mesh/Textures/PubicHair/paw.png"},
		{id="rectangle", name="Rectangle", path="res://Mesh/Textures/PubicHair/rectangle.png"},
		{id="square", name="Square", path="res://Mesh/Textures/PubicHair/square.png"},
	]

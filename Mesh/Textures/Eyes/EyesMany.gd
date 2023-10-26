extends TextureVariantMany

func _init():
	super._init()
	
	textureType = TextureType.Eyes
	textureSubType = TextureSubType.Generic
	textures = [
		{id="normal", name="Normal", path="res://Mesh/Textures/Eyes/eye.png"},
		{id="robot", name="Robot", path="res://Mesh/Textures/Eyes/roboteye.png"},
	]

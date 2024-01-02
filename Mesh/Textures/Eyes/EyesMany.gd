extends TextureVariantMany

func _init():
	super._init()
	
	textureType = TextureType.Eyes
	textureSubType = TextureSubType.Generic
	textures = [
		{id="normal", name="Normal", path="res://Mesh/Textures/Eyes/eye.png"},
		{id="robot", name="Robot", path="res://Mesh/Textures/Eyes/roboteye.png"},
		{id="heart", name="Heart", path="res://Mesh/Textures/Eyes/heart.png"},
		{id="demon", name="Demon", path="res://Mesh/Textures/Eyes/demon.png"},
		{id="animal", name="Animal", path="res://Mesh/Textures/Eyes/animal.png"},
		{id="hound", name="Hound", path="res://Mesh/Textures/Eyes/hound.png"},
	]

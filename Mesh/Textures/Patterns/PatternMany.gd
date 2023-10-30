extends TextureVariantMany

func _init():
	super._init()
	
	textureType = TextureType.Pattern
	textureSubType = TextureSubType.Generic
	textures = [
		{id="nopattern", name="No pattern", path="res://Mesh/Textures/Patterns/nopattern.png"},
		{id="jaguarpattern", name="Jaguar pattern", path="res://Mesh/Textures/Patterns/dottedfurpattern.png"},
	]

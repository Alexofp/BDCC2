extends TextureVariantMany

func _init():
	super._init()
	
	textureType = TextureType.Eyelashes
	textureSubType = TextureSubType.Generic
	textures = [
		{id="eyelash1", name="Eyelash 1", path="res://Mesh/Textures/Eyelashes/eyelash1.png"},
		{id="eyelash2", name="Eyelash 2", path="res://Mesh/Textures/Eyelashes/eyelash2.png"},
		{id="eyelash3", name="Eyelash 3", path="res://Mesh/Textures/Eyelashes/eyelash3.png"},
		{id="eyelash4", name="Eyelash 4", path="res://Mesh/Textures/Eyelashes/eyelash4.png"},
		{id="eyelash5", name="Eyelash 5", path="res://Mesh/Textures/Eyelashes/eyelash5.png"},
	]

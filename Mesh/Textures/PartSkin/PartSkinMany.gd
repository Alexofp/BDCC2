extends TextureVariantMany

func _init():
	super._init()
	
	textureType = TextureType.PartSkin
	textureSubType = TextureSubType.Generic
	textures = [
		{id="some", name="Some decal", path="res://Mesh/Textures/PartSkin/DecalTest.png"},
		{id="bodyshape", name="Body shape", path="res://Mesh/Textures/PartSkin/bodyshape.png"},
		{id="jaguar", name="Jaguar", path="res://Mesh/Textures/PartSkin/jaguar.png"},
	]

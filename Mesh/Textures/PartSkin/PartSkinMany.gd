extends TextureVariantMany

func _init():
	super._init()
	
	textureType = TextureType.PartSkin
	textureSubType = TextureSubType.Generic
	textures = [
		{id="some", name="Some decal", path="res://Mesh/Textures/PartSkin/DecalTest.png"},
		{id="some2", name="Some decal2", path="res://Mesh/Textures/PartSkin/nippleDefault2.png"},
	]

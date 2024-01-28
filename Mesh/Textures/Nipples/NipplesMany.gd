extends TextureVariantMany

func _init():
	super._init()
	
	textureType = TextureType.Nipples
	textureSubType = TextureSubType.Generic
	textures = [
		{id="default", name="Default", path="res://Mesh/Textures/Nipples/MyBody_MyBody Nipples_SMALL.png"},
		{id="big", name="Big", path="res://Mesh/Textures/Nipples/MyBody Nipples_Nipples_BaseColor.png"},
	]

extends RefCounted
class_name TextureVariantMany

var textureType:String = TextureType.None
var textureSubType:String = TextureSubType.Generic
var textures:Array = [
	##Example
	#{id="brow1", name="Brow 1", path="res://Mesh/Textures/Brows/brow1.png"},
]

func _init():
	pass

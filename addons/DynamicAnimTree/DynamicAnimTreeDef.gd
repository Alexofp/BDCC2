extends RefCounted
class_name DynamicAnimTreeDef

var layers:Dictionary[int, DATLayer]
var animLibPaths:Dictionary[int, String]

func _init() -> void:
	defineLayers()

func defineLayers():
	pass

func addLayer(_indx:int, _layer:DATLayer):
	layers[_indx] = _layer

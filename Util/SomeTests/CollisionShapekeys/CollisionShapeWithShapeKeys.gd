@tool
extends CollisionShape3D
class_name CollisionShapeWithShapeKeys

@export var shapeWithShapeKeys:CollisionWithShapeKeys : set = onShapeSetChanged
@export var shapeKeySettings:Dictionary[String, float] = {}
@export_tool_button("Process") var process_action = doProcess

func doProcess():
	var newShape:=ConcavePolygonShape3D.new()
	
	var theFaces := shapeWithShapeKeys.base.duplicate()
	for key in shapeKeySettings:
		if(shapeKeySettings[key] == 0.0):
			continue
		if(!shapeWithShapeKeys.shapeKeys.has(key)):
			continue
		var keyValue:float = shapeKeySettings[key]
		var shapeKeyFaces := shapeWithShapeKeys.shapeKeys[key]
		
		for _i in range(theFaces.size()):
			theFaces[_i].x += shapeKeyFaces[_i].x * keyValue
			theFaces[_i].y += shapeKeyFaces[_i].y * keyValue
			theFaces[_i].z += shapeKeyFaces[_i].z * keyValue
	newShape.set_faces(theFaces)
	
	shape = newShape

func onShapeSetChanged(_value:CollisionWithShapeKeys):
	shapeWithShapeKeys = _value
	
	shapeKeySettings = {}
	if(shapeWithShapeKeys):
		for key in shapeWithShapeKeys.shapeKeys:
			shapeKeySettings[key] = 0.0

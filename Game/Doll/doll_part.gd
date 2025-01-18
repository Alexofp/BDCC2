extends Node3D
class_name DollPart

func applyOption(_optionID:String, _value:Variant):
	pass

func getMeshes() -> Array:
	var result:Array = []
	for child in get_children():
		if(child is MeshInstance3D):
			result.append(child)
		result.append_array(getMeshesSub(child))
	return result

func getMeshesSub(theNode:Node) -> Array:
	var result:Array = []
	for child in theNode.get_children():
		if(child is MeshInstance3D):
			result.append(child)
		result.append_array(getMeshesSub(child))
	return result

func setBlendshape(_id:String, _value:float):
	for meshA in getMeshes():
		var mesh:MeshInstance3D = meshA
		var indx:int = mesh.find_blend_shape_by_name(_id)
		if(indx >= 0):
			mesh.set_blend_shape_value(indx, _value)

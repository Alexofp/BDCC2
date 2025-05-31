@tool
extends Node

@export var meshInstance:MeshInstance3D
@export var result:CollisionWithShapeKeys
@export_tool_button("Process") var process_action = doProcess

func doProcess():
	if(!meshInstance):
		return
	var newResult:CollisionWithShapeKeys = CollisionWithShapeKeys.new()
	if(result):
		newResult = result
	
	for _i in range(meshInstance.get_blend_shape_count()):
		meshInstance.set_blend_shape_value(_i, 0.0)
	
	var baseArrayMesh := meshInstance.bake_mesh_from_current_blend_shape_mix()
	var theCollision := baseArrayMesh.create_trimesh_shape()
	
	var theBaseFaces := theCollision.get_faces()
	newResult.base = theBaseFaces
	
	var theMesh:ArrayMesh = meshInstance.mesh
	for _i in range(meshInstance.get_blend_shape_count()):
		var blendShapeName:String = theMesh.get_blend_shape_name(_i)
		#print(blendShapeName)
		
		meshInstance.set_blend_shape_value(_i, 1.0)
		var shapeKeyArrayMesh := meshInstance.bake_mesh_from_current_blend_shape_mix()
		var theShapeCollision := shapeKeyArrayMesh.create_trimesh_shape()
		var theShapeFaces := theShapeCollision.get_faces()
		
		for _s in theShapeFaces.size():
			theShapeFaces[_s].x -= theBaseFaces[_s].x
			theShapeFaces[_s].y -= theBaseFaces[_s].y
			theShapeFaces[_s].z -= theBaseFaces[_s].z
		
		newResult.shapeKeys[blendShapeName] = theShapeFaces
		
		meshInstance.set_blend_shape_value(_i, 0.0)
		
	result = newResult

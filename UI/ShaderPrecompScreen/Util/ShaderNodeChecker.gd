extends Node
class_name ShaderNodeChecker

static func checkNode(_node:Node):
	var problems:Array[String]
	
	checkNode_REQURSIVE(_node, problems)
	
	if(problems.is_empty()):
		problems.append("NO PROBLEMS FOUND")
	Log.error(str(Util.join(problems, "\n")))

static func checkNode_REQURSIVE(_node:Node, _problems:Array[String]):
	var _nodePath:String = str(_node.get_path())
	
	if(_node is MeshInstance3D):
		for _i in _node.get_surface_override_material_count():
			var theMat:Material = _node.get_surface_override_material(_i)
			if(isMatBad(theMat)):
				_problems.append(_nodePath+" OVERRIDE MAT "+str(_i)+" BAD MAT")
		if(_node.mesh):
			var theMesh:Mesh = _node.mesh
			for _i in theMesh.get_surface_count():
				var theMat:Material = theMesh.surface_get_material(_i)
				if(isMatBad(theMat)):
					_problems.append(_nodePath+" BASE MESH MAT "+str(_i)+" BAD MAT")
	
	if(_node is GPUParticles3D):
		if(isMatBad(_node.process_material)):
			_problems.append(_nodePath+" PROCESS MATERIAL BAD MAT")
		if(isMatBad(_node.material_override)):
			_problems.append(_nodePath+" MATERIAL OVERRIDE BAD MAT")
		#for thePass in [_node.draw_pass_1, _node.draw_pass_2, _node.draw_pass_3, _node.draw_pass_4]:
			
		
	for childNode in _node.get_children():
		checkNode_REQURSIVE(childNode, _problems)

static func isMatBad(_mat:Material) -> bool:
	if(!_mat):
		return false
	
	if(_mat is ShaderMaterial):
		if(_mat.shader.resource_path.is_empty()):
			return true
	else:
		if(_mat.resource_path.is_empty()):
			return true
	
	return false

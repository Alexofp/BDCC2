extends Object
class_name Util

static func delete_children(node: Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

static func getAllMeshInstancesOfANode(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	
	var tocheck = [node]
	while(!tocheck.is_empty()):
		var thenode:Node = tocheck.pop_back()
		
		for n in thenode.get_children():
			if(n is MeshInstance3D):
				result.append(n)
			if(n.get_child_count() > 0):
				tocheck.append(n)
	
	return result

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

static func getFirstSkeleton3DOfANode(node: Node) -> Skeleton3D:
	var tocheck = [node]
	
	while(!tocheck.is_empty()):
		var thenode:Node = tocheck.pop_back()
		
		if(thenode is Skeleton3D):
			return thenode
		
		tocheck.append_array(thenode.get_children())
	
	return null

static func getScriptsInFolder(folder: String):
	var result = []
	
	var dir = DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
				#print("Found directory: " + file_name)
			else:
				if(file_name.get_extension() == "gd"):
					var full_path = folder.path_join(file_name)
					result.append(full_path)
			file_name = dir.get_next()
	else:
		Log.Printerr("An error occurred when trying to access the path "+folder)
	
	return result

static func getScriptsInFolderSmart(folder: String, includeThisFolder = true, includeSubFolders = true, reqursive = true):
	var result = []
	
	var dir = DirAccess.open(folder)
	if dir:
		dir.include_navigational = false
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if(includeSubFolders):
					var full_path = folder.path_join(file_name)
					result.append_array(getScriptsInFolderSmart(full_path, true, reqursive))
				#print("Found directory: " + file_name)
			else:
				if(!includeThisFolder):
					file_name = dir.get_next()
					continue
				if(file_name.get_extension() == "gd"):
					var full_path = folder.path_join(file_name)
					result.append(full_path)
			file_name = dir.get_next()
	else:
		Log.Printerr("An error occurred when trying to access the path "+folder)
	
	return result

static func moveValueUp(theArray, theIndex):
	var thingie = theArray[theIndex]
	theArray.remove_at(theIndex)
	theIndex -= 1
	if(theIndex < 0):
		theIndex = 0
	theArray.insert(theIndex, thingie)

static func moveValueDown(theArray, theIndex):
	var thingie = theArray[theIndex]
	theArray.remove_at(theIndex)
	theIndex += 1
	if(theIndex > theArray.size()):
		theIndex = theArray.size()
	theArray.insert(theIndex, thingie)

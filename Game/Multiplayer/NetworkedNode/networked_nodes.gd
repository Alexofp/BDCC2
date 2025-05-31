extends Node3D
class_name NetworkedNodes

func notifySpawned(_node:Node):
	if(!_node.is_in_group("Networked")):
		assert(false, "Node is not in the Networked group")
		return
	if(!_node.is_inside_tree()):
		assert(false, "Node is not inside the tree")
		return

	_node.tree_exiting.connect(onNetworkedNodeDeleted.bind(_node))
	if(!Network.isServerNotSingleplayer()):
		return
	var nodeData:Dictionary = _node.saveNetworkData() if _node.has_method("saveNetworkData") else {}
	if(_node is Node3D):
		nodeData["pos"] = _node.position
		nodeData["ang"] = _node.rotation
	Network.rpcClients(spawnNetworkedNode_RPC, [
		_node.scene_file_path, str(_node.get_parent().get_path()), _node.name, nodeData
	])
	var allNetworked:Array = []
	getAllNetworkedNodesOfRecursive(_node, allNetworked)
	for childNode in allNetworked:
		var childNodeData:Dictionary = childNode.saveNetworkData() if childNode.has_method("saveNetworkData") else {}
		if(childNode is Node3D):
			childNodeData["pos"] = childNode.position
			childNodeData["ang"] = childNode.rotation
		
		Network.rpcClients(spawnNetworkedNode_RPC, [
			childNode.scene_file_path, str(childNode.get_parent().get_path()), childNode.name, childNodeData
		])
	
func getAllNetworkedNodesOfRecursive(_node:Node, _ar:Array):
	for child in _node.get_children():
		if(child.is_in_group("Networked")):
			_ar.append(child)
		
		if(child.get_child_count() > 0):
			getAllNetworkedNodesOfRecursive(child, _ar)
	
	
func onNetworkedNodeDeleted(_node:Node):
	if(!Network.isServerNotSingleplayer()):
		return
	Log.Print("DELETING NODE "+str(_node.get_path()))
	Network.rpcClients(deleteNetworkedNode_RPC, [
		str(_node.get_path()),
	])

@rpc("authority", "call_remote", "reliable")
func deleteNetworkedNode_RPC(_thePath:String):
	Log.Print("DELETING NODE "+str(_thePath))
	var theNode:Node = get_tree().root.get_node(_thePath)
	if(!theNode):
		assert(false, "NODE NOT FOUND TO DELETE")
		return
	theNode.get_parent().remove_child(theNode)
	theNode.queue_free()

@rpc("authority", "call_remote", "reliable")
func spawnNetworkedNode_RPC(filePath:String, nodePath:String, nodeName:String, nodeData:Dictionary, cacheSupport:bool = false, tempSceneCache:Dictionary = {}):
	var theScene:PackedScene
	if(cacheSupport && tempSceneCache.has(filePath)):
		theScene = tempSceneCache[filePath]
	else:
		theScene = load(filePath)
		if(cacheSupport):
			tempSceneCache[filePath] = theScene
	
	var existingNodePath:String = nodePath.path_join(nodeName)
	if(get_tree().root.has_node(NodePath(existingNodePath))):
		# No need to spawn the node, we have it already
		var theNode:Node = get_tree().root.get_node(NodePath(existingNodePath))
		if(theNode.has_method("loadNetworkData")):
			theNode.loadNetworkData(nodeData)
		Log.Print("NETWORKED NODE LOADED: "+theNode.name)
	else:
		var theNode:Node = theScene.instantiate()
		theNode.name = nodeName
		if(theNode is Node3D):
			theNode.position = SAVE.loadVar(nodeData, "pos", Vector3(-99999.0, -99999.0, -99999.0))
			theNode.rotation = SAVE.loadVar(nodeData, "ang", Vector3(0.0, 0.0, 0.0))
		
		var parentNode:Node = get_tree().root.get_node(NodePath(nodePath))
		parentNode.add_child(theNode)
		
		if(theNode.has_method("loadNetworkData")):
			theNode.loadNetworkData(nodeData)
		
		Log.Print("NETWORKED NODE SPAWNED: "+theNode.name)

func _ready() -> void:
	GameInteractor.networkedNodes = self

func gatherGroupList() -> Array[Node]:
	var theNodes := get_tree().get_nodes_in_group("Networked")
	
	return theNodes


func saveNetworkData() -> Dictionary:
	var pathDict:Dictionary[int, String] = {}
	var stringToPathDict:Dictionary[String, int] = {}
	var lastPathID:int = 0
	
	var currentNodes := gatherGroupList()
	var nodesData:Array = []
	
	for node in currentNodes:
		var theFilePath:String = node.scene_file_path
		if(theFilePath == ""):
			assert(false, "NO SCENE FILE PATH ATTACHED TO NETWORKED NODE")
			continue
		var theFileID:int = 0
		if(stringToPathDict.has(theFilePath)):
			theFileID = stringToPathDict[theFilePath]
		else:
			pathDict[lastPathID] = theFilePath
			stringToPathDict[theFilePath] = lastPathID
			theFileID = lastPathID
			lastPathID += 1
		
		
		var theData:Dictionary = {
			file = theFileID,
			path = str(node.get_parent().get_path()),
			name = str(node.name),
			data = node.saveNetworkData() if node.has_method("saveNetworkData") else {},
		}
		if(node is Node3D):
			theData["data"]["pos"] = node.position
			theData["data"]["ang"] = node.rotation
		
		nodesData.append(theData)
	
	return {
		pathDict = pathDict,
		nodes = nodesData,
	}

func loadNetworkData(_data:Dictionary):
	var currentNodes := gatherGroupList()
	for node in currentNodes:
		node.get_parent().remove_child(node)
	for node in currentNodes:
		node.queue_free()
	
	var pathDict = SAVE.loadVar(_data, "pathDict", {})
	
	var tempSceneCache:Dictionary = {}
	
	var nodesData:Array = SAVE.loadVar(_data, "nodes", [])
	for nodeEntry in nodesData:
		var filePathID:int = SAVE.loadVar(nodeEntry, "file", 0)
		var filePath:String = pathDict[filePathID]
		var nodePath:String = SAVE.loadVar(nodeEntry, "path", "")
		var nodeName:String = SAVE.loadVar(nodeEntry, "name", "")
		var nodeData:Dictionary = SAVE.loadVar(nodeEntry, "data", {})
		
		spawnNetworkedNode_RPC(filePath, nodePath, nodeName, nodeData, true, tempSceneCache)

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
	var nodeData:Dictionary = _node.saveData() if _node.has_method("saveData") else {}
	if(_node is Node3D):
		nodeData["pos"] = _node.position
		nodeData["ang"] = _node.rotation
	Network.rpcClients(spawnNetworkedNode_RPC.bind(
		_node.scene_file_path, str(_node.get_parent().get_path()), _node.name, nodeData
	))
	var allNetworked:Array = []
	getAllNetworkedNodesOfRecursive(_node, allNetworked)
	for childNode in allNetworked:
		var childNodeData:Dictionary = childNode.saveData() if childNode.has_method("saveData") else {}
		if(childNode is Node3D):
			childNodeData["pos"] = childNode.position
			childNodeData["ang"] = childNode.rotation
		
		Network.rpcClients(spawnNetworkedNode_RPC.bind(
			childNode.scene_file_path, str(childNode.get_parent().get_path()), childNode.name, childNodeData
		))
	
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
	Network.rpcClients(deleteNetworkedNode_RPC.bind(
		str(_node.get_path()),
	))

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
	
	var existingNode:Node = get_tree().root.get_node_or_null(NodePath(existingNodePath))
	
	if(existingNode && existingNode.scene_file_path != filePath):
		Log.Print("NETWORKED NODE HAS WRONG SCENE PATH, DELETING "+existingNode.name)
		existingNode.get_parent().remove_child(existingNode)
		existingNode.queue_free()
		existingNode = null
	
	if(existingNode):
		# No need to spawn the node, we have it already
		var theNode:Node = get_tree().root.get_node(NodePath(existingNodePath))
		if(theNode.has_method("loadData")):
			theNode.loadData(nodeData)
		Log.Print("NETWORKED NODE LOADED: "+theNode.name)
	else:
		var theNode:Node = theScene.instantiate()
		theNode.name = nodeName
		if(theNode is Node3D):
			theNode.position = SAVE.loadVar(nodeData, "pos", Vector3(-99999.0, -99999.0, -99999.0))
			theNode.rotation = SAVE.loadVar(nodeData, "ang", Vector3(0.0, 0.0, 0.0))
		
		var parentNode:Node = get_tree().root.get_node(NodePath(nodePath))
		parentNode.add_child(theNode)
		
		if(theNode.has_method("loadData")):
			theNode.loadData(nodeData)
		
		Log.Print("NETWORKED NODE SPAWNED: "+theNode.name)

func _enter_tree() -> void:
	GI.networkedNodes = self

func _exit_tree() -> void:
	GI.networkedNodes = null

func gatherGroupList() -> Array[Node]:
	var theNodes := get_tree().get_nodes_in_group("Networked")
	
	return theNodes

# Sends an event to every client (and server too)
func sendGlobalEvent(_node:Node, _eventID:String, _args:Array=[]):
	var theNodeRef = GI.getUniqueIDOf(_node)
	
	# Call it locally
	if(_node.has_method("handleGlobalEvent")):
		_node.call("handleGlobalEvent", _eventID, _args)
	
	Network.rpcClients(handleNodeGlobalEvent_RPC.bind(theNodeRef, _eventID, _args))

@rpc("authority", "call_remote", "reliable")
func handleNodeGlobalEvent_RPC(_nodeID, _eventID:String, _args:Array):
	var theNode:Node= GI.getNodeByUniqueID(_nodeID)
	if(!theNode):
		Log.Printerr("Node not found for a global event. ID="+str(_nodeID)+" event="+str(_eventID))
		return
	if(theNode.has_method("handleGlobalEvent")):
		theNode.call("handleGlobalEvent", _eventID, _args)

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.Var, saveData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	loadData(_data.readVar())
	_data.endLoad()

func saveData() -> Dictionary:
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
			data = node.saveData() if node.has_method("saveData") else {},
		}
		if(node is Node3D):
			theData["data"]["pos"] = node.position
			theData["data"]["ang"] = node.rotation
		
		nodesData.append(theData)
	
	return {
		pathDict = pathDict,
		nodes = nodesData,
	}

func loadData(_data:Dictionary):
	var currentNodes := gatherGroupList()
	
	var pathDict = SAVE.loadVar(_data, "pathDict", {})
	
	var tempSceneCache:Dictionary = {}
	
	var didLoadDict:Dictionary[NodePath, bool] = {}
	
	var nodesData:Array = SAVE.loadVar(_data, "nodes", [])
	for nodeEntry in nodesData:
		var filePathID:int = SAVE.loadVar(nodeEntry, "file", 0)
		var filePath:String = pathDict[filePathID]
		var nodePath:String = SAVE.loadVar(nodeEntry, "path", "")
		var nodeName:String = SAVE.loadVar(nodeEntry, "name", "")
		var nodeData:Dictionary = SAVE.loadVar(nodeEntry, "data", {})
		
		var existingNodePath:NodePath = NodePath(nodePath.path_join(nodeName))
		didLoadDict[existingNodePath] = true
		
		spawnNetworkedNode_RPC(filePath, nodePath, nodeName, nodeData, true, tempSceneCache)

	
	var toDelete:Array[Node] = []
	
	for theNode in currentNodes:
		if(!theNode || !is_instance_valid(theNode)):
			continue
		var thePath:NodePath = theNode.get_path()
		if(!didLoadDict.has(thePath)):
			toDelete.append(theNode)
		
	for node in toDelete:
		Log.Print("DELETING "+str(node)+" BECAUSE IT DOESN'T EXIST ON THE SERVER.")
		node.get_parent().remove_child(node)
	for node in toDelete:
		node.queue_free()

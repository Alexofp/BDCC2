extends Node3D
class_name NetworkedNodes

# Also gets used for saving/loading props but oh well

# SyncStatic = static prop. Should always exist on both the server and the client
# SyncDynamic = dynamic prop. Spawned by the server. All existing dynamic props are deleted on join
# SyncChild = Child of a sync prop. Also gets sync'd

const SYNC_STATIC_GROUP = "SyncStatic"
const SYNC_DYNAMIC_GROUP = "SyncDynamic"
const SYNC_CHILD_GROUP = "SyncChild"

func isStatic(_node:Node) -> bool:
	return _node.is_in_group(SYNC_STATIC_GROUP)

func isDynamic(_node:Node) -> bool:
	return _node.is_in_group(SYNC_DYNAMIC_GROUP)

## Marks this node to be synched and saved/loaded
func makeNodeNetDynamic(_node:Node):
	if(!Network.isServer() || !_node):
		return
	if(_node.is_in_group(SYNC_DYNAMIC_GROUP)):
		return
	_node.remove_from_group(SYNC_STATIC_GROUP)
	_node.add_to_group(SYNC_DYNAMIC_GROUP)
	if(Network.isServerNotSingleplayer()):
		notifySpawned(_node)
		#notifySpawned.call_deferred(_node) # Should be instant probably..

func notifySpawned(_node:Node):
	if(!_node.is_in_group(SYNC_DYNAMIC_GROUP)):
		assert(false, "Node is not in the SyncDynamic group")
		return
	if(!_node.is_inside_tree()):
		assert(false, "Node is not inside the tree")
		return

	_node.tree_exiting.connect(onNetDynamicNodeDeleted.bind(_node)) #Should this be done always?
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
	getAllNetChildNodesOfRecursive(_node, allNetworked)
	for childNode in allNetworked:
		var childNodeData:Dictionary = childNode.saveData() if childNode.has_method("saveData") else {}
		if(childNode is Node3D):
			childNodeData["pos"] = childNode.position
			childNodeData["ang"] = childNode.rotation
		
		Network.rpcClients(spawnNetworkedNode_RPC.bind(
			childNode.scene_file_path, str(childNode.get_parent().get_path()), childNode.name, childNodeData
		))
	
func getAllNetChildNodesOfRecursive(_node:Node, _ar:Array):
	for child in _node.get_children():
		#if(child.is_in_group(SYNC_STATIC_GROUP) || child.is_in_group(SYNC_DYNAMIC_GROUP)):
		if(child.is_in_group(SYNC_CHILD_GROUP)):
			_ar.append(child)
		
		if(child.get_child_count() > 0):
			getAllNetChildNodesOfRecursive(child, _ar)
	
	
func onNetDynamicNodeDeleted(_node:Node):
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

func getAllStaticSyncNodes() -> Array[Node]:
	return get_tree().get_nodes_in_group(SYNC_STATIC_GROUP)

func getAllDynamicSyncNodes() -> Array[Node]:
	return get_tree().get_nodes_in_group(SYNC_DYNAMIC_GROUP)

# Sends an event to every client (and server too)
func sendGlobalEvent(_node:Node, _eventID:String, _args:Array=[]):
	if(!Network.isServer()):
		assert(false, "THIS FUNCTION CAN ONLY BE CALLED FROM A SERVER")
		return
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

# Sends an event to the server
func sendServerEvent(_node:Node, _eventID:String, _args:Array=[]):
	var theNodeRef = GI.getUniqueIDOf(_node)
	
	if(Network.isServer()):
		# Call it locally
		if(_node.has_method("handleServerEvent")):
			_node.call("handleServerEvent", _eventID, _args)
	else:
		handleNodeServerEvent_RPC.rpc_id(1, theNodeRef, _eventID, _args)

@rpc("any_peer", "call_remote", "reliable")
func handleNodeServerEvent_RPC(_nodeID, _eventID:String, _args:Array):
	var theNode:Node= GI.getNodeByUniqueID(_nodeID)
	if(!theNode):
		Log.Printerr("Node not found for a server event. ID="+str(_nodeID)+" event="+str(_eventID))
		return
	if(theNode.has_method("handleServerEvent")):
		theNode.call("handleServerEvent", _eventID, _args)

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.Var, saveData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	loadData(_data.readVar())
	_data.endLoad()

func nodeToScenePath(_node:Node) -> String:
	var theFilePath:String = _node.scene_file_path
	#if(theFilePath == ""):
	return theFilePath

func scenePathToFinalPath(_scenePath:String) -> String:
	return _scenePath

func deleteDynamicNodes():
	for theNode:Node in getAllDynamicSyncNodes().duplicate():
		theNode.name += "_DELETED"
		theNode.queue_free()

func loadNodes(_nodes:Array[Dictionary], _isDynamic:bool = false, theLateLoadNodes:Dictionary[Node, Dictionary] = {}):
	#var _lateNodes:Dictionary[Node, Dictionary]
	for theEntry:Dictionary in _nodes:
		var theFile:String = SAVE.loadStr(theEntry, "file")
		var thePath:NodePath = SAVE.loadVar(theEntry, "path", NodePath())
		if(theFile.is_empty() || thePath.is_empty()):
			continue
		var theData:Dictionary = SAVE.loadDict(theEntry, "data")
		
		var theName:String = thePath.get_name(thePath.get_name_count()-1)
		var theParentPath:NodePath = thePath.slice(0, thePath.get_name_count()-1)
		
		if(!_isDynamic):
			var theThing:Node = get_tree().root.get_node(thePath)
			if(!theThing):
				Log.warning("(Networked nodes loadNodes) Static node seems to be gone: "+str(thePath))
				continue
			# Check if the thing has the right type?
			if(theThing.scene_file_path != theFile):
				Log.warning("(Networked nodes loadNodes) Static node seems to have wrong scene path: save="+str(theFile)+" found="+str(theThing.scene_file_path))
				# will try to continue anyway
			if(theThing.has_method("loadData")):
				theThing.loadData(theData)
			if(theThing.has_method("loadDataLate")):
				#_lateNodes[theThing] = theData
				theLateLoadNodes[theThing] = theData
		
		if(_isDynamic):
			var theExistingThing:Node = get_tree().root.get_node_or_null(thePath)
			if(theExistingThing):
				Log.warning("(Networked nodes loadNodes) Dynamic node already existed (deleting): "+str(thePath))
				theExistingThing.name += "_DELETED"
				theExistingThing.queue_free()
				theExistingThing = null
			
			var theParentNode:Node = get_tree().root.get_node_or_null(theParentPath)
			if(!theParentNode):
				Log.error("(Networked nodes loadNodes) Parent node not found for path "+str(thePath))
				continue
			var theThingScene:PackedScene = load(theFile)
			if(!theThingScene):
				Log.error("(Networked nodes loadNodes) Scene path not found: '"+str(theFile)+"'")
				continue
			var theThing:Node = theThingScene.instantiate()
			theThing.name = theName
			theParentNode.add_child(theThing, true)
			theThing.name = theName
			if(theEntry.has("pos") && (theThing is Node3D)):
				theThing.position = SAVE.loadVec3(theEntry, "pos")
				theThing.rotation = SAVE.loadVec3(theEntry, "ang")
			
			if(theThing.has_method("loadData")):
				theThing.loadData(theData)
			if(theThing.has_method("loadDataLate")):
				#_lateNodes[theThing] = theData
				theLateLoadNodes[theThing] = theData
			makeNodeNetDynamic(theThing)
	
	#for theNode:Node in _lateNodes:
	#	theNode.loadDataLate(_lateNodes[theNode])
	
func saveNodes(_nodes:Array[Node], _isDynamic:bool = false) -> Array[Dictionary]:
	var nodesData:Array[Dictionary] = []
	
	for theNode:Node in _nodes: # Sort by parent nodepath lengths?
		var theFilePath:String = nodeToScenePath(theNode)
		if(theFilePath == ""):
			assert(false, "NO SCENE FILE PATH ATTACHED TO NETWORKED NODE")
			continue
		var theData:Dictionary = {
			#file = theFileID,
			file = theFilePath,
			path = theNode.get_path(), # Simplify this somehow?
			#name = str(theNode.name),
			data = theNode.saveData() if theNode.has_method("saveData") else {},
		}
		if(isDynamic(theNode) && (theNode is Node3D)):
			theData["pos"] = theNode.position
			theData["ang"] = theNode.rotation
		
		# MAKE ME WORK
		#var allNetworked:Array = []
		#getAllNetChildNodesOfRecursive(theNode, allNetworked)
		#if(!allNetworked.is_empty()):
		#	var theChildDatas:Array[Dictionary]
		#	theData["childs"] = 
		
		nodesData.append(theData)
		
	return nodesData

func saveData() -> Dictionary:
	return {
		nodesStatic = saveNodes(getAllStaticSyncNodes(), false),
		nodesDynamic = saveNodes(getAllDynamicSyncNodes(), true),
	}

func loadData(_data:Dictionary):
	deleteDynamicNodes()
	var theLateLoadNodes:Dictionary[Node, Dictionary]
	loadNodes(SAVE.loadArrayOfDicts(_data, "nodesStatic"), false, theLateLoadNodes)
	loadNodes(SAVE.loadArrayOfDicts(_data, "nodesDynamic"), true, theLateLoadNodes)
	# Do the late load here?
	for theNode:Node in theLateLoadNodes:
		theNode.loadDataLate(theLateLoadNodes[theNode])

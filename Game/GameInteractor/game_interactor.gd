extends Node

var characterRegistry:CharacterRegistry
var pawnRegistry:PawnRegistry
var dollHolder:DollHolder
var sitManager:SitManager

var serverCommandObjects:Dictionary = {}
var clientCommandObjects:Dictionary = {}

const CALLTYPE_ARRAY = 0
const CALLTYPE_SPREADARGS = 1

const UID_DOLL = 0
const UID_PATH = 1
const UID_NULL = 2

func _ready():
	Network.playerConnected.connect(onPlayerConnected)

func onPlayerConnected(_id:int, _playerInfo:NetworkPlayerInfo):
	if(Network.isServer() && Network.getMultiplayerID() != _id):
		Log.Print("(GAME INTERACTOR) Sending full data to "+str(_id))
		applyFullNetworkData.rpc_id(_id, saveFullNetworkData())

@rpc("authority", "call_remote", "reliable")
func applyFullNetworkData(_data:Dictionary):
	Log.Print("(GAME INTERACTOR) Received full data")
	loadFullNetworkData(_data)

func saveFullNetworkData() -> Dictionary:
	return {
		characterRegistry = characterRegistry.saveNetworkData(),
		pawnRegistry = pawnRegistry.saveNetworkData(),
		dolls = dollHolder.saveNetworkData(),
		sitManager = sitManager.saveNetworkData(),
	}

func loadFullNetworkData(_data:Dictionary):
	characterRegistry.loadNetworkData(SAVE.loadVar(_data, "characterRegistry", {}))
	pawnRegistry.loadNetworkData(SAVE.loadVar(_data, "pawnRegistry", {}))
	dollHolder.loadNetworkData(SAVE.loadVar(_data, "dolls", {}))
	sitManager.loadNetworkData(SAVE.loadVar(_data, "sitManager", {}))

func registerOnServerCommand(_command:int, _theObj:Object, functionName:String, callType:int, argsList:Array):
	if(serverCommandObjects.has(_command)):
		var cureRef:WeakRef = serverCommandObjects[_command][0]
		if(cureRef.get_ref()):
			assert(false, "REDEFINING SERVER COMMAND WITH ID "+str(_command))
	serverCommandObjects[_command] = [weakref(_theObj), functionName, argsList, callType]

func registerOnClientCommand(_command:int, _theObj:Object, functionName:String, callType:int, argsList:Array):
	if(clientCommandObjects.has(_command)):
		var cureRef:WeakRef = clientCommandObjects[_command][0]
		if(cureRef.get_ref()):
			assert(false, "REDEFINING CLIENT COMMAND WITH ID "+str(_command))
	clientCommandObjects[_command] = [weakref(_theObj), functionName, argsList, callType]


func hasAuthority() -> bool:
	return !Network.isMultiplayer() || is_multiplayer_authority()

func argsFitArgsList(_theArgs:Array, _argList:Array) -> bool:
	if(_argList.size() != _argList.size()):
		return false
		
	for _i in range(_theArgs.size()):
		if(!IntComArg.isValid(_argList[_i], _theArgs[_i])):
			return false
	
	return true

@rpc("any_peer", "call_remote", "reliable")
func internalDoOnServer(_command:int, _data:Array = []):
	if(!hasAuthority()):
		return
	
	var clientID:int = multiplayer.get_remote_sender_id()
	
	if(serverCommandObjects.has(_command)):
		var commandEntry:Array = serverCommandObjects[_command]
		if(!argsFitArgsList(_data, commandEntry[2])):
			Log.Printerr("Game Interactor's server command received bad arguments. ID is "+str(_command)+" from client "+str(clientID)+". Args: "+str(_data)+" Expected: "+str(IntComArg.getDebugNameForList(commandEntry[2])))
			return
		var theObj:Object = commandEntry[0].get_ref()
		if(!theObj):
			Log.Printerr("Game Interactor's server command reference is null. ID is "+str(_command)+" from client "+str(clientID))
			return
			
		var theCallType:int = commandEntry[3]
		if(theCallType == CALLTYPE_ARRAY):
			theObj.call(commandEntry[1], _command, clientID, _data)
		elif(theCallType == CALLTYPE_SPREADARGS):
			var funcData:Array = [_command, clientID]
			funcData.append_array(_data)
			theObj.callv(commandEntry[1], funcData)
		else:
			assert(false, "UNKNOWN CALL TYPE "+str(theCallType))
		
	elif(_command == InteractCommand.CHARACTER_DO_INTERACT):
		if(_data.size() == 2 && (_data[0] is int) && (_data[1] is int)):
			var doll:DollController = dollHolder.findDollWithUniqueID(_data[0])
			if(doll):
				doll.getInteractor().doActionByID(_data[1])
	elif(_command == InteractCommand.PING):
		Log.Print("PING-PING from client "+str(clientID))
		#await get_tree().create_timer(0.1).timeout
		if(clientID != 0 && clientID != 1):
			internalDoOnClient.rpc_id(clientID, InteractCommand.PONG)
	else:
		Log.Printerr("Game Interactor received unsupported doOnServer() command id "+str(_command)+" from client "+str(clientID))

@rpc("authority", "call_remote", "reliable")
func internalDoOnClient(_command:int, _data:Array = []):
	if(hasAuthority()):
		return
	
	var serverID:int = multiplayer.get_remote_sender_id()
	
	if(clientCommandObjects.has(_command)):
		var commandEntry:Array = clientCommandObjects[_command]
		if(!argsFitArgsList(_data, commandEntry[2])):
			Log.Printerr("Game Interactor's client command received bad arguments. ID is "+str(_command)+" from server "+str(serverID)+". Args: "+str(_data)+" Expected: "+str(IntComArg.getDebugNameForList(commandEntry[2])))
			return
		var theObj:Object = commandEntry[0].get_ref()
		if(!theObj):
			Log.Printerr("Game Interactor's client command reference is null. ID is "+str(_command)+" from server "+str(serverID))
			return
			
		var theCallType:int = commandEntry[3]
		if(theCallType == CALLTYPE_ARRAY):
			theObj.call(commandEntry[1], _command, serverID, _data)
		elif(theCallType == CALLTYPE_SPREADARGS):
			var funcData:Array = [_command, serverID]
			funcData.append_array(_data)
			theObj.callv(commandEntry[1], funcData)
		else:
			assert(false, "UNKNOWN CALL TYPE "+str(theCallType))
		
	elif(_command == InteractCommand.PONG):
		Log.Print("PONG-PONG from server "+str(serverID))
	else:
		Log.Printerr("Game Interactor received unsupported doOnClient() command id "+str(_command)+" from server "+str(serverID))

func doOnServer(_command:int, _data:Array = []):
	if(!Network.isServer()):
		internalDoOnServer.rpc_id(1, _command, _data)
	else:
		internalDoOnServer(_command, _data)

func doOnClient(_clientID:int, _command:int, _data:Array = []):
	if(!Network.isMultiplayer()):
		return
	if(Network.getMultiplayerID() == 1):
		internalDoOnClient.rpc_id(_clientID, _command, _data)

func doOnAllClients(_command:int, _data:Array = []):
	if(!Network.isMultiplayer()):
		return
	if(Network.getMultiplayerID() == 1):
		#internalDoOnClient.rpc(_command, _data)
		Network.rpcClients(internalDoOnClient, [_command, _data])

func doOnClientList(_clients:Array, _command:int, _data:Array = []):
	if(!Network.isMultiplayer()):
		return
	if(Network.getMultiplayerID() == 1):
		for clientID in _clients:
			internalDoOnClient.rpc_id(clientID, _command, _data)

func sendPingToServer():
	doOnServer(InteractCommand.PING)

func askDoAction(doll:DollController, action:InteractActionBaked):
	#doll.getInteractor().doActionByID(action.uniqueID)
	doOnServer(InteractCommand.CHARACTER_DO_INTERACT, [doll.uniqueID, action.uniqueID])

func getUniqueIDOf(thing:Node) -> Array:
	if(thing is DollController):
		return [UID_DOLL, thing.uniqueID]
	if(thing == null):
		return [UID_NULL, null]
	
	return [UID_PATH, str(get_tree().root.get_path_to(thing).get_concatenated_names())]

func getNodeByUniqueID(theID:Array) -> Node:
	if(theID.size() != 2):
		return null
	if(!(theID[0] is int)):
		return null
	var idType:int = theID[0]
	if(idType == UID_NULL):
		return null
	if(idType == UID_DOLL):
		if(!(theID[1] is int)):
			Log.Printerr("Illegal doll UID: "+str(theID))
			return null
		return dollHolder.findDollWithUniqueID(theID[1])
	
	if(idType == UID_PATH):
		if(!(theID[1] is String)):
			Log.Printerr("Illegal path UID: "+str(theID))
			return null
		return get_tree().root.get_node_or_null(NodePath(theID[1]))
	
	return null

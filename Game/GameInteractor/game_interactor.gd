extends Node

var characterRegistry:CharacterRegistry
var pawnRegistry:PawnRegistry
var dollHolder:DollHolder
var sitManager:SitManager
var networkedNodes:NetworkedNodes
var sexManager:SexManager
var inventoryRegistry:InventoryRegistry
var leashSystem:LeashSystem
var actionSystem:ActionSystem
var world:World

var serverCommandObjects:Dictionary = {}
var clientCommandObjects:Dictionary = {}

const CALLTYPE_ARRAY = 0
const CALLTYPE_SPREADARGS = 1

const UID_DOLL = 0
const UID_PATH = 1
const UID_NULL = 2

func _ready():
	#Network.playerConnected.connect(onPlayerConnected)
	pass

func applyFullNetworkData(_data:Bins):
	Log.Print("(GAME INTERACTOR) Received full data")
	loadFullNetworkData(_data)
	_data.checkEnded()

func saveFullNetworkData() -> Bins:
	var data := Bins.saveStart([
		Bins.BINS, GM.main.timeManager.saveNetworkData(),
		Bins.BINS, inventoryRegistry.saveNetworkData(),
		Bins.BINS, characterRegistry.saveNetworkData(),
		Bins.BINS, pawnRegistry.saveNetworkData(),
		Bins.BINS, dollHolder.saveNetworkData(),
		Bins.BINS, sexManager.saveNetworkData(),
		Bins.BINS, leashSystem.saveNetworkData(),
		Bins.BINS, networkedNodes.saveNetworkData(),
		Bins.BINS, sitManager.saveNetworkData(),
	])
	return data.endSave()

func loadFullNetworkData(_data:Bins):
	_data.loadStart()
	GM.main.timeManager.loadNetworkData(_data.readBins())
	inventoryRegistry.loadNetworkData(_data.readBins())
	characterRegistry.loadNetworkData(_data.readBins())
	pawnRegistry.loadNetworkData(_data.readBins())
	dollHolder.loadNetworkData(_data.readBins())
	sexManager.loadNetworkData(_data.readBins())
	leashSystem.loadNetworkData(_data.readBins())
	networkedNodes.loadNetworkData(_data.readBins())
	sitManager.loadNetworkData(_data.readBins())
	_data.endLoad()

func saveFullData() -> Dictionary:
	return {
		timeManager = GM.main.timeManager.saveData(),
		inventoryRegistry = inventoryRegistry.saveData(),
		characterRegistry = characterRegistry.saveData(),
		pawnRegistry = pawnRegistry.saveData(),
		dolls = dollHolder.saveData(),
		sexManager = sexManager.saveData(),
		networkedNodes = networkedNodes.saveData(),
		sitManager = sitManager.saveData(),
	}

func loadFullData(_data:Dictionary):
	GM.main.timeManager.loadData(SAVE.loadVar(_data, "timeManager", {}))
	inventoryRegistry.loadData(SAVE.loadVar(_data, "inventoryRegistry", {}))
	characterRegistry.loadData(SAVE.loadVar(_data, "characterRegistry", {}))
	pawnRegistry.loadData(SAVE.loadVar(_data, "pawnRegistry", {}))
	dollHolder.loadData(SAVE.loadVar(_data, "dolls", {}))
	sexManager.loadData(SAVE.loadVar(_data, "sexManager", {}))
	networkedNodes.loadData(SAVE.loadVar(_data, "networkedNodes", {}))
	sitManager.loadData(SAVE.loadVar(_data, "sitManager", {}))

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
		Network.rpcClients(internalDoOnClient.bind(_command, _data))

func doOnClientList(_clients:Array, _command:int, _data:Array = []):
	if(!Network.isMultiplayer()):
		return
	if(Network.getMultiplayerID() == 1):
		for clientID in _clients:
			internalDoOnClient.rpc_id(clientID, _command, _data)

func sendPingToServer():
	doOnServer(InteractCommand.PING)

func askDoPawnInteractionAction(_pawn:CharacterPawn, _entry:Array):
	if(Network.isServer()):
		_pawn.getPawnInteractor().doBakedActionInteraction(_entry[1], _entry[3])
		return
	askDoPawnInteractionAction_SERVERRPC.rpc_id(1, _pawn.getCharID(), _entry[1], _entry[3])
	pass

@rpc("any_peer", "call_remote", "reliable")
func askDoPawnInteractionAction_SERVERRPC(_pawnID:String, _actionIndx:int, _actionID:String):
	var thePawn := GM.pawnRegistry.getPawn(_pawnID)
	if(!thePawn):
		#Remove this log?
		Log.error("Pawn not found to do action. Pawn="+_pawnID+", Action id ="+_actionID)
		return
	thePawn.getPawnInteractor().doBakedActionInteraction(_actionIndx, _actionID)

func askDoPawnAction(_pawn:CharacterPawn, _action:InteractActionBaked):
	if(Network.isServer()):
		_pawn.getPawnInteractor().doBakedAction(_action.uniqueID, _action.actionID)
		return
	askDoPawnAction_SERVERRPC.rpc_id(1, _pawn.getCharID(), _action.uniqueID, _action.actionID)
	pass

@rpc("any_peer", "call_remote", "reliable")
func askDoPawnAction_SERVERRPC(_pawnID:String, _actionIndx:int, _actionID:String):
	var thePawn := GM.pawnRegistry.getPawn(_pawnID)
	if(!thePawn):
		#Remove this log?
		Log.error("Pawn not found to do action. Pawn="+_pawnID+", Action id ="+_actionID)
		return
	thePawn.getPawnInteractor().doBakedAction(_actionIndx, _actionID)

func askDoInteractEntryDo(_pawn:CharacterPawn, _action:InteractEntryDo, _category:InteractCategory, _indx:int):
	if(Network.isServer()):
		_pawn.doInteractEntryDo(_action, _category.target)
	else:
		askDoInteractEntryDo_SERVERRPC.rpc_id(1, _pawn.getCharID(), getUniqueIDOf(_category.target), _indx, _action.action.id)

@rpc("any_peer", "call_remote", "reliable")
func askDoInteractEntryDo_SERVERRPC(_pawnID:String, _targetArray, _actionIndx:int, _actionID:String):
	var theTarget := getNodeByUniqueID(_targetArray)
	if(!theTarget):
		Log.Printerr("Interact target node not found: "+str(_targetArray))
		return
	var thePawn := GM.pawnRegistry.getPawn(_pawnID)
	if(!thePawn):
		#Remove this log?
		Log.error("Pawn not found to do interact entry. Pawn="+_pawnID+", Action id ="+_actionID)
		return
	#Log.Print(str(_actionIndx))
	thePawn.pawn_interactor.updateInteractor()
	thePawn.doInteractEntryDoByIndex(_actionIndx, theTarget, _actionID)

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

@rpc("any_peer", "call_remote", "reliable")
func askChatSend_ServerRPC(_text:String):
	if(!hasAuthority()):
		return
	handleChatSend(Network.getRPCPlayerInfo(), _text)

# Only gets called on server
func handleChatSend(_playerInfo:NetworkPlayerInfo, _text:String):
	#print("MEOW: "+_text)
	if(!_playerInfo):
		return
	
	var thePawn := GM.pawnRegistry.getPawn(_playerInfo.charID)
	var theDoll:DollController = thePawn.getDoll() if thePawn else null
	
	if(_text.begins_with("/")):
		var commandPair := Util.splitOnFirst(_text, " ")
		var commandType:String = commandPair[0].substr(1)
		var commandArgText:String = commandPair[1] if commandPair.size() > 1 else ""
		
		#TODO: Setup a system for kicking and other stuff
		if(commandType == "meow"):
			_playerInfo.sendToChat("Meow meow :3")
		elif(commandType == "echo"):
			_playerInfo.sendToChat("Echoing back: "+commandArgText)
		elif(commandType == "me"):
			if(thePawn):
				thePawn.sayAdvanced(CharacterPawn.parseMeTextToArray(commandArgText))
		else:
			_playerInfo.sendToChat("Unknown command: "+commandType)
	else:
		if(thePawn):
			thePawn.sayAdvanced(CharacterPawn.parseSayTextToArray(_text))
		#sendChatGlobal(_playerInfo.getName()+": "+_text)
	
	if(theDoll):
		theDoll.resetTypingStatus()
		if(Network.isServerNotSingleplayer()):
			Network.rpcClients(notifyDollResetTypingStatus_RPC.bind(theDoll.uniqueID))
	
const TYPING_NONE = 0
const TYPING_CHAT = 1
const TYPING_ACTION = 2

func getTypingStatusFromText(_text:String) -> int:
	if(_text.is_empty()):
		return TYPING_NONE
	if(_text.begins_with("*") || _text.begins_with("/me ")):
		return TYPING_ACTION
	if(_text.begins_with("/")):
		return TYPING_NONE
	
	return TYPING_CHAT

func notifyTyping(_new_text:String):
	var theStatus:int = getTypingStatusFromText(_new_text)
	if(theStatus == TYPING_CHAT || theStatus == TYPING_ACTION):
		if(Network.isClient()):
			notifyTyping_SERVERRPC.rpc_id(1, theStatus)
		else:
			notifyTyping_SERVERRPC(theStatus)

@rpc("any_peer", "call_remote", "unreliable")
func notifyTyping_SERVERRPC(_status:int):
	var theInfo := Network.getSenderPlayerInfo()
	if(!theInfo):
		return
	var theCharID:String = theInfo.getCharID()
	var thePawn := GM.pawnRegistry.getPawn(theCharID)
	if(!thePawn):
		return
	var theDoll := thePawn.getDoll()
	if(!theDoll):
		return
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(notifyDollTypingStatus_RPC.bind(theDoll.uniqueID, _status))
	theDoll.pushTypingStatus(_status)

@rpc("authority", "call_remote", "unreliable")
func notifyDollTypingStatus_RPC(_dollID:int, _status:int):
	var theDoll := GM.dollHolder.findDollWithUniqueID(_dollID)
	if(!theDoll):
		return
	theDoll.pushTypingStatus(_status)

@rpc("authority", "call_remote", "unreliable")
func notifyDollResetTypingStatus_RPC(_dollID:int):
	var theDoll := GM.dollHolder.findDollWithUniqueID(_dollID)
	if(!theDoll):
		return
	theDoll.resetTypingStatus()

func askChatSend(_text:String):
	if(Network.isClient()):
		askChatSend_ServerRPC.rpc_id(1, _text)
		return
	handleChatSend(Network.getMyPlayerInfo(), _text)

func sendChatGlobal(_text:String):
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(sendChat_RPC.bind(_text))
	sendChat_RPC(_text)
	
@rpc("authority", "call_remote", "reliable")
func sendChat_RPC(_text:String):
	GameChat.addChat(_text)

func askUpdateInteractor(_interactor:PawnInteractor):
	if(Network.isServer()):
		_interactor.updateInteractor()
	else:
		askUpdateInteractor_SERVER.rpc_id(1, _interactor.pawn.getCharID())

@rpc("any_peer", "call_remote", "reliable")
func askUpdateInteractor_SERVER(_pawnID:String):
	var thePawn:CharacterPawn = pawnRegistry.getPawn(_pawnID)
	if(!thePawn):
		return
	var theInteractor := thePawn.getPawnInteractor()
	theInteractor.updateInteractor()
	
	#await get_tree().create_timer(1.0).timeout
	Network.rpcClients(askUpdateInteractor_RPC.bind(_pawnID, theInteractor.saveCategoriesData().getBytesCompressedSimple()))

@rpc("authority", "call_remote", "reliable")
func askUpdateInteractor_RPC(_pawnID:String, _data:PackedByteArray):
	var thePawn:CharacterPawn = pawnRegistry.getPawn(_pawnID)
	if(!thePawn):
		return
	var theBins := Bins.readCompressedSimple(_data)
	thePawn.getPawnInteractor().loadCategoriesData(theBins)

func makePawnOpenInteractMenuSpecific(_pawn:CharacterPawn, _target:Node3D):
	if(_pawn.isControlledByUs()):
		GM.main.showInteractMenuSpecific(_target)
		return
	if(Network.isServerNotSingleplayer()):
		var theInfo := Network.getPlayerInfoControllingCharID(_pawn.getCharID())
		if(!theInfo):
			return
		#Log.Print(str(theInfo.id))
		makePawnOpenInteractMenuSpecific_RPC.rpc_id(theInfo.id, getUniqueIDOf(_target))
		return

@rpc("authority", "call_remote", "reliable")
func makePawnOpenInteractMenuSpecific_RPC(_targetAr:Array):
	var _target:Node3D = getNodeByUniqueID(_targetAr)
	if(!_target):
		return
	#print(_target is CharacterPawn)
	GM.main.showInteractMenuSpecific(_target)

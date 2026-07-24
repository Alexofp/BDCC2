extends Node

# Errors
#const OK = 0
const ERROR_GENERIC = 1

const SERVER_PORT = 12345
const SERVER_ADDRESS: String = "127.0.0.1"
const MAX_PLAYERS : int = 32

var players:Dictionary[int, NetworkPlayerInfo]
var playerControlsCharID:Dictionary[int, String]
var charIDControlledByPlayer:Dictionary[String, int]

signal playerConnected(peer_id, player_info)
signal playerDisconnected(peer_id, player_info)
signal playerListUpdated
signal serverDisconnected

signal playerSwitchedCharacter(playerID:int, oldCharID:String, newCharID:String)
signal localPlayerSwitchedCharacter(oldCharID:String, newCharID:String)

signal preMultiplayerStarted(isHost:bool)
signal multiplayerStarted(isHost:bool)
signal multiplayerEnded(isHost:bool)

var networkPlayerInfoScene := preload("res://Game/Multiplayer/NetworkPlayerInfo.tscn")

var roomID:String = ""
signal roomIDChanged(newRoomID:String)

var connector:ConnectorNetworkBase

func host(_connector:ConnectorNetworkBase) -> FuncResultOrError:
	stopMultiplayer()
	connector = _connector
	if(!connector):
		return null
		
	preMultiplayerStarted.emit(true)
		
	add_child(connector)
	var theRes := await connector.doHost()
	if(theRes.isError()):
		return theRes
	
	multiplayerStarted.emit(true)
	return theRes

func join(_connector:ConnectorNetworkBase) -> FuncResultOrError:
	stopMultiplayer()
	connector = _connector
	if(!connector):
		return null
		
	#preMultiplayerStarted.emit(false)
		
	add_child(connector)
	var theRes := await connector.doJoin()
	if(theRes.isError()):
		return theRes
	
	#multiplayerStarted.emit(true)
	return theRes

func stopMultiplayer():
	if(connector):
		roomID = ""
		roomIDChanged.emit(roomID)
		connector.stopMultiplayer()
		connector.queue_free()
		connector = null
		#NetworkTime.stop()
	if(!isMultiplayer()):
		return
	multiplayerEnded.emit(isServer())
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	#players.clear()
	serverDisconnected.emit()

func setMyNickname(newName:String):
	var myInfo:NetworkPlayerInfo = getMyPlayerInfo()
	if(myInfo):
		myInfo.nickname = newName
		#TODO: Sync it with the server

func createPlayerInfo(theId:int, theNickname:String) -> NetworkPlayerInfo:
	var info:NetworkPlayerInfo = networkPlayerInfoScene.instantiate()
	info.id = theId
	info.nickname = theNickname
	return info
	
@rpc("authority", "call_remote", "reliable")
func registerPlayerInfo_RPC(theBytes:PackedByteArray):
	var theBins := Bins.readUncompressed(theBytes)
	#Log.Print("registerPlayerInfo_RPC "+str(theInfo))
	var info:NetworkPlayerInfo = networkPlayerInfoScene.instantiate()
	info.loadNetworkData(theBins)
	Log.Print("registerPlayerInfo_RPC id="+str(info.id)+" NAME="+str(info.nickname))
	registerPlayerInfo(info)

func registerPlayerInfo(info:NetworkPlayerInfo, isConnect:bool = true):
	players[info.id] = info
	#info.name = str(info.id)
	info.tree_exiting.connect(playerInfoDeletedHandle.bind(info))
	add_child(info)
	info.name = str(info.id)
	
	if(isServerNotSingleplayer()):
		rpcClients(registerPlayerInfo_RPC.bind(info.saveNetworkData().getBytes()))
	
	if(isConnect):
		playerConnected.emit(info.id, info)
		playerListUpdated.emit()

@rpc("authority", "call_remote", "reliable")
func deletePlayerInfoByID_RPC(theID:int):
	deletePlayerInfoByID(theID)

func deletePlayerInfoByID(theID:int, isDisconnect:bool = true):
	if(!players.has(theID)):
		return
	var theData:NetworkPlayerInfo = players[theID]
	players[theID].queue_free()
	theData.name = "ToBeDeletedPlayerInfo"
	players.erase(theID)

	if(isServerNotSingleplayer()):
		rpcClients(deletePlayerInfoByID_RPC.bind(theID))

	if(isDisconnect):
		Log.Print("Player disconnected: id="+str(theID)+", name="+(str(theData.nickname) if theData else "ERROR"))
		
		if(theData):
			playerDisconnected.emit(theID, theData)
			playerListUpdated.emit()
		else:
			Log.Printerr("TRIED TO ERASE A PLAYER THAT WASN'T IN OUR PLAYER LIST")

func playerInfoDeletedHandle(theInfo:NetworkPlayerInfo):
	if(theInfo.is_inside_tree()):
		theInfo.name = "TO_BE_DELETED"
	var theID:int = theInfo.id
	controlFreePlayerID(theID)
	players.erase(theID)

func getMyPlayerInfo() -> NetworkPlayerInfo:
	var theID :int = getMultiplayerID()
	if(!players.has(theID)):
		#assert(false, "NO PLAYER INFO FOUND, ID="+str(theID))
		return null
	return players[theID]

func getMyCharID() -> String:
	var theInfo := getMyPlayerInfo()
	if(!theInfo):
		return ""
	return theInfo.charID

func getSenderPlayerInfo() -> NetworkPlayerInfo:
	var theID :int = getSenderID()
	if(!players.has(theID)):
		#assert(false, "NO PLAYER INFO FOUND, ID="+str(theID))
		return null
	return players[theID]

func getRPCPlayerInfo() -> NetworkPlayerInfo:
	var theID :int = getSenderID()
	if(!players.has(theID)):
		#assert(false, "NO PLAYER INFO FOUND, ID="+str(theID))
		return null
	return players[theID]

func getPlayerInfoControllingCharID(_charID:String) -> NetworkPlayerInfo:
	if(!charIDControlledByPlayer.has(_charID)):
		return null
	var thePid:int = charIDControlledByPlayer[_charID]
	if(!players.has(thePid)):
		return null
	return players[thePid]

func getControlledCharIDOfPlayerID(_pid:int) -> String:
	if(!playerControlsCharID.has(_pid)):
		return ""
	return playerControlsCharID[_pid]

func getCharIDOfPlayer(_info:NetworkPlayerInfo) -> String:
	if(!_info):
		return ""
	var thePid:int = _info.id
	if(!playerControlsCharID.has(thePid)):
		return ""
	return playerControlsCharID[thePid]

func getPlayerIDWhoControls(_charID:String) -> int:
	if(!charIDControlledByPlayer.has(_charID)):
		return -1
	return charIDControlledByPlayer[_charID]

func controlFreePlayerID(_pid:int):
	if(_pid < 0):
		return
	if(!playerControlsCharID.has(_pid)):
		return
	var curInfo:NetworkPlayerInfo = players[_pid] if players.has(_pid) else null
	var curCharID:String = playerControlsCharID[_pid]
	
	if(charIDControlledByPlayer.has(curCharID)):
		charIDControlledByPlayer.erase(curCharID)
	playerControlsCharID.erase(_pid)
	
	if(curInfo):
		notifyPlayerSwitchedCharacter(curInfo, curCharID, "")
	
	if(isServerNotSingleplayer()):
		rpcClients(controlFreePlayerID_RPC.bind(_pid))

@rpc("authority", "call_remote", "reliable")
func controlFreePlayerID_RPC(_pid:int):
	controlFreePlayerID(_pid)

func controlFreeCharID(_charID:String):
	if(_charID.is_empty()):
		return
	if(!charIDControlledByPlayer.has(_charID)):
		return
	var _pid:int = charIDControlledByPlayer[_charID]
	controlFreePlayerID(_pid)

func setControlledCharID(_pid:int, _charID:String):
	if(_pid < 0 && _charID.is_empty()):
		return
	if(playerControlsCharID.has(_pid) && playerControlsCharID[_pid] == _charID):
		return
	
	controlFreePlayerID(_pid)
	controlFreeCharID(_charID)
	
	if(players.has(_pid) && !_charID.is_empty()):
		var curInfo := players[_pid]
		var curID:String = playerControlsCharID[_pid] if playerControlsCharID.has(_pid) else ""
		playerControlsCharID[_pid] = _charID
		charIDControlledByPlayer[_charID] = _pid
		if(curInfo):
			notifyPlayerSwitchedCharacter(curInfo, curID, _charID)
	
	if(isServerNotSingleplayer()):
		rpcClients(setControlledCharID_RPC.bind(_pid, _charID))

@rpc("authority", "call_remote", "reliable")
func setControlledCharID_RPC(_pid:int, _charID:String):
	setControlledCharID(_pid, _charID)

func saveNetworkData() -> Bins:
	var data := Bins.saveStart([
		Bins.I32, players.size(),
	])
	for playerID in players:
		var info:NetworkPlayerInfo = players[playerID]
		data.append(info.saveNetworkData())
	
	var ar:Array = [
		Bins.U16, playerControlsCharID.size(),
	]
	for pid in playerControlsCharID:
		ar.append_array([
			Bins.I64, pid,
			Bins.StrShort, playerControlsCharID[pid],
		])
	data.append(Bins.saveStartEnd(ar))
	
	return data.endSave()

func loadNetworkData(_data:Bins):
	_data.loadStart()
	clearPlayers()
	var playersSize:int = _data.readI32()
	
	for _i in playersSize:
		var info:NetworkPlayerInfo = networkPlayerInfoScene.instantiate()
		info.loadNetworkData(_data)
		Log.Print("registerPlayerInfo_RPC id="+str(info.id)+" NAME="+str(info.nickname))
		registerPlayerInfo(info)
	
	playerControlsCharID.clear()
	charIDControlledByPlayer.clear()
	_data.loadStart()
	var controlAm:int = _data.readU16()
	for _i in controlAm:
		var thePid:int = _data.readI64()
		var theCharID:String = _data.readStrShort()
		#var theEntity:Node = GI.getNodeByUniqueID(theEnAr)
		
		setControlledCharID(thePid, theCharID)
	_data.endLoad()
	
	_data.endLoad()

func saveData() -> Dictionary:
	var playerData:Dictionary = {}
	for playerID in players:
		var info:NetworkPlayerInfo = players[playerID]
		playerData[playerID] = info.saveData()
	return {
		players = playerData,
		playerControlsCharID = playerControlsCharID,
		charIDControlledByPlayer = charIDControlledByPlayer,
	}

func clearPlayers():
	for playerID in players.keys():
		deletePlayerInfoByID(playerID)
	players = {}

func loadData(_data:Dictionary):
	clearPlayers()
	
	var playerData:Dictionary = SAVE.loadVar(_data, "players", {})
	for playerID in playerData:
		var info:NetworkPlayerInfo = networkPlayerInfoScene.instantiate()
		info.loadData(playerData[playerID] if (playerData[playerID] is Dictionary) else {})
		Log.Print("registerPlayerInfo_RPC id="+str(info.id)+" NAME="+str(info.nickname))
		registerPlayerInfo(info)
	
	playerControlsCharID = SAVE.loadVar(_data, "playerControlsCharID", {})
	charIDControlledByPlayer = SAVE.loadVar(_data, "charIDControlledByPlayer", {})

@rpc("authority", "call_remote", "reliable")
func applyJoinGameNetworkData(_bytes:PackedByteArray):
	var _data:Bins = Bins.readCompressedSimple(_bytes)
	#_data.loadStart()
	#Log.Print("RECEIVED PLAYERS INFO FROM "+str(multiplayer.get_remote_sender_id()))
	Log.Print("RECEIVED PLAYER DATA: "+str(_data))
	loadNetworkData(_data)
	#_data.endLoad()
	_data.makeSureComplete()
	
@rpc("authority", "call_remote", "reliable")
func notifyMultiplayerStarted():
	Log.Print("RECEIVED NOTIFY MULTIPLAYER STARTED FROM "+str(multiplayer.get_remote_sender_id()))
	

func _ready() -> void:
	var myInfo := createPlayerInfo(1, "Player")
	registerPlayerInfo(myInfo)
	
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.peer_connected.connect(_on_player_connected)

func _on_player_disconnected(id):
	if(Network.isServer()):
		deletePlayerInfoByID(id, true)

func _on_server_disconnected():
	#stopMultiplayer()
	GM.errorOutToMainMenu("Connection to server lost")

func _on_player_connected(_id):
	#_register_player.rpc_id(id, localPlayerInfo.saveNetworkData())
	pass

func getPlayersDebugStr() -> String:
	var theStuff:Dictionary = {}
	for id in players:
		var theData:NetworkPlayerInfo = players[id]
		theStuff[id] = theData.getDebugData()
	return str(theStuff)

func printDebug(theText:String):
	var prefix:String = "[Singleplayer] "
	if(isServer()):
		prefix = "[Server] "
	if(isClient()):
		var localPlayerInfo := getMyPlayerInfo()
		prefix = "[Client:"+(localPlayerInfo.nickname if localPlayerInfo else "NOT_SENT_YET")+"] "
	print(prefix+theText)

func isServer() -> bool:
	var peer := multiplayer.multiplayer_peer
	if(!peer):
		return true
	return multiplayer.is_server()
	
func isServerNotSingleplayer() -> bool:
	return isServer() && isMultiplayer()
	
func isClient() -> bool:
	return !isServer() && isMultiplayer()

func isClientOrSingleplayer() -> bool:
	return !isServer()

func getMultiplayerID() -> int:
	if(!isMultiplayer()):
		return 1
	return multiplayer.get_unique_id()

func getSenderID() -> int:
	var theSenderID:int = multiplayer.get_remote_sender_id()
	if(theSenderID <= 0):
		return getMultiplayerID()
	return theSenderID

func isMultiplayer() -> bool:
	if(!multiplayer.multiplayer_peer):
		return false
	if(multiplayer.multiplayer_peer is OfflineMultiplayerPeer):
		return false
	return true

func isHostID(_theID:int) -> bool:
	return _theID == 1

func getHostID() -> int:
	return 1

func notifyNameChanged(_info:NetworkPlayerInfo):
	playerListUpdated.emit()

func notifyPlayerSwitchedCharacter(info:NetworkPlayerInfo, oldCharID:String, newCharID:String):
	playerSwitchedCharacter.emit(info.id, oldCharID, newCharID)
	if(info.isUs()):
		localPlayerSwitchedCharacter.emit(oldCharID, newCharID)

func getPlayerInfo(_pcID:int) -> NetworkPlayerInfo:
	if(!players.has(_pcID)):
		return null
	return players[_pcID]

# This function would only send the rpc to clients that are fully connected
func rpcClients(callable:Callable, debugOutput:bool = false):
	for playerID in players:
		if(playerID == getMultiplayerID() || players[playerID].connecting):
			continue
		if(debugOutput):
			Log.Print("RPC "+str(callable)+" on "+str(playerID))
		callable.rpc_id(playerID)
			

func rpcClientsArgs(callable:Callable, args:Array = [], skipUs:bool = true):
	var theCallable:Callable = callable.bindv(args)
	for playerID in players:
		if((skipUs && playerID == getMultiplayerID()) || players[playerID].connecting):
			continue
		theCallable.rpc_id(playerID)

func sentToChat(_id:int, _text:String):
	if(_id == getMultiplayerID()):
		sendToChat_RPC(_id, _text)
	elif(isServer()):
		sendToChat_RPC.rpc_id(_id, _id, _text)

@rpc("authority", "call_remote", "reliable")
func sendToChat_RPC(_id:int, _text:String):
	GameChat.addChat(_text)

func getConnectionState() -> int:
	if(!multiplayer.multiplayer_peer):
		return MultiplayerPeer.CONNECTION_DISCONNECTED
	return multiplayer.multiplayer_peer.get_connection_status()

func clientAskGameInfo() -> FuncResultOrError:
	if(getConnectionState() != ENetMultiplayerPeer.CONNECTION_CONNECTED):
		return FuncResultOrError.createError(ERROR_GENERIC, "Connection lost")
	Log.Print("Asking for game info")
	clientAskGameInfo_SERVERRPC.rpc_id(1)
	
	var timeoutRes := await AsyncUtil.timeout(internal_clientAskGameInfo, 25.0)
	if(timeoutRes.didTimeout()):
		return FuncResultOrError.createError(ERROR_GENERIC, "Timeout while getting game info")
	var clientAskGameInfo_RESULT:FuncResultOrError = timeoutRes.getArg1()
	#await internal_clientAskGameInfo
	Log.Print("Received game info")
	return clientAskGameInfo_RESULT

@rpc("any_peer", "call_remote", "reliable")
func clientAskGameInfo_SERVERRPC():
	if(!isServer()):
		return
	Log.Print("Received ask for game info, sending it to "+str(multiplayer.get_remote_sender_id()))
	
	var gameState:Dictionary = {
		map = GM.main.mapPath,
		mode = GM.main.gameMode.id,
	}
	clientAskGameInfo_RPC.rpc_id(multiplayer.get_remote_sender_id(), gameState)

signal internal_clientAskGameInfo(res)

@rpc("authority", "call_remote", "reliable")
func clientAskGameInfo_RPC(_state:Dictionary):
	internal_clientAskGameInfo.emit(FuncResultOrError.createResult(_state))


func clientAskToJoin(_nickname:String) -> FuncResultOrError:
	if(getConnectionState() != ENetMultiplayerPeer.CONNECTION_CONNECTED):
		# Not connected
		return FuncResultOrError.createError(ERROR_GENERIC)
	
	preMultiplayerStarted.emit(false)
	clearPlayers()
	Log.Print("Asking to join with nickname "+_nickname)
	clientAskToJoin_SERVERRPC.rpc_id(1, _nickname)
	
	#await internal_clientAskToJoin
	var timeoutRes := await AsyncUtil.timeout(internal_clientAskToJoin, 30.0)
	if(timeoutRes.didTimeout()):
		return FuncResultOrError.createError(ERROR_GENERIC, "Timeout while getting full game data")
	var clientAskToJoin_RESULT:FuncResultOrError = timeoutRes.getArg1()
	
	Log.Print("Got full game data, applying")
	GI.applyFullNetworkData(Bins.readCompressedSimple(clientAskToJoin_RESULT.result))
	Log.Print("Full game data got applied")
	
	multiplayerStarted.emit(false)
	return FuncResultOrError.createResult(true)

@rpc("any_peer", "call_remote", "reliable")
func clientAskToJoin_SERVERRPC(nickname:String):
	if(!isServer()):
		return
	
	Log.Print("Received ask to join from "+str(multiplayer.get_remote_sender_id()))
	
	Log.Print("Registring new player "+str(multiplayer.get_remote_sender_id()))
	var myInfo := createPlayerInfo(multiplayer.get_remote_sender_id(), nickname)
	myInfo.connecting = true
	registerPlayerInfo(myInfo)
	
	Log.Print("Sending player list to "+str(multiplayer.get_remote_sender_id()))
	applyJoinGameNetworkData.rpc_id(multiplayer.get_remote_sender_id(), saveNetworkData().getBytesCompressedSimple())
	
	Log.Print("Sending full game data to "+str(multiplayer.get_remote_sender_id()))
	clientAskToJoin_RPC.rpc_id(multiplayer.get_remote_sender_id(), GI.saveFullNetworkData().getBytesCompressedSimple())
	
	#Log.Print("UNCOMPRESSED NEW: "+str(GI.saveFullNetworkData().getBytes().size()))
	#Log.Print("COMPRESSION NEW: "+str(GI.saveFullNetworkData().getBytesCompressedSimple().size()))
	#Log.Print("COMPRESSION OLD: "+str(var_to_bytes(GI.saveFullData()).size()))
	
	myInfo.connecting = false
	
	#GI.applyFullNetworkData.rpc_id(multiplayer.get_remote_sender_id(), GI.saveFullNetworkData())

	#notifyMultiplayerStarted.rpc_id(multiplayer.get_remote_sender_id())
	#Log.Print("SENT NOTIFY MULTIPLAYER STARTED RPC TO "+str(multiplayer.get_remote_sender_id()))

signal internal_clientAskToJoin(res)
@rpc("authority", "call_remote", "reliable")
func clientAskToJoin_RPC(_data:PackedByteArray):
	internal_clientAskToJoin.emit(FuncResultOrError.createResult(_data))
	#multiplayerStarted.emit(false)
	#GI.applyFullNetworkData(_data)
	#internal_clientAskToJoin.emit()

func hasRoomID() -> bool:
	return roomID != ""

func getRoomID() -> String:
	return roomID

func asyncCondition(cond: Callable, timeout: float = 10.0) -> Error:
	timeout = Time.get_ticks_msec() + timeout * 1000
	while not cond.call():
		await get_tree().process_frame
		if Time.get_ticks_msec() > timeout:
			return ERR_TIMEOUT
	return OK

# NODE TUNNEL
const NODETUNNEL_SERVER = "relay.nodetunnel.io"
const NODETUNNEL_PORT = 9998

func hostNodeTunnel(hostNickname:String = "host", relayServer:String = NODETUNNEL_SERVER, relayServerPort:int = NODETUNNEL_PORT) -> FuncResultOrError:
	preMultiplayerStarted.emit(true)
	setMyNickname(hostNickname)
	
	var peer := NodeTunnelPeer.new()
	multiplayer.multiplayer_peer = peer
	
	peer.connect_to_relay(relayServer, relayServerPort)
	await peer.relay_connected
	Log.Print("Node Tunnel Connected! Your ID: "+ str(peer.online_id))
	
	peer.host()
	await peer.hosting
	
	Log.Print("(Node Tunnel) Share this ID: "+str(peer.online_id))
	roomID = peer.online_id
	roomIDChanged.emit(roomID)
	
	#await get_tree().process_frame
	multiplayerStarted.emit(true)
	return FuncResultOrError.createResult(true)

func connectNodeTunnel(_hostID:String, relayServer:String = NODETUNNEL_SERVER, relayServerPort:int = NODETUNNEL_PORT) -> FuncResultOrError:
	roomID = _hostID
	roomIDChanged.emit(roomID)
	var peer := NodeTunnelPeer.new()
	multiplayer.multiplayer_peer = peer
	
	peer.connect_to_relay(relayServer, relayServerPort)
	await peer.relay_connected
	Log.Print("Node Tunnel Connected! Your ID: "+ str(peer.online_id))
	
	peer.join(_hostID)
	await peer.joined
	
	return FuncResultOrError.createResult(true)
# NODE TUNNEL END

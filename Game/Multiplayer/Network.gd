extends Node

# Errors
const OK = 0
const ERROR_GENERIC = 1

const SERVER_PORT = 12345
const SERVER_ADDRESS: String = "127.0.0.1"
const MAX_PLAYERS : int = 32

var players:Dictionary = {}

signal playerConnected(peer_id, player_info)
signal playerDisconnected(peer_id, player_info)
signal playerListUpdated
signal serverDisconnected

signal playerSwitchedCharacter(playerID, oldCharID, newCharID)
signal localPlayerSwitchedCharacter(oldCharID, newCharID)

signal preMultiplayerStarted(isHost:bool)
signal multiplayerStarted(isHost:bool)
signal multiplayerEnded(isHost:bool)

var networkPlayerInfoScene := preload("res://Game/Multiplayer/NetworkPlayerInfo.tscn")

var roomID:String = ""
signal roomIDChanged(newRoomID:String)

@rpc("any_peer", "call_remote", "reliable")
func askToJoinGame(nickname:String):
	if(!isServer()):
		return
	Log.Print("RECEIVED ASK TO JOIN FROM "+str(multiplayer.get_remote_sender_id()))
	applyJoinGameNetworkData.rpc_id(multiplayer.get_remote_sender_id(), saveNetworkData())
	Log.Print("SENT GAME JOIN NETWORK DATA TO "+str(multiplayer.get_remote_sender_id()))
	var myInfo := createPlayerInfo(multiplayer.get_remote_sender_id(), nickname)
	registerPlayerInfo(myInfo)
	
	notifyMultiplayerStarted.rpc_id(multiplayer.get_remote_sender_id())
	Log.Print("SENT NOTIFY MULTIPLAYER STARTED RPC TO "+str(multiplayer.get_remote_sender_id()))

func setMyNickname(newName:String):
	var myInfo:NetworkPlayerInfo = getMyPlayerInfo()
	if(myInfo):
		myInfo.nickname = newName
		# TODO Sync it with the server

func createPlayerInfo(theId:int, theNickname:String) -> NetworkPlayerInfo:
	var info:NetworkPlayerInfo = networkPlayerInfoScene.instantiate()
	info.id = theId
	info.nickname = theNickname
	return info
	
@rpc("authority", "call_remote", "reliable")
func registerPlayerInfo_RPC(theInfo:Dictionary):
	Log.Print("registerPlayerInfo_RPC "+str(theInfo))
	var info:NetworkPlayerInfo = networkPlayerInfoScene.instantiate()
	info.loadNetworkData(theInfo)
	registerPlayerInfo(info)

func registerPlayerInfo(info:NetworkPlayerInfo, isConnect:bool = true):
	players[info.id] = info
	#info.name = str(info.id)
	info.tree_exiting.connect(playerInfoDeletedHandle.bind(info))
	add_child(info)
	info.name = str(info.id)
	
	if(isServerNotSingleplayer()):
		rpcClients(registerPlayerInfo_RPC.bind(info.saveNetworkData()))
	
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
	players.erase(theInfo.id)

func getMyPlayerInfo() -> NetworkPlayerInfo:
	var theID :int = getMultiplayerID()
	if(!players.has(theID)):
		#assert(false, "NO PLAYER INFO FOUND, ID="+str(theID))
		return null
	return players[theID]

func getRPCPlayerInfo() -> NetworkPlayerInfo:
	var theID :int = multiplayer.get_remote_sender_id()
	if(!players.has(theID)):
		#assert(false, "NO PLAYER INFO FOUND, ID="+str(theID))
		return null
	return players[theID]

func saveNetworkData() -> Dictionary:
	var playerData:Dictionary = {}
	for playerID in players:
		var info:NetworkPlayerInfo = players[playerID]
		playerData[playerID] = info.saveNetworkData()
	return {
		players = playerData,
	}

func clearPlayers():
	for playerID in players.keys():
		deletePlayerInfoByID(playerID)
	players = {}

func loadNetworkData(_data:Dictionary):
	clearPlayers()
	
	var playerData:Dictionary = SAVE.loadVar(_data, "players", {})
	for playerID in playerData:
		registerPlayerInfo_RPC(playerData[playerID] if (playerData[playerID] is Dictionary) else {})

@rpc("authority", "call_remote", "reliable")
func applyJoinGameNetworkData(_data:Dictionary):
	#Log.Print("RECEIVED PLAYERS INFO FROM "+str(multiplayer.get_remote_sender_id()))
	Log.Print("RECEIVED PLAYER DATA: "+str(_data))
	loadNetworkData(_data)
	
@rpc("authority", "call_remote", "reliable")
func notifyMultiplayerStarted():
	Log.Print("RECEIVED NOTIFY MULTIPLAYER STARTED FROM "+str(multiplayer.get_remote_sender_id()))
	

func _ready() -> void:
	var myInfo := createPlayerInfo(1, "Player")
	registerPlayerInfo(myInfo)
	
	multiplayer.multiplayer_peer = null
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connection_failed)
	

func canHostOrJoin() -> bool:
	return !!multiplayer.multiplayer_peer

var internal_connectResult:FuncResultOrError
signal internal_onConnectOrFail

func _on_connection_failed():
	internal_connectResult = FuncResultOrError.createError(1)
	internal_onConnectOrFail.emit()
	pass

func _on_connected_ok():
	internal_connectResult = FuncResultOrError.createResult(true)
	internal_onConnectOrFail.emit()
	pass

func _on_player_connected(_id):
	#_register_player.rpc_id(id, localPlayerInfo.saveNetworkData())
	pass

@rpc("any_peer", "reliable")
func _register_player(new_player_info:Dictionary):
	var new_player_id:int = multiplayer.get_remote_sender_id()
	var theInfo:NetworkPlayerInfo = NetworkPlayerInfo.new()
	theInfo.loadNetworkData(new_player_info)
	theInfo.id = new_player_id
	players[new_player_id] = theInfo
	playerConnected.emit(new_player_id, theInfo)
	playerListUpdated.emit()
	printDebug("debug function _register_player on Network.gd: "+ str(getPlayersDebugStr()))

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

func _on_player_disconnected(id):
	if(Network.isServer()):
		deletePlayerInfoByID(id, true)

func _on_server_disconnected():
	#stopMultiplayer()
	GM.errorOutToMainMenu("Connection to server lost")

func isServer() -> bool:
	return !multiplayer.multiplayer_peer || (multiplayer.multiplayer_peer && multiplayer.is_server())
	
func isServerNotSingleplayer() -> bool:
	return !!multiplayer.multiplayer_peer && multiplayer.is_server()
	
func isClient() -> bool:
	return !!multiplayer.multiplayer_peer && !multiplayer.is_server()

func isClientOrSingleplayer() -> bool:
	return !multiplayer.multiplayer_peer || !multiplayer.is_server()

func stopMultiplayer():
	roomID = ""
	roomIDChanged.emit(roomID)
	if(!isMultiplayer()):
		return
	multiplayerEnded.emit(isServer())
	multiplayer.multiplayer_peer = null
	#players.clear()
	serverDisconnected.emit()

func getMultiplayerID() -> int:
	if(!isMultiplayer()):
		return 1
	return multiplayer.get_unique_id()

func isMultiplayer() -> bool:
	return !!multiplayer.multiplayer_peer

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

func getInfoThatControlsCharID(_charID:String) -> NetworkPlayerInfo:
	for playerID in players:
		var info:NetworkPlayerInfo = players[playerID]
		if(info.charID == _charID):
			return info
	return null

# TODO will probably have to replace all rpc calls with this one
# Why? .rpc() sends the rpc to all clients no matter if they are considered
# fully connected or still connecting (haven't received game data).
# This function would only send the rpc to clients that are fully connected
func rpcClients(callable:Callable):
	for playerID in players:
		if(playerID == getMultiplayerID() || players[playerID].connecting):
			continue
		callable.rpc_id(playerID)

func rpcClientsArgs(callable:Callable, args:Array = [], skipUs:bool = true):
	var theCallable:Callable = callable.bindv(args)
	for playerID in players:
		if((skipUs && playerID == getMultiplayerID()) || players[playerID].connecting):
			continue
		theCallable.rpc_id(playerID)

@rpc("authority", "call_remote", "reliable")
func sendToChat_RPC(_id:int, _text:String):
	var theInfo := getPlayerInfo(_id)
	if(theInfo):
		theInfo.sendToChat(_text)



func hostLAN(hostNickname:String = "host") -> FuncResultOrError:
	preMultiplayerStarted.emit(true)
	setMyNickname(hostNickname)
	
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(SERVER_PORT, MAX_PLAYERS)
	if error:
		Log.Printerr("Network unable to start hosting, error = "+str(error_string(error)))
		var errorText:String = error_string(error)
		if(error == ERR_ALREADY_IN_USE):
			errorText = "The multiplayer peer is already in use. Restart the game."
		elif(error == ERR_CANT_CREATE):
			errorText = "Unable to start hosting. The port "+str(SERVER_PORT)+" might already be in use by another application."
		return FuncResultOrError.createError(ERROR_GENERIC, errorText)
	multiplayer.multiplayer_peer = peer
	
	await get_tree().process_frame
	
	multiplayerStarted.emit(true)
	return FuncResultOrError.createResult(true)

func connectLAN(_ip:String) -> FuncResultOrError:
	var peer := ENetMultiplayerPeer.new()
	Log.Print("Connecting to server..")#+str(_ip)
	
	var error := peer.create_client(_ip, SERVER_PORT)
	if error:
		Log.Printerr("Network unable to start connecting, error = "+str(error_string(error)))
		return FuncResultOrError.createError(ERROR_GENERIC, error_string(error))
	multiplayer.multiplayer_peer = peer
	
	await internal_onConnectOrFail
	if(internal_connectResult.isError()):
		Log.Printerr("Network failed to connect, status = "+str(peer.get_connection_status()))
		return FuncResultOrError.createError(ERROR_GENERIC, "Connection failed")
	if(peer.get_connection_status() != ENetMultiplayerPeer.CONNECTION_CONNECTED):
		Log.Printerr("Network failed to connect, status = "+str(peer.get_connection_status()))
		return FuncResultOrError.createError(ERROR_GENERIC, "Connection failed")
	
	return FuncResultOrError.createResult(true)

func clientAskGameInfo() -> FuncResultOrError:
	if(!multiplayer.multiplayer_peer || multiplayer.multiplayer_peer.get_connection_status() != ENetMultiplayerPeer.CONNECTION_CONNECTED):
		return FuncResultOrError.createError(ERROR_GENERIC, "Connection lost")
	Log.Print("Asking for game info")
	clientAskGameInfo_SERVERRPC.rpc_id(1)
	#TODO: Some kind of timeout?
	await internal_clientAskGameInfo
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

signal internal_clientAskGameInfo
var clientAskGameInfo_RESULT:FuncResultOrError
@rpc("authority", "call_remote", "reliable")
func clientAskGameInfo_RPC(_state:Dictionary):
	clientAskGameInfo_RESULT = FuncResultOrError.createResult(_state)
	internal_clientAskGameInfo.emit()


func clientAskToJoin(_nickname:String) -> FuncResultOrError:
	if(!multiplayer.multiplayer_peer || multiplayer.multiplayer_peer.get_connection_status() != ENetMultiplayerPeer.CONNECTION_CONNECTED):
		# Not connected
		return FuncResultOrError.createError(ERROR_GENERIC)
	
	preMultiplayerStarted.emit(false)
	clearPlayers()
	Log.Print("Asking to join with nickname "+_nickname)
	clientAskToJoin_SERVERRPC.rpc_id(1, _nickname)
	
	await internal_clientAskToJoin
	
	Log.Print("Got full game data, applying")
	GameInteractor.applyFullNetworkData(clientAskToJoin_RESULT.result)
	Log.Print("Full game data got applied")
	clientAskToJoin_RESULT = null
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
	applyJoinGameNetworkData.rpc_id(multiplayer.get_remote_sender_id(), saveNetworkData())
	
	Log.Print("Sending full game data to "+str(multiplayer.get_remote_sender_id()))
	clientAskToJoin_RPC.rpc_id(multiplayer.get_remote_sender_id(), GameInteractor.saveFullNetworkData())
	
	myInfo.connecting = false
	
	#GameInteractor.applyFullNetworkData.rpc_id(multiplayer.get_remote_sender_id(), GameInteractor.saveFullNetworkData())

	#notifyMultiplayerStarted.rpc_id(multiplayer.get_remote_sender_id())
	#Log.Print("SENT NOTIFY MULTIPLAYER STARTED RPC TO "+str(multiplayer.get_remote_sender_id()))

signal internal_clientAskToJoin
var clientAskToJoin_RESULT:FuncResultOrError
@rpc("authority", "call_remote", "reliable")
func clientAskToJoin_RPC(_data:Dictionary):
	clientAskToJoin_RESULT = FuncResultOrError.createResult(_data)
	internal_clientAskToJoin.emit()
	#multiplayerStarted.emit(false)
	#GameInteractor.applyFullNetworkData(_data)
	#internal_clientAskToJoin.emit()

func hasRoomID() -> bool:
	return roomID != ""

func getRoomID() -> String:
	return roomID

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

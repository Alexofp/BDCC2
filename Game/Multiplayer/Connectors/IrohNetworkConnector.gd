extends ConnectorNetworkBase

#class AutoSomething:
#	func _init() -> void:
#		doThing()
#	func doThing():
#		print("MEOW!MEOWMEOW")
#static var test:AutoSomething = AutoSomething.new()

var roomID:String = ""
var serverPeer:IrohServer

func _init() -> void:
	id = "IrohNetworkConnector"
	Network.playerListUpdated.connect(onUpdatePlayerList)

func getName() -> String:
	return "Iroh connector"

func getListName() -> String:
	return "Internet (Iroh)"

func getHostSettings() -> Dictionary:
	return {
		maxPlayers = {
			name = "Max players",
			type = "int",
			value = maxPlayers,
		},
		password = {
			name = "Password",
			type = "string",
			value = password,
		},
	}

func getJoinSettings() -> Dictionary:
	return {
		roomID = {
			name = "Room ID",
			type = "string",
			value = roomID,
		},
		password = {
			name = "Server password",
			type = "string",
			value = password,
		},
	}

func doHost() -> FuncResultOrError:
	#preMultiplayerStarted.emit(true)
	#setMyNickname(hostNickname)
	
	var peer := IrohServer.start()
	if(!peer):
		Log.Printerr("Network unable to start hosting using Iroh")
		return FuncResultOrError.createError(ERROR_GENERIC, "Iroh error")
	multiplayer.multiplayer_peer = peer
	serverPeer = peer
	
	await get_tree().process_frame
	
	setRoomID(peer.connection_string())
	onUpdatePlayerList()
	
	return FuncResultOrError.createResult(true)

func doJoin() -> FuncResultOrError:
	Network.roomID = roomID
	var client := IrohClient.network_connect(roomID)
	if(!client):
		Log.Printerr("Network unable to start connecting using Iroh")
		return FuncResultOrError.createError(ERROR_GENERIC, "Iroh error")
	var theError:String = client.connection_error()
	if(!theError.is_empty()):
		Log.Printerr("Network unable to start connecting using Iroh: "+theError)
		return FuncResultOrError.createError(ERROR_GENERIC, "Iroh error: "+theError)
	
	multiplayer.multiplayer_peer = client
	
	var timeoutRes := await AsyncUtil.timeout(internal_onConnectOrFail, 45.0)
	if(timeoutRes.didTimeout()):
		return FuncResultOrError.createError(ERROR_GENERIC, "Connection timeout")
	var internal_connectResult:FuncResultOrError = timeoutRes.getArg1()
	
	#await internal_onConnectOrFail
	
	if(internal_connectResult.isError()):
		Log.Printerr("Network failed to connect, status = "+str(getConnectionState()))
		return FuncResultOrError.createError(ERROR_GENERIC, "Connection failed")
	if(getConnectionState() != ENetMultiplayerPeer.CONNECTION_CONNECTED):
		Log.Printerr("Network failed to connect, status = "+str(getConnectionState()))
		return FuncResultOrError.createError(ERROR_GENERIC, "Connection failed")
	
	return FuncResultOrError.createResult(true)
	
func stopMultiplayer():
	pass

func getConnectionState() -> int:
	if(!multiplayer.multiplayer_peer):
		return MultiplayerPeer.CONNECTION_DISCONNECTED
	return multiplayer.multiplayer_peer.get_connection_status()

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connection_failed)

signal internal_onConnectOrFail(res)

func _on_connection_failed():
	internal_onConnectOrFail.emit(FuncResultOrError.createError(1))
	pass

func _on_connected_ok():
	internal_onConnectOrFail.emit(FuncResultOrError.createResult(true))
	pass

func onUpdatePlayerList():
	if(Network.isServerNotSingleplayer() && serverPeer):
		serverPeer.refuse_new_connections = Network.players.size() >= maxPlayers
		#print("REFUSE: "+str(serverPeer.refuse_new_connections))

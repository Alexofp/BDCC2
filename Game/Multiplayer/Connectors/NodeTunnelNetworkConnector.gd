extends ConnectorNetworkBase

var roomID:String = ""
var serverPeer:MultiplayerPeer

const RelayServer:String = "2.27.16.181:8080"

func _init() -> void:
	id = "NodeTunnelNetworkConnector"
	Network.playerListUpdated.connect(onUpdatePlayerList)

func getName() -> String:
	return "NodeTunnel connector"

func getListName() -> String:
	return "Internet (NodeTunnel)"

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
	
	var peer := NodeTunnelPeer.new()
	var error:int = peer.connect_to_relay(RelayServer, "bdcc2")
	if(error != OK):
		var errorText:String = "Network unable to start connecting using "+id+", error = "+str(error_string(error))
		Log.Printerr(errorText)
		return FuncResultOrError.createError(ERROR_GENERIC, errorText)

	multiplayer.multiplayer_peer = peer
	var timeoutRes := await AsyncUtil.timeout(peer.authenticated, 30.0)
	if(timeoutRes.didTimeout()):
		return FuncResultOrError.createError(ERROR_GENERIC, id+" authentication timeout")
	peer.host_room(false, "")
	#if(!peer):
	#	Log.Printerr("Network unable to start hosting using NodeTunnel")
	#	return FuncResultOrError.createError(ERROR_GENERIC, "NodeTunnel error")
	serverPeer = peer
	
	var timeoutRes2 := await AsyncUtil.timeout(peer.room_connected, 30.0)
	if(timeoutRes2.didTimeout()):
		return FuncResultOrError.createError(ERROR_GENERIC, "Room join timeout")
	#await get_tree().process_frame
	
	setRoomID(peer.room_id)
	onUpdatePlayerList()
	
	return FuncResultOrError.createResult(true)

func doJoin() -> FuncResultOrError:
	Network.roomID = roomID
	var client := NodeTunnelPeer.new()
	client.connect_to_relay(RelayServer, "bdcc2")
	multiplayer.multiplayer_peer = client
	await client.authenticated
	var error:int = client.join_room(roomID)
	if(error != OK):
		var errorText:String = "Network unable to start connecting using "+id+", error = "+str(error_string(error))
		Log.Printerr(errorText)
		return FuncResultOrError.createError(ERROR_GENERIC, errorText)
	
	var timeoutRes2 := await AsyncUtil.timeout(client.room_connected, 30.0)
	if(timeoutRes2.didTimeout()):
		return FuncResultOrError.createError(ERROR_GENERIC, "Room join timeout")
	
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

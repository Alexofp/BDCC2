extends ConnectorNetworkBase
class_name LANNetworkConnector

const DEFAULT_IP := "127.0.0.1"
const DEFAULT_PORT := 12345

var ip:String = DEFAULT_IP
var port:int = DEFAULT_PORT

func setJoinIPAndPortFromString(_ip:String):
	var theSplit := _ip.split(":", false, 1)
	if(theSplit.size() == 1):
		ip = theSplit[0]
		port = DEFAULT_PORT
	if(theSplit.size() == 2):
		ip = theSplit[0]
		port = int(theSplit[1])

func setJoinIP(_ip:String, _port:int):
	ip = _ip
	port = _port

func setHostPort(_port:int):
	ip = "0.0.0.0"
	port = _port

func doHost() -> FuncResultOrError:
	#preMultiplayerStarted.emit(true)
	#setMyNickname(hostNickname)
	
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port, Network.MAX_PLAYERS)
	if error:
		Log.Printerr("Network unable to start hosting, error = "+str(error_string(error)))
		var errorText:String = error_string(error)
		if(error == ERR_ALREADY_IN_USE):
			errorText = "The multiplayer peer is already in use. Restart the game."
		elif(error == ERR_CANT_CREATE):
			errorText = "Unable to start hosting. The port "+str(port)+" might already be in use by another application."
		return FuncResultOrError.createError(ERROR_GENERIC, errorText)
	multiplayer.multiplayer_peer = peer
	
	await get_tree().process_frame
	
	#multiplayerStarted.emit(true)
	return FuncResultOrError.createResult(true)

func doJoin() -> FuncResultOrError:
	var peer := ENetMultiplayerPeer.new()
	Log.Print("Connecting to server..")#+str(_ip)
	
	var error := peer.create_client(ip, port)
	if error:
		Log.Printerr("Network unable to start connecting, error = "+str(error_string(error)))
		return FuncResultOrError.createError(ERROR_GENERIC, error_string(error))
	multiplayer.multiplayer_peer = peer
	
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

extends ConnectorNetworkBase
class_name NorayNetworkConnector

const NORAY_SERVER = "2.27.16.181"#"tomfol.io"
const NORAY_PORT = 8890

const NORAY_SERVERS = [
	"2.27.16.181:8890",
	"tomfol.io:8890",
]

enum NorayRole { NONE, HOST, CLIENT }
var norayRole := NorayRole.NONE

var relayServer:String = NORAY_SERVER
var relayServerPort:int = NORAY_PORT
var forceRelay:bool = false

func requiresRelayServer() -> bool:
	return true

func getRelayServerList() -> Array[String]:
	return NORAY_SERVERS

func setRelay(_ip:String, _port:int, _force:bool = false):
	assert(norayRole == NorayRole.NONE, "Can't change relay while connected")
	relayServer = _ip
	relayServerPort = _port
	forceRelay = _force

func stopMultiplayer():
	norayRole = NorayRole.NONE
	if(Noray.is_connected_to_host()):
		Noray.disconnect_from_host()

func doJoin() -> FuncResultOrError:
	registerNoraySignals()
	norayRole = NorayRole.CLIENT
	#roomID = _hostID
	#roomIDChanged.emit(roomID)
	
	var errorBig := await norayPrepare()
	if(errorBig.isError()):
		return errorBig
	
	assert(!Network.roomID.is_empty(), "Trying to use an EMPTY room id")
	if(forceRelay):
		Noray.connect_relay(Network.roomID)
	else:
		Noray.connect_nat(Network.roomID)
	
	var norayRes := await AsyncUtil.timeout(internal_norayConnectedOrFailed, 45.0)
	if(norayRes.didTimeout()):
		return FuncResultOrError.createError(ERROR_GENERIC, "Timeout while connecting to the server")
	var norayConnectedOrFailed_RESULT:FuncResultOrError = norayRes.getArg1()
	
	#await internal_norayConnectedOrFailed
	if(norayConnectedOrFailed_RESULT.isError()):
		return norayConnectedOrFailed_RESULT
	return FuncResultOrError.createResult(true)
	
signal internal_norayConnectedOrFailed(res)

func doHost() -> FuncResultOrError:
	registerNoraySignals()
	norayRole = NorayRole.HOST
	#preMultiplayerStarted.emit(true)
	#setMyNickname(hostNickname)
	
	var errorBig := await norayPrepare()
	if(errorBig.isError()):
		return errorBig
	
	var port := Noray.local_port
	Log.Print("Starting host on port " + str(port))
	
	var peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(port)
	if(error != OK):
		var errorText:String = "Failed to listen on "+str(port)+" port, error = "+str(error_string(error))
		Log.Printerr(errorText)
		return FuncResultOrError.createError(ERROR_GENERIC, errorText)
	
	get_tree().get_multiplayer().multiplayer_peer = peer
	Log.Print("Listening on port " + str(port))
	
	while peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		await get_tree().process_frame
	
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		var errorText:String = "Failed to start server!"
		Log.Printerr(errorText)
		return FuncResultOrError.createError(ERROR_GENERIC, errorText)
	
	get_tree().get_multiplayer().server_relay = true
	
	setRoomID(Noray.oid)
	
	return FuncResultOrError.createResult(true)

func registerNoraySignals():
	Noray.on_oid.connect(func(oid):
		Log.Print("OID = "+str(oid)))
	Noray.on_connect_nat.connect(norayHandleConnectNat)
	Noray.on_connect_relay.connect(norayHandleConnectRelay)

# connect_to_noray() function from the noray-bootstrapper.gd basically
func norayPrepare() -> FuncResultOrError:
	Noray.process_mode = Node.PROCESS_MODE_ALWAYS
	PacketHandshake.process_mode = Node.PROCESS_MODE_ALWAYS

	var error = await Noray.connect_to_host(relayServer, relayServerPort)
	if(error != OK):
		var errorText:String = "Failed to connect to Noray, error = "+str(error_string(error))
		Log.Printerr(errorText)
		return FuncResultOrError.createError(ERROR_GENERIC, errorText)

	Noray.register_host()
	var theResult := await AsyncUtil.timeout(Noray.on_pid, 25.0)
	if(theResult.didTimeout()):
		var errorText:String = "Failed to connect to Noray, timeout while getting PID"
		Log.Printerr(errorText)
		return FuncResultOrError.createError(ERROR_GENERIC, errorText)

	error = await Noray.register_remote()
	if(error != OK):
		var errorText:String = "Failed to register remote address, error = "+str(error_string(error))
		Log.Printerr(errorText)
		return FuncResultOrError.createError(ERROR_GENERIC, errorText)
	
	Log.Print("Registered local port: " + str(Noray.local_port))
	return FuncResultOrError.createResult(true)



func norayHandleConnectNat(address: String, port: int) -> Error:
	var err := await norayHandleConnect(address, port)

	# If client failed to connect over NAT, try again over relay
	if err != OK and norayRole != NorayRole.HOST:
		Log.Print("NAT connect failed with reason %s, retrying with relay" % error_string(err))
		Noray.connect_relay(Network.roomID)
		err = OK
		return err

	internal_norayConnectedOrFailed.emit(FuncResultOrError.createResult(true))

	return err

func norayHandleConnectRelay(address: String, port: int) -> Error:
	var err := await norayHandleConnect(address, port)
	
	if err != OK:
		internal_norayConnectedOrFailed.emit(FuncResultOrError.createError(ERROR_GENERIC, "Failed to connect"))
	else:
		internal_norayConnectedOrFailed.emit(FuncResultOrError.createResult(true))
	
	return err

func norayHandleConnect(address: String, port: int) -> Error:
	if not Noray.local_port:
		return ERR_UNCONFIGURED

	var err := OK
	
	if norayRole == NorayRole.NONE:
		Log.warning("Refusing connection, not running as client nor host")
		err = ERR_UNAVAILABLE
	
	if norayRole == NorayRole.CLIENT:
		var udp = PacketPeerUDP.new()
		udp.bind(Noray.local_port)
		udp.set_dest_address(address, port)
		
		Log.Print("Attempting handshake with %s:%s" % [address, port])
		err = await PacketHandshake.over_packet_peer(udp)
		udp.close()
		
		if err != OK:
			if err == ERR_BUSY:
				Log.Print("Handshake to %s:%s succeeded partially, attempting connection anyway" % [address, port])
			else:
				Log.Print("Handshake to %s:%s failed: %s" % [address, port, error_string(err)])
				return err
		else:
			Log.Print("Handshake to %s:%s succeeded" % [address, port])

		# Connect
		var peer = ENetMultiplayerPeer.new()
		err = peer.create_client(address, port, 0, 0, 0, Noray.local_port)
		if err != OK:
			Log.Print("Failed to create client: %s" % error_string(err))
			return err

		get_tree().get_multiplayer().multiplayer_peer = peer
		
		# Wait for connection to succeed
		await asyncCondition(
			func(): return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
		)
			
		if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
			Log.Print("Failed to connect to %s:%s with status %s" % [address, port, peer.get_connection_status()])
			get_tree().get_multiplayer().multiplayer_peer = null
			return ERR_CANT_CONNECT
		
		#connect_ui.hide()
		# NOTE: This is not needed when using NetworkEvents
		# However, this script also runs in multiplayer-simple where NetworkEvents
		# are assumed to be absent, hence starting NetworkTime manually
		#NetworkTime.start()

	if norayRole == NorayRole.HOST:
		# We should already have the connection configured, only thing to do is a handshake
		var peer = get_tree().get_multiplayer().multiplayer_peer as ENetMultiplayerPeer
		
		err = await PacketHandshake.over_enet_peer(peer, address, port)
		
		if err != OK:
			Log.Print("Handshake to %s:%s failed: %s" % [address, port, error_string(err)])
			return err
		Log.Print("Handshake to %s:%s concluded" % [address, port])

	return err

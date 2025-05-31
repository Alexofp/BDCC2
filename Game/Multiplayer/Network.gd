extends Node

const SERVER_PORT = 12345
const SERVER_ADDRESS: String = "127.0.0.1"
const MAX_PLAYERS : int = 32

const NORAY_ADDRESS = "tomfol.io"
const NORAY_PORT = 8890

var players:Dictionary = {}

signal noray_connected

signal playerConnected(peer_id, player_info)
signal playerDisconnected(peer_id, player_info)
signal playerListUpdated
signal serverDisconnected

signal playerSwitchedCharacter(playerID, oldCharID, newCharID)
signal localPlayerSwitchedCharacter(oldCharID, newCharID)


#signal preMultiplayerStarted(isHost)
signal multiplayerStarted(isHost)
signal multiplayerEnded(isHost)

var is_host:bool = false

var networkPlayerInfoScene := preload("res://Game/Multiplayer/NetworkPlayerInfo.tscn")

enum {
	STATE_SINGLEPLAYER,
	STATE_HOST,
	STATE_HOST_NORAY,
	STATE_CONNECTING,
	STATE_CONNECTED,
	STATE_CONNECTED_NORAY,
	STATE_CONNECTING_NAT,
	STATE_CONNECTING_RELAY,
}
const STATE_NAMES := [
	"STATE_SINGLEPLAYER",
	"STATE_HOST",
	"STATE_HOST_NORAY",
	"STATE_CONNECTING",
	"STATE_CONNECTED",
	"STATE_CONNECTED_NORAY",
	"STATE_CONNECTING_NAT",
	"STATE_CONNECTING_RELAY",
]

var state :int= STATE_SINGLEPLAYER

enum {
	TARGET_NOTHING = 100,
	TARGET_SINGLEPLAYER,
	TARGET_HOST,
	TARGET_HOST_NORAY,
	TARGET_CONNECTED,
	TARGET_CONNECTED_NORAY,
}

var targetState :int= TARGET_SINGLEPLAYER
var targetPort:int = 0
var targetIP:String = ""
var targetOID:String = ""
var targetNickname:String = "Player"

enum {
	NORAY_DISCONNECTED,
	NORAY_CONNECTING,
	NORAY_CONNECTED,
	NORAY_FAILED,
}
var norayState :int= NORAY_DISCONNECTED

signal stateChanged(newState)
signal stateReached(newState) # Only gets called for 'main' states. STATE_SINGLEPLAYER, STATE_HOST, STATE_CONNECTED

enum {
	ACTION_PROCEED,
	ACTION_CONNECTION_FAILED,
	ACTION_CONNECTED_TO_SERVER,
	#ACTION_NORAY_HANDSHAKE_SUCCESS,
	#ACTION_NORAY_CONNECTED,
}

func hasAchievedTargetState() -> bool:
	if(targetState == TARGET_NOTHING):
		return true
	if(targetState == TARGET_SINGLEPLAYER && state == STATE_SINGLEPLAYER):
		return true
	if(targetState == TARGET_HOST && state == STATE_HOST):
		return true
	if(targetState == TARGET_CONNECTED && state == STATE_CONNECTED):
		return true
	
	return false

func _process(_delta: float) -> void:
	doProcessStateMachine.call_deferred(ACTION_PROCEED)

func setState(newST:int):
	if(newST >= 100):
		assert(false, "BAD STATE ("+str(newST)+"), MAKE SURE YOU'RE NOT USING TARGET_XXX inside setState()")
		return
	state = newST
	Log.Print("NEW NETWORK STATE: "+str(STATE_NAMES[state] if state<STATE_NAMES.size() else str(state)))
	stateChanged.emit(state)

func setNorayState(newST:int):
	norayState = newST

func doProcessStateMachine(action:int, _args:Array = []) -> bool:
	if(hasAchievedTargetState()):
		return true
		
	if(action == ACTION_PROCEED):
		if(state == STATE_CONNECTING_NAT):
			return true
		if(state == STATE_CONNECTING_RELAY):
			return true
		
		if(state == STATE_SINGLEPLAYER && targetState == TARGET_HOST):
			var peer := ENetMultiplayerPeer.new()
			var error := peer.create_server(targetPort, MAX_PLAYERS)
			if error:
				Log.Printerr("Network unable to start hosting, error = "+str(error_string(error)))
				
				# Failed, go back to singleplayer
				targetState = TARGET_SINGLEPLAYER
				setState(STATE_SINGLEPLAYER)
				stateReached.emit(state)
				return true
			multiplayer.multiplayer_peer = peer
			
			setState(STATE_HOST)
			multiplayerStarted.emit(true)
			
			#for playerID in players:
			#	playerConnected.emit(playerID, players[playerID])
			
			# Reached target state
			stateReached.emit(state)
			return true
			
		if(state == STATE_SINGLEPLAYER && targetState == TARGET_CONNECTED):
			var peer := ENetMultiplayerPeer.new()
			Log.Print("Connecting to "+str(targetIP))
			var error := peer.create_client(targetIP, targetPort)
			if error:
				Log.Printerr("Network unable to start connecting, error = "+str(error_string(error)))
				
				# Failed, go back to singleplayer
				targetState = TARGET_SINGLEPLAYER
				setState(STATE_SINGLEPLAYER)
				stateReached.emit(state)
				return true

			multiplayer.multiplayer_peer = peer
			if(targetNickname == ""):
				targetNickname = "Player_" + str(multiplayer.get_unique_id())
			
			setState(STATE_CONNECTING)
			return true
		
		if(state == STATE_CONNECTING && targetState == TARGET_CONNECTED):
			return true
	
		if(targetState == TARGET_CONNECTED_NORAY || targetState == TARGET_HOST_NORAY):
			if(norayState == NORAY_DISCONNECTED):
				setNorayState(NORAY_CONNECTING)
				Noray.connect_to_host(NORAY_ADDRESS, NORAY_PORT)
				return true
		
		if(targetState == TARGET_CONNECTED_NORAY || targetState == TARGET_HOST_NORAY):
			if(norayState == NORAY_FAILED):
				Log.Printerr("Network failed to connect to NORAY")
				
				# Failed, go back to singleplayer
				targetState = TARGET_SINGLEPLAYER
				setState(STATE_SINGLEPLAYER)
				stateReached.emit(state)
				return true
		
		if(state == STATE_SINGLEPLAYER && targetState == TARGET_CONNECTED_NORAY):
			if(norayState != NORAY_CONNECTED):
				return true
			
			# Noray is connected

			#localPlayerInfo = NetworkPlayerInfo.new()
			#localPlayerInfo.nickname = _nickname
			#join(oid)
			setState(STATE_CONNECTING_NAT)
			Noray.connect_nat(targetOID)
			return true
		
		
		if(state == STATE_SINGLEPLAYER && targetState == TARGET_HOST_NORAY):
			if(norayState != NORAY_CONNECTED):
				return true
			
			var peer := ENetMultiplayerPeer.new()
			var error := peer.create_server(Noray.local_port, MAX_PLAYERS)
			if error:
				Log.Printerr("Network unable to start hosting, error = "+str(error_string(error)))
				
				# Failed, go back to singleplayer
				targetState = TARGET_SINGLEPLAYER
				setState(STATE_SINGLEPLAYER)
				stateReached.emit(state)
				return true
			multiplayer.multiplayer_peer = peer
			
			setState(STATE_HOST_NORAY)
			multiplayerStarted.emit(true)
			
			#for playerID in players:
			#	playerConnected.emit(playerID, players[playerID])
			
			# Reached target state
			stateReached.emit(state)
			return true
			
	
	if(action == ACTION_CONNECTION_FAILED):
		if(state == STATE_CONNECTING):
			Log.Printerr("Network failed to connect.")
			multiplayer.multiplayer_peer = null
			
			# Failed, go back to singleplayer
			targetState = TARGET_SINGLEPLAYER
			setState(STATE_SINGLEPLAYER)
			stateReached.emit(state)
			return true
	
	if(action == ACTION_CONNECTED_TO_SERVER):
		if(state == STATE_CONNECTING || state == STATE_CONNECTING_NAT || state == STATE_CONNECTING_RELAY):
			if(state == STATE_CONNECTING):
				setState(STATE_CONNECTED)
			else:
				setState(STATE_CONNECTED_NORAY)
			
			clearPlayers()
			multiplayerStarted.emit(false)
			#var myInfo := createPlayerInfo(getMultiplayerID(), targetNickname)
			#registerPlayerInfo(myInfo)
			
			askToJoinGame.rpc_id(1, targetNickname)
			
			# Reached target state
			stateReached.emit(state)
			return true
	
		
	
	assert("UNSUPPORTED STATE AND ACTION. STATE="+str(state)+" TARGET_STATE="+str(targetState)+" ACTION="+str(action))
	return false

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

func joinGame(nickname: String, address: String = SERVER_ADDRESS):
	if(state != STATE_SINGLEPLAYER):
		assert(false, "WRONG STATE TO START JOINING")
		return
	
	targetState = TARGET_CONNECTED
	targetIP = address
	targetPort = SERVER_PORT
	targetNickname = nickname
	
	doProcessStateMachine(ACTION_PROCEED)
	
func joinGameNORAY(_nickname:String, oid:String):
	if(state != STATE_SINGLEPLAYER):
		assert(false, "WRONG STATE TO START JOINING")
		return
	
	targetState = TARGET_CONNECTED_NORAY
	targetOID = oid
	targetPort = SERVER_PORT
	targetNickname = _nickname
	is_host = false
	
	doProcessStateMachine(ACTION_PROCEED)
	
	


#func startHost(hostNickname:String = "host", useNoray:bool = true):
func startHost(hostNickname:String = "host"):
	if(state != STATE_SINGLEPLAYER):
		assert(false, "WRONG STATE TO START HOSTING")
		return
	
	targetState = TARGET_HOST
	targetPort = SERVER_PORT
	targetNickname = hostNickname
	setMyNickname(hostNickname)
	
	doProcessStateMachine(ACTION_PROCEED)

func startHostNORAY(hostNickname:String = "host"):
	if(state != STATE_SINGLEPLAYER):
		assert(false, "WRONG STATE TO START HOSTING")
		return
	
	targetState = TARGET_HOST_NORAY
	targetPort = SERVER_PORT
	targetNickname = hostNickname
	is_host = true
	setMyNickname(hostNickname)
	
	doProcessStateMachine(ACTION_PROCEED)


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
		registerPlayerInfo_RPC.rpc(info.saveNetworkData())
	
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
		deletePlayerInfoByID_RPC.rpc(theID)

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
	Log.Print("RECEIVED JOIN GAME NETWORK DATA FROM "+str(multiplayer.get_remote_sender_id()))
	loadNetworkData(_data)
	
@rpc("authority", "call_remote", "reliable")
func notifyMultiplayerStarted():
	Log.Print("RECEIVED NOTIFY MULTIPLAYER STARTED FROM "+str(multiplayer.get_remote_sender_id()))
	

func _ready() -> void:
	var myInfo := createPlayerInfo(1, "Player")
	registerPlayerInfo(myInfo)
	
	multiplayer.multiplayer_peer = null
	multiplayer.server_disconnected.connect(_on_connection_failed)
	multiplayer.connection_failed.connect(_on_server_disconnected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	
	Noray.on_connect_to_host.connect(on_noray_connected)
	Noray.on_connect_nat.connect(_handle_connect_nat)
	Noray.on_connect_relay.connect(_handle_connect_relay)
	
	#Noray.connect_to_host(NORAY_ADDRESS, NORAY_PORT)

# Noray start
func on_noray_connected():
	Log.Print("Connected to Noray server")
	
	Noray.register_host()
	await Noray.on_pid
	await Noray.register_remote()
	noray_connected.emit()
	norayState = NORAY_CONNECTED

func _handle_connect_nat(address: String, port: int):
	var err = await _handle_connect(address, port)
	
	if err != OK && !is_host:
		Log.Print("NAT failed, using relay")
		setState(STATE_CONNECTING_RELAY)
		Noray.connect_relay(targetOID)
		err = OK
	
	return err

func _handle_connect_relay(address: String, port: int):
	return await _handle_connect(address, port)

func _handle_connect(address: String, port: int):
	var err := OK
	
	if !is_host:
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
		
		#doProcessStateMachine(ACTION_NORAY_HANDSHAKE_SUCCESS, [address, port])

		var peer = ENetMultiplayerPeer.new()
		err = peer.create_client(address, port, 0, 0, 0, Noray.local_port)
		if err != OK:
			Log.Print("Failed to create client: %s" % error_string(err))
			return err
		get_tree().get_multiplayer().multiplayer_peer = peer
		
		# Wait for connection to succeed
		await Async.condition(
			func(): return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
		)
		
		if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
			Log.Print("Failed to connect to %s:%s with status %s" % [address, port, peer.get_connection_status()])
			get_tree().get_multiplayer().multiplayer_peer = null
			return ERR_CANT_CONNECT

		doProcessStateMachine(ACTION_CONNECTED_TO_SERVER)
		
		return OK
	else:
		var peer = get_tree().get_multiplayer().multiplayer_peer as ENetMultiplayerPeer
		err = await PacketHandshake.over_enet(peer.host, address, port)
		
		if err != OK:
			Log.Printerr("Server handshake to %s:%s failed: %s" % [address, port, error_string(err)])
			return err
		Log.Print("Server handshake to %s:%s concluded" % [address, port])
	
	return err
	
	
	
	
# Noray end


func canHostOrJoin() -> bool:
	return !!multiplayer.multiplayer_peer

func _on_connection_failed():
	doProcessStateMachine(ACTION_CONNECTION_FAILED)


func _on_connected_ok():
	doProcessStateMachine(ACTION_CONNECTED_TO_SERVER)

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
	#if(!players.has(id)):
	#	return
	#var theData:NetworkPlayerInfo = players[id] if players.has(id) else null
	if(Network.isServer()):
		deletePlayerInfoByID(id, true)


func _on_server_disconnected():
	stopMultiplayer()
	
func isServer() -> bool:
	return !multiplayer.multiplayer_peer || (multiplayer.multiplayer_peer && multiplayer.is_server())
	
func isServerNotSingleplayer() -> bool:
	return !!multiplayer.multiplayer_peer && multiplayer.is_server()
	
func isClient() -> bool:
	return !!multiplayer.multiplayer_peer && !multiplayer.is_server()

func isClientOrSingleplayer() -> bool:
	return !multiplayer.multiplayer_peer || !multiplayer.is_server()

func stopMultiplayer():
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
func rpcClients(callable:Callable, args:Array = [], skipUs:bool = true):
	for playerID in players:
		if(skipUs && playerID == getMultiplayerID()):
			continue
		callable.bindv(args).rpc_id(playerID)

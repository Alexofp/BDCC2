extends MultiplayerSynchronizer
class_name SafeClientMultiplayerSynchronizer

func _ready() -> void:
	set_visibility_for(0, false)

	Network.playerConnected.connect(onPlayerConnect)
	
	await Network.get_tree().create_timer(1).timeout
	for playerID in Network.players:
		set_visibility_for(playerID, true)
	#if(Network.isClient()):
	#	addClientToVisible.rpc_id.call_deferred(1)

func onPlayerConnect(peer_id, _player_info):
	await Network.get_tree().create_timer(1).timeout
	set_visibility_for.call_deferred(peer_id, true)

@rpc("any_peer", "call_remote", "reliable")
func addClientToVisible():
	if(Network.isServer()):
		#Log.Print("MADE "+str(multiplayer.get_remote_sender_id())+" VISIBLE.")
		set_visibility_for(multiplayer.get_remote_sender_id(), true)

extends MultiplayerSynchronizer
class_name SafeMultiplayerSynchronizer

## This class is like a normal MultiplayerSynchronizer but it only begins
## synchronizing properties once it gets confirmation from the clients.
## This prevents errors that happen when we try to sync properties of nodes
## that weren't created yet on the clients.

# This little class is the real MVP. Thank you

func _ready() -> void:
	if(Network.isServer()):
		set_visibility_for(0, false)
	if(Network.isClient()):
		sendRequest.call_deferred()
	Network.multiplayerStarted.connect(onMultiplayerStarted)

func onMultiplayerStarted(_isHost:bool):
	if(Network.isClient()):
		sendRequest.call_deferred()

func sendRequest():
	var nodeToCheck:Node = self
	while(nodeToCheck):
		if(nodeToCheck.is_queued_for_deletion()):
			return
		nodeToCheck = nodeToCheck.get_parent()
	if(!is_inside_tree()):
		return
	if(Network.isClient()):
		addClientToVisible.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func addClientToVisible():
	if(Network.isServer()):
		#Log.Print("MADE "+str(multiplayer.get_remote_sender_id())+" VISIBLE.")
		set_visibility_for(multiplayer.get_remote_sender_id(), true)

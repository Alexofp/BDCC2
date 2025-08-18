extends Node3D
class_name GameModeBase

var id:int = -1

## Called when the gamemode is created. The map isn't loaded yet by this point
func initArgs(_args:Array):
	print("initArgs: "+str(id))
	pass

## Called after the map is loaded and we are ready to start playing
func start():
	print("Starting mode: "+str(id))

func onPlayerConnected(_peer_id:int, _player_info:NetworkPlayerInfo):
	#Log.Print("Player connected: "+_player_info.nickname+" (id="+str(_peer_id)+")")
	if(Network.isServer()):
		var thePC:BaseCharacter = GM.characterRegistry.createCharacter()
		var _thePawn:CharacterPawn = GM.pawnRegistry.createPawn(thePC.getID())
		_player_info.charID = thePC.getID()
		
func onPlayerDisconnected(_peer_id:int, _player_info:NetworkPlayerInfo):
	#Log.Print("Player disconnected: "+_player_info.nickname+" (id="+str(_peer_id)+")")
	if(Network.isServer()):
		GM.pawnRegistry.deletePawnOfNetworkPlayer(_player_info)
	pass

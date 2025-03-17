extends Control

@onready var name_list: ItemList = %NameList

func _ready() -> void:
	Network.playerConnected.connect(onPlayerConnected)
	Network.playerDisconnected.connect(onPlayerDisconnected)
	Network.playerListUpdated.connect(updatePlayerList)
	updatePlayerList()

func onPlayerConnected(_id, _info):
	#updatePlayerList()
	pass

func onPlayerDisconnected(_id, _info):
	#updatePlayerList()
	pass

func updatePlayerList():
	name_list.clear()
	
	for playerID in Network.players:
		var info:NetworkPlayerInfo = Network.players[playerID]
		
		name_list.add_item(info.getName()+" (id="+str(playerID)+")")
	

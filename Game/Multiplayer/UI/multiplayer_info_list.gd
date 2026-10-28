extends Control

@onready var admin_panel_button: Button = %AdminPanelButton
@onready var name_list: ItemList = %NameList
@export var adminPanel:bool = false
signal onAdminPanelOpen

func _ready() -> void:
	Network.playerConnected.connect(onPlayerConnected)
	Network.playerDisconnected.connect(onPlayerDisconnected)
	Network.playerListUpdated.connect(updatePlayerList)
	Network.multiplayerStarted.connect(onMultiplayerStarted)
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

func _on_admin_panel_button_pressed() -> void:
	onAdminPanelOpen.emit()

func onMultiplayerStarted(_isHost:bool):
	updateAdminPanelButton()

func updateAdminPanelButton():
	if(!adminPanel):
		admin_panel_button.visible = false
		return
	admin_panel_button.visible = Network.doWeHaveAdminRights()

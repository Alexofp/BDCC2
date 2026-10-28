extends PanelContainer

@onready var player_desc_label: RichTextLabel = %PlayerDescLabel
@onready var kick_button: Button = %KickButton
@onready var client_list: ItemList = %ClientList

signal onClosePressed
var selectedID:int = -1
var entries:Array[NetworkPlayerInfo]

func _on_close_button_pressed() -> void:
	onClosePressed.emit()

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
	client_list.clear()
	entries.clear()
	var _i:int = 0
	for playerID:int in Network.players:
		var info:NetworkPlayerInfo = Network.players[playerID]
		client_list.add_item(info.getName()+" (id="+str(playerID)+")")
		if(selectedID == playerID):
			client_list.select(_i)
		entries.append(info)
		_i += 1
	
func _on_client_list_item_selected(_index: int) -> void:
	if(_index < 0 || _index >= entries.size()):
		return
	selectedID = entries[_index].id
	updateSelectedInfo()
	
func updateSelectedInfo():
	var theInfo:NetworkPlayerInfo = Network.getPlayerInfo(selectedID)
	if(!theInfo):
		player_desc_label.text = ""
		return
	var _thePlayerData:PlayerData = GM.game.findPlayerDataForProfile(theInfo.profile, false)
	var _isUs:bool = theInfo.isUs()
	var theLines:Array[String]
	theLines.append("Nickname: "+theInfo.getName())
	theLines.append("Internal network id: "+str(theInfo.id))
	if(!_thePlayerData):
		theLines.append("No player data found")
	else:
		var theChar:BaseCharacter = GM.characterRegistry.getCharacter(_thePlayerData.charID)
		if(theChar):
			theLines.append("Playing as: "+theChar.getFullName())
		else:
			theLines.append("Not playing as anyone")
	
	player_desc_label.text = Util.join(theLines, "\n")

func _on_kick_button_pressed() -> void:
	Network.askKickPlayer(selectedID)

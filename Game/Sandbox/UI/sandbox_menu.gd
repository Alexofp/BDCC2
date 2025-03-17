extends PanelContainer

@onready var pawn_list: ItemList = %PawnList

var pawnIDs:Array = []

signal onClosePressed

func _ready():
	GameInteractor.pawnRegistry.onPawnListChanged.connect(updatePawnMenu)
	Network.playerListUpdated.connect(updatePawnMenu)
	Network.playerSwitchedCharacter.connect(onPlayerSwitchedCharacter)
	updatePawnMenu()

func onPlayerSwitchedCharacter(_playerID, _oldCharID, _newCharID) -> void:
	updatePawnMenu()

func _on_close_button_pressed() -> void:
	onClosePressed.emit()

func _enter_tree() -> void:
	UIHandler.addUI(self)

func _exit_tree() -> void:
	UIHandler.removeUI(self)

func updatePawnMenu():
	pawn_list.clear()
	pawnIDs.clear()
	
	var _i:int = 0
	for pawnID in GameInteractor.pawnRegistry.pawns:
		var pcInfo:NetworkPlayerInfo = Network.getInfoThatControlsCharID(pawnID)
		var theName:String = str(pawnID)
		if(pcInfo):
			theName += " ("+str(pcInfo.getName())+")"
		
		pawnIDs.append(pawnID)
		var _pawn:CharacterPawn = GameInteractor.pawnRegistry.getPawn(pawnID)
		
		pawn_list.add_item(theName)
		if(pcInfo && pcInfo.isUs()):
			pawn_list.select(_i)
		_i += 1

func _on_switch_button_pressed() -> void:
	if(pawn_list.get_selected_items().is_empty()):
		return
	var theIndx:int = pawn_list.get_selected_items()[0]
	if(theIndx < 0 || theIndx >= pawnIDs.size()):
		return
	var newPawnID:String = pawnIDs[theIndx]
	
	#TODO Make this a gameinteractor thing?
	if(Network.isClient()):
		switchInfoSelectedCharID.rpc_id(1, newPawnID)
		return
	var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
	if(!myInfo):
		return
	myInfo.charID = newPawnID

@rpc("any_peer", "call_remote", "reliable")
func switchInfoSelectedCharID(newPawnID:String):
	var myInfo:NetworkPlayerInfo = Network.getPlayerInfo(multiplayer.get_remote_sender_id())
	if(!myInfo):
		return
	myInfo.charID = newPawnID
	
@rpc("any_peer", "call_remote", "reliable")
func _on_add_pawn_button_pressed() -> void:
	if(Network.isClient()):
		_on_add_pawn_button_pressed.rpc_id(1)
		return
	#TODO Make this a gameinteractor thing?
	var thePC:BaseCharacter = GameInteractor.characterRegistry.createCharacter()
	var _thePawn:CharacterPawn = GameInteractor.pawnRegistry.createPawn(thePC.getID())
	

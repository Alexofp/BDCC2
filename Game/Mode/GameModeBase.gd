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

func showCharacterCreator():
	GM.main.showCharacterCreator()

func hideCharacterCreator():
	GM.main.hideCharacterCreator()

func isCharacterCreatorVisible() -> bool:
	return GM.main.isCharacterCreatorVisible()

func onCharacterCreatorAppear():
	pass

func onCharacterCreatorConfirm():
	pass

func _physics_process(_delta: float) -> void:
	if(Network.isServer()):
		checkOutOfBoundsCharacters()

func _process(_delta: float) -> void:
	processCharacterCreator(_delta)
	if(canClientsCreateItems()):
		processDebugMenuGiver(_delta)

func processCharacterCreator(_delta:float):
	if(!UIHandler.isMenuInputBlocked()):
		if(Input.is_action_just_pressed("debug_mousecapture")):
			if(!isCharacterCreatorVisible()):
				if(!UIHandler.tryCloseMenu()):
					showCharacterCreator()
			else:
				hideCharacterCreator()

func processDebugMenuGiver(_delta:float):
	if(!UIHandler.isMenuInputBlocked()):
		if(Input.is_action_just_pressed("debug_item_giver")):
			if(!UIHandler.tryCloseMenu()):
				var theGiverUI = load("res://UI/Util/debug_item_giver_ui.tscn").instantiate()
				#theGiverUI.giverNode = weakref(self)
				theGiverUI.dollUser = GI.getUniqueIDOf(GM.pcDoll)
				GM.main.addUINode(theGiverUI)

func canClientsCreateItems() -> bool:
	return true

func askDebugEquipItem(theChar:BaseCharacter, _slot:int, _itemID:String):
	if(Network.isClient()):
		askDebugEquipItem_SERVERRPC.rpc_id(1, theChar.getID(), _slot, _itemID)
	else:
		askDebugEquipItem_SERVERRPC(theChar.getID(), _slot, _itemID)

@rpc("any_peer", "call_remote", "reliable")
func askDebugEquipItem_SERVERRPC(_charID:String, _slot:int, _itemID:String):
	if(!canClientsCreateItems()):
		Log.Printerr("Client "+str(multiplayer.get_remote_sender_id())+" tried to cheat-create an item.")
		return
	var theChar:BaseCharacter = GM.characterRegistry.getCharacter(_charID)
	if(!theChar):
		return
	theChar.getInventory().setEquippedItem(_slot, GlobalRegistry.createItem(_itemID) if !_itemID.is_empty() else null)

func askDebugGiveItem(theChar:BaseCharacter, _itemID:String):
	if(Network.isClient()):
		askDebugGiveItem_SERVERRPC.rpc_id(1, theChar.getID(), _itemID)
	else:
		askDebugGiveItem_SERVERRPC(theChar.getID(), _itemID)

@rpc("any_peer", "call_remote", "reliable")
func askDebugGiveItem_SERVERRPC(_charID:String, _itemID:String):
	if(!canClientsCreateItems()):
		Log.Printerr("Client "+str(multiplayer.get_remote_sender_id())+" tried to cheat-create an item.")
		return
	var theChar:BaseCharacter = GM.characterRegistry.getCharacter(_charID)
	if(!theChar):
		return
	theChar.getInventory().addItem(GlobalRegistry.createItem(_itemID))

func canClientSwitchCharacters(_nid:int) -> bool:
	return true

func askSwitchToCharID(_charID:String) -> void:
	if(Network.isClient()):
		askSwitchToCharID_SERVERRPC.rpc_id(1, _charID)
		return
	askSwitchToCharID_SERVERRPC(_charID)

@rpc("any_peer", "call_remote", "reliable")
func askSwitchToCharID_SERVERRPC(newPawnID:String):
	var myInfo:NetworkPlayerInfo = Network.getSenderPlayerInfo()
	if(!myInfo):
		return
	if(!canClientSwitchCharacters(myInfo.id)):
		return
	
	var curInfo := Network.getPlayerInfoControllingCharID(newPawnID)
	if(!curInfo):
		myInfo.charID = newPawnID
	elif(curInfo == myInfo):
		pass
	else:
		myInfo.sendToChat("This character is already controlled by another player.")

func checkOutOfBoundsCharacters(_lowPoint:float = -200.0, _resetPoint:Vector3 = Vector3(0.0, 0.0, 0.0)):
	GM.dollHolder.checkOutOfBoundsCharacters(_lowPoint, _resetPoint)

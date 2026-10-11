extends Node3D
class_name GameModeBase

var id:String = ""

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
	processFreeCam(_delta)
	if(canClientsCreateItems()):
		processDebugMenuGiver(_delta)

func processFreeCam(_delta:float) -> void:
	if(Input.is_action_just_pressed("game_freecam") && !UIHandler.isMenuInputBlocked()):
		if(GM.main.free_camera.cameraPriority > 1.0):
			GM.main.free_camera.cameraPriority = -1.0
		else:
			var curCam := CameraSystem.getActiveCameraWithHighestPriority()
			if(curCam):
				GM.main.free_camera.global_rotation = curCam.global_rotation
				GM.main.free_camera.global_position = curCam.global_position
			GM.main.free_camera.cameraPriority = 10000.0

func processCharacterCreator(_delta:float):
	if(Input.is_action_just_pressed("game_charactercreator") && !UIHandler.isMenuInputBlocked()):
		if(!isCharacterCreatorVisible()):
			if(!UIHandler.tryCloseMenu()):
				showCharacterCreator()
		else:
			hideCharacterCreator()

func processDebugMenuGiver(_delta:float):
	if(Input.is_action_just_pressed("debug_item_giver") && !UIHandler.isMenuInputBlocked()):
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

func startNewGame(_holder:StartGameHolder):
	loadFromDef(_holder.gameModeDef)
	if(Network.isServer()):
		createPopulationNewGame(_holder)
		createPlayerNewGame(_holder)

func createPopulationNewGame(_holder:StartGameHolder):
	var _i:int = 0
	for theStartChar:StartGameCharHolder in _holder.population:
		if(!theStartChar.preset):
			Log.Printerr("Bad preset!")
			continue
		var _theChar:BaseCharacter = GM.characterRegistry.createCharacter()
		theStartChar.preset.applyToCharacter(_theChar)
		giveDefaultStuff(_theChar)
		var _thePawn:CharacterPawn = GM.pawnRegistry.createPawn(_theChar.getID())
		_thePawn.position.x = 2.0 + _i*2.0
		_i += 1

func createPlayerNewGame(_holder:StartGameHolder):
	var thePC:BaseCharacter = GM.characterRegistry.createCharacter()
	_holder.playerPreset.preset.applyToCharacter(thePC)
	giveDefaultStuff(thePC)
	#thePC.resetToDefaultPCCharacter()
	var _thePawn:CharacterPawn = GM.pawnRegistry.createPawn(thePC.getID())
	var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
	myInfo.charID = thePC.getID()

func giveDefaultStuff(_char:BaseCharacter):
	if(_char.gender.getGender() != Gender.Male):
		_char.inventory.equipItem(GlobalRegistry.createItem("InmateTop"), InventorySlot.Top)
	else:
		_char.inventory.equipItem(GlobalRegistry.createItem("InmateTankTop"), InventorySlot.Top)
	_char.inventory.equipItem(GlobalRegistry.createItem("InmateShorts"), InventorySlot.Bottom)
	_char.inventory.equipItem(GlobalRegistry.createItem("InmateCollar"), InventorySlot.Collar)

func loadFromDef(_modeRef:GameModeDef):
	pass

func saveData() -> Dictionary:
	return {}

func loadData(_data:Dictionary):
	pass

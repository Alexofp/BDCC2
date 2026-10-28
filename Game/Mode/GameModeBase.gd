extends Node3D
class_name GameModeBase

var id:String = ""

var playersData:Array[PlayerData]
var fallbackGID:String = "" # What player data should we use in case we can't find ours

# Use a dict to optimize this?
func getPlayerDataForCharID(_charID:String) -> PlayerData:
	for theData:PlayerData in playersData:
		if(theData.charID == _charID):
			return theData
	return null

func findPlayerDataForProfile(_profile:PlayerProfile, _lookForFallbackInSinglePlayer:bool = true) -> PlayerData:
	for _data:PlayerData in playersData:
		if(_data.gid == _profile.gid):
			return _data
	# If we're doing singleplayer, try to find the data of the player who started this game
	if(_lookForFallbackInSinglePlayer && !Network.isMultiplayer() && !fallbackGID.is_empty()):
		for _data:PlayerData in playersData:
			if(_data.gid == fallbackGID):
				return _data
		# Return any data? First would probably be the good one
		if(!playersData.is_empty()):
			return playersData[0]
	return null

func assignPlayerData(_char:BaseCharacter, _profile:PlayerProfile):
	for _existing:PlayerData in playersData:
		if(_existing.gid == _profile.gid):
			_existing.charID = _char.getID()
			return
	var _newPlayerData:PlayerData = PlayerData.new()
	_newPlayerData.charID = _char.getID()
	_newPlayerData.gid = _profile.gid
	_newPlayerData.playerName = _profile.nickname
	playersData.append(_newPlayerData)

# Called after the game was loaded from a save. Only realistically gets called on the server
func afterGameLoad():
	if(!Network.isServer()):
		return
	var myInfo := Network.getMyPlayerInfo()
	if(!myInfo): # Dedicated server or something
		return
	var bestPlayerInfo := findPlayerDataForProfile(myInfo.profile, true)
	if(!bestPlayerInfo): # Rip, we would probably have to create a new character
		return
	myInfo.charID = bestPlayerInfo.charID
	#assignPlayerData() ?

## Called when the gamemode is created. The map isn't loaded yet by this point
func initArgs(_args:Array):
	print("initArgs: "+str(id))
	pass

## Called after the map is loaded and we are ready to start playing
func start():
	print("Starting mode: "+str(id))

@rpc("authority", "call_remote", "reliable")
func openWelcomeMenu_RPC(_data:Dictionary):
	GM.main.showWelcomeClientUI(_data)

@rpc("authority", "call_remote", "reliable")
func closeWelcomeMenu_RPC():
	GM.main.hideWelcomeClientUI()

func askToJoinAsMyCharacter():
	if(!Network.isClient()):
		return
	askToJoinAsMyCharacter_SERVERRPC.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func askToJoinAsMyCharacter_SERVERRPC():
	var _player_info:NetworkPlayerInfo = Network.getRPCPlayerInfo()
	if(!_player_info || !_player_info.charID.is_empty()):
		return
	var _theirPlayerData:PlayerData = findPlayerDataForProfile(_player_info.profile)
	if(_theirPlayerData && GM.characterRegistry.getCharacter(_theirPlayerData.charID)):
		var theCharID:String = _theirPlayerData.charID
		var _oldChar:BaseCharacter = GM.characterRegistry.getCharacter(theCharID)
		if(!GM.pawnRegistry.hasPawn(theCharID)):
			GM.pawnRegistry.createPawn(theCharID)
		_player_info.charID = theCharID
		assignPlayerData(_oldChar, _player_info.profile) # Just in case
		closeWelcomeMenu_RPC.rpc_id(_player_info.id)
		return

func askToJoinWithPreset(_preset:CharacterPreset):
	if(!Network.isClient()):
		return
	askToJoinWithPreset_SERVERRPC.rpc_id(1, _preset.saveData())

@rpc("any_peer", "call_remote", "reliable")
func askToJoinWithPreset_SERVERRPC(_presetData:Dictionary):
	if(!Network.isServer()):
		return
	var _player_info:NetworkPlayerInfo = Network.getRPCPlayerInfo()
	if(!_player_info || !_player_info.charID.is_empty()):
		return
	closeWelcomeMenu_RPC.rpc_id(_player_info.id)
	
	var thePreset:CharacterPreset = CharacterPreset.new()
	thePreset.loadData(_presetData)
	
	# Make them a new character
	var thePC:BaseCharacter = GM.characterRegistry.createCharacter()
	#thePC.resetToDefaultPCCharacter()
	thePreset.applyToCharacter(thePC)
	giveDefaultStuff(thePC)
	var _thePawn:CharacterPawn = GM.pawnRegistry.createPawn(thePC.getID())
	_player_info.charID = thePC.getID()
	
	assignPlayerData(thePC, _player_info.profile)

# Called after the client has received all the world data
func onPlayerConnectedLate(_peer_id:int, _player_info:NetworkPlayerInfo):
	onPlayerConnectedDoStuff(_peer_id, _player_info)
	pass
	
func onPlayerConnected(_peer_id:int, _player_info:NetworkPlayerInfo):
	pass
	
func onPlayerConnectedDoStuff(_peer_id:int, _player_info:NetworkPlayerInfo):
	#Log.Print("Player connected: "+_player_info.nickname+" (id="+str(_peer_id)+")")
	if(!Network.isServer()):
		return
	# Check if they have a character already
	var _theirPlayerData:PlayerData = findPlayerDataForProfile(_player_info.profile)
	if(_theirPlayerData && GM.characterRegistry.getCharacter(_theirPlayerData.charID)):
		var theCharID:String = _theirPlayerData.charID
		var _oldChar:BaseCharacter = GM.characterRegistry.getCharacter(theCharID)
		if(!GM.pawnRegistry.hasPawn(theCharID)): # If no pawn, show them a menu
			#GM.pawnRegistry.createPawn(theCharID)
			openWelcomeMenu_RPC.rpc_id(_peer_id, {
				motd = Network.customMOTD,
				charName = _oldChar.getFullName(),
			})
			return
		_player_info.charID = theCharID
		assignPlayerData(_oldChar, _player_info.profile) # Just in case
		return
	# Make them a new character
	if(false):
		var thePC:BaseCharacter = GM.characterRegistry.createCharacter()
		thePC.resetToDefaultPCCharacter()
		giveDefaultStuff(thePC)
		var _thePawn:CharacterPawn = GM.pawnRegistry.createPawn(thePC.getID())
		_player_info.charID = thePC.getID()
		assignPlayerData(thePC, _player_info.profile)
	openWelcomeMenu_RPC.rpc_id(_peer_id, {
		motd = Network.customMOTD,
	})
		
func onPlayerDisconnected(_peer_id:int, _player_info:NetworkPlayerInfo):
	#Log.Print("Player disconnected: "+_player_info.nickname+" (id="+str(_peer_id)+")")
	if(Network.isServer() && GM.pawnRegistry):
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

func createPopulationNewGame(_holder:StartGameHolder, _spawnAsPawn:bool = true):
	var _i:int = 0
	for theStartChar:StartGameCharHolder in _holder.population:
		if(!theStartChar.preset):
			Log.Printerr("Bad preset!")
			continue
		var _theChar:BaseCharacter = GM.characterRegistry.createCharacter()
		theStartChar.preset.applyToCharacter(_theChar)
		giveDefaultStuff(_theChar)
		if(_spawnAsPawn):
			var _thePawn:CharacterPawn = GM.pawnRegistry.createPawn(_theChar.getID())
			_thePawn.position.x = 2.0 + _i*2.0
		_i += 1

func createPlayerNewGame(_holder:StartGameHolder, _spawnAsPawn:bool = true) -> BaseCharacter:
	var thePC:BaseCharacter = GM.characterRegistry.createCharacter()
	_holder.playerPreset.preset.applyToCharacter(thePC)
	giveDefaultStuff(thePC)
	#thePC.resetToDefaultPCCharacter()
	if(_spawnAsPawn):
		var _thePawn:CharacterPawn = GM.pawnRegistry.createPawn(thePC.getID())
	var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
	myInfo.charID = thePC.getID()
	
	assignPlayerData(thePC, MyProfile.profile)
	fallbackGID = MyProfile.profile.gid
	
	return thePC

func giveDefaultStuff(_char:BaseCharacter):
	if(_char.gender.getGender() != Gender.Male):
		_char.inventory.equipItem(GlobalRegistry.createItem("InmateTop"), InventorySlot.Top)
	else:
		_char.inventory.equipItem(GlobalRegistry.createItem("InmateTankTop"), InventorySlot.Top)
	_char.inventory.equipItem(GlobalRegistry.createItem("InmateShorts"), InventorySlot.Bottom)
	_char.inventory.equipItem(GlobalRegistry.createItem("InmateCollar"), InventorySlot.Collar)

func loadFromDef(_modeRef:GameModeDef):
	pass

func canSaveGame() -> bool:
	return true

func saveData() -> Dictionary:
	var _playerData:Array[Dictionary]
	for thePlayerData:PlayerData in playersData:
		_playerData.append(thePlayerData.saveData())
	
	return {
		playersData = _playerData,
		fallbackGID = fallbackGID,
	}

func loadData(_data:Dictionary):
	playersData.clear()
	
	fallbackGID = SAVE.loadVar(_data, "fallbackGID", "")
	
	var _playerData:Array = SAVE.loadVar(_data, "playersData", [])
	for thePlayerEntry:Dictionary in _playerData:
		var _newPlayerData:PlayerData = PlayerData.new()
		_newPlayerData.loadData(thePlayerEntry)
		playersData.append(_newPlayerData)

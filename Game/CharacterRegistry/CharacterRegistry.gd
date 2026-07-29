extends Node
class_name CharacterRegistry

var characters:Dictionary[String, BaseCharacter] = {}
var characterList:Array[BaseCharacter] = []
var lastUniqueID:int = 0

signal characterAdded(charID:String, character:BaseCharacter)
signal characterRemoved(charID:String, character:BaseCharacter)

func _ready():
	GI.characterRegistry = self
	#Network.playerConnected.connect(onPlayerConnected)
	#set_multiplayer_authority(Network.getHostID())
	

#func onPlayerConnected(_id:int, _playerInfo:NetworkPlayerInfo):
	#if(Network.isServer() && Network.getMultiplayerID() != _id):
		#Log.Print("Sending full characters data to "+str(_id))
		#applyFullNetworkData.rpc_id(_id, saveFullNetworkData())

func askCharacterChangeBaseSkinTypeData(character:BaseCharacter, newSkinType:int, newSkinTypeData:SkinTypeData):
	if(Network.isServer()):
		character.setBaseSkinTypeData(newSkinType, newSkinTypeData)
	else:
		askCharacterChangeBaseSkinTypeData_SERVERRPC.rpc_id(1, character.getID(), newSkinType, newSkinTypeData.saveData())

@rpc("any_peer", "call_remote", "reliable")
func askCharacterChangeBaseSkinTypeData_SERVERRPC(_id:String, _skinType:int, _skinTypeData:Dictionary):
	# Do server checks here
	var theCharacter := getCharacter(_id)
	if(!theCharacter):
		return
	var skinTypeData := SkinTypeData.new()
	skinTypeData.loadData(_skinTypeData)
	#askCharacterChangeBaseSkinTypeData(theCharacter, _skinType, skinTypeData)
	theCharacter.setBaseSkinTypeData(_skinType, skinTypeData)


func askCharacterPartChange(character:BaseCharacter, genericType:int, partSlot:int, _newPartID:String, _newPartData:Dictionary):
	if(Network.isServer()):
		if(!character):
			return
		var bodypart:GenericPart = GlobalRegistry.createGenericPart(genericType, _newPartID) if _newPartID != "" else null
		if(bodypart):
			bodypart.loadData(_newPartData)
		#character.addGenericPart(genericType, partSlot, bodypart)
		character.addGenericPartTryKeepProperties(genericType, partSlot, bodypart)
	else:
		askCharacterPartChange_SERVERRPC.rpc_id(1, character.getID(), genericType, partSlot, _newPartID, _newPartData)

@rpc("any_peer", "call_remote", "reliable")
func askCharacterPartChange_SERVERRPC(_id:String, genericType:int, partSlot:int, _newPartID:String, _newPartData:Dictionary):
	# Do server checks here
	var theCharacter := getCharacter(_id)
	if(!theCharacter):
		return
	askCharacterPartChange(theCharacter, genericType, partSlot, _newPartID, _newPartData)


func askCharacterPartOptionChange(character:BaseCharacter, genericType:int, partSlot:int, optionID:String, newvalue:Variant):
	if(Network.isServer()):
		#var character:BaseCharacter = getCharacter(_id)
		if(!character):
			return
		var genericPart:GenericPart = character.getGenericPart(genericType, partSlot)
		if(!genericPart):
			return
		genericPart.setOptionValue(optionID, newvalue)
	else:
		askCharacterPartOptionChange_SERVERRPC.rpc_id(1, character.getID(), genericType, partSlot, optionID, newvalue)
	#GI.doOnServer(InteractCommand.BODYPART_CHANGE, [character.getID(), genericType, partSlot, optionID, newvalue])

@rpc("any_peer", "call_remote", "reliable")
func askCharacterPartOptionChange_SERVERRPC(_id:String, genericType:int, partSlot:int, optionID:String, newvalue:Variant):
	# Do the server checks here
	var theCharacter := getCharacter(_id)
	if(!theCharacter):
		return
	askCharacterPartOptionChange(theCharacter, genericType, partSlot, optionID, newvalue)


func askCharacterSyncOptionChange(character:BaseCharacter, optionID:String, theValue):
	if(Network.isServer()):
		character.applyCharChange(optionID, theValue)
	else:
		onCharacterSyncOptionChange_SERVERRPC.rpc_id(1, character.getID(), optionID, theValue)
		
@rpc("any_peer", "call_remote", "reliable")
func onCharacterSyncOptionChange_SERVERRPC(charID:String, optionID:String, theValue):
	# Do server checks here
	var theCharacter:BaseCharacter = getCharacter(charID)
	if(!theCharacter):
		return
	if(optionID in theCharacter.getSyncOptions()):
		theCharacter.applyCharChange(optionID, theValue)

func askCharacterSetPersonality(character:BaseCharacter, personality:Personality):
	if(Network.isServer()):
		character.personality.loadNetworkData(personality.saveNetworkData().prepareToRead())
	else:
		onCharacterSetPersonality_SERVERRPC.rpc_id(1, character.getID(), personality.saveNetworkData().getBytesCompressedSimple())
		
@rpc("any_peer", "call_remote", "reliable")
func onCharacterSetPersonality_SERVERRPC(charID:String, personalityData:PackedByteArray):
	# Do server checks here
	var theCharacter:BaseCharacter = getCharacter(charID)
	if(!theCharacter):
		return
	theCharacter.personality.loadNetworkData(Bins.readCompressedSimple(personalityData))
	

func askCharacterSetFetishHolder(character:BaseCharacter, fetishHolder:FetishHolder):
	if(Network.isServer()):
		character.fetishHolder.loadNetworkData(fetishHolder.saveNetworkData().prepareToRead())
	else:
		onCharacterSetFetishHolder_SERVERRPC.rpc_id(1, character.getID(), fetishHolder.saveNetworkData().getBytesCompressedSimple())
		
@rpc("any_peer", "call_remote", "reliable")
func onCharacterSetFetishHolder_SERVERRPC(charID:String, fetishHolderData:PackedByteArray):
	# Do server checks here
	var theCharacter:BaseCharacter = getCharacter(charID)
	if(!theCharacter):
		return
	theCharacter.fetishHolder.loadNetworkData(Bins.readCompressedSimple(fetishHolderData))
	
	
	
	
func getCharacter(theID:String) -> BaseCharacter:
	if(!characters.has(theID)):
		return null
	return characters[theID]

func hasCharacter(theID:String) -> bool:
	return characters.has(theID)

func generateNewUniqueID() -> String:
	lastUniqueID += 1
	return "npc"+str(lastUniqueID-1)

func addCharacter(theChar:BaseCharacter):
	assert(theChar.getID() != "", "EMPTY CHARACTER ID")
	
	if(theChar.id == ""):
		theChar.id = generateNewUniqueID()
	
	characters[theChar.getID()] = theChar
	characterList.append(theChar)
	connectSignalsToCharacter(theChar)

func connectSignalsToCharacter(theChar:BaseCharacter):
	theChar.onChange.connect(onCharChange.bind(theChar))
	pass

func onCharChange(_change:BaseCharChange, _theChar:BaseCharacter):
	var theType := _change.getType()
	
	match theType:
		BaseCharChange.PART:
			if(_change.genericType != BaseCharacter.GENERIC_CLOTHING && Network.isServerNotSingleplayer()):
				var thePart := _theChar.getGenericPart(_change.genericType, _change.slot)
				Network.rpcClients(characterPartChange_RPC.bind(_theChar.getID(), _change.genericType, _change.slot, thePart.id if thePart else "", thePart.saveNetworkData().getBytesCompressedSimple() if thePart else PackedByteArray()))
			pass
		BaseCharChange.PART_OPTION:
			if(_change.genericType != BaseCharacter.GENERIC_CLOTHING && Network.isServerNotSingleplayer()):
				Network.rpcClients(characterPartOptionChange_RPC.bind(_theChar.getID(), _change.genericType, _change.slot, _change.optionID, _change.value))
			pass
		BaseCharChange.CHAR_OPTION:
			if(Network.isServerNotSingleplayer()):
				Network.rpcClients(characterOptionChange_RPC.bind(_theChar.getID(), _change.optionID, _theChar.getSyncOptionValue(_change.optionID)))
			pass
		BaseCharChange.PART_FILTER:
			pass
		BaseCharChange.PERSONALITY_UPDATE:
			if(Network.isServerNotSingleplayer()):
				Network.rpcClients(characterPersonalityUpdate_RPC.bind(_theChar.getID(), _theChar.personality.saveNetworkData().getBytesCompressedSimple()))
			pass
		BaseCharChange.FETISHES_UPDATE:
			if(Network.isServerNotSingleplayer()):
				Network.rpcClients(characterFetishesUpdate_RPC.bind(_theChar.getID(), _theChar.fetishHolder.saveNetworkData().getBytesCompressedSimple()))
			pass

@rpc("authority", "call_remote", "reliable")
func characterFetishesUpdate_RPC(_id:String, _fetishData:PackedByteArray):
	var theCharacter:BaseCharacter = getCharacter(_id)
	if(!theCharacter):
		return
	theCharacter.fetishHolder.loadNetworkData(Bins.readCompressedSimple(_fetishData))

@rpc("authority", "call_remote", "reliable")
func characterPersonalityUpdate_RPC(_id:String, _persData:PackedByteArray):
	var theCharacter:BaseCharacter = getCharacter(_id)
	if(!theCharacter):
		return
	theCharacter.personality.loadNetworkData(Bins.readCompressedSimple(_persData))

@rpc("authority", "call_remote", "reliable")
func characterOptionChange_RPC(_id:String, _optionID:String, _value:Variant):
	var theCharacter:BaseCharacter = getCharacter(_id)
	if(!theCharacter):
		return
	theCharacter.applyCharChange(_optionID, _value)

@rpc("authority", "call_remote", "reliable")
func characterPartOptionChange_RPC(_id:String, _genericType:int, _slot:int, _optionID:String, _value:Variant):
	var theCharacter:BaseCharacter = getCharacter(_id)
	if(!theCharacter):
		return
	var genericPart:GenericPart = theCharacter.getGenericPart(_genericType, _slot)
	if(!genericPart):
		return
	genericPart.setOptionValue(_optionID, _value)

@rpc("authority", "call_remote", "reliable")
func characterPartChange_RPC(_id:String, _genericType:int, _slot:int, _partID:String, _partData:PackedByteArray):
	var theCharacter:BaseCharacter = getCharacter(_id)
	if(!theCharacter):
		return
	var bodypart:GenericPart = GlobalRegistry.createGenericPart(_genericType, _partID) if _partID != "" else null
	if(bodypart):
		bodypart.loadNetworkData(Bins.readCompressedSimple(_partData))
	theCharacter.addGenericPart(_genericType, _slot, bodypart)

func createCharacter() -> BaseCharacter:
	return addExistingCharacter(prepareCharacter())

func prepareCharacter() -> BaseCharacter:
	var newID := generateNewUniqueID()
	var newChar:BaseCharacter = BaseCharacter.new()
	newChar.id = newID
	return newChar

@rpc("authority", "call_remote", "reliable")
func createCharacter_RPC(theID:String, _data:Dictionary):
	var theChar:BaseCharacter = createCharacterCustomID(theID)
	theChar.loadData(_data)

func createCharacterCustomID(theID:String) -> BaseCharacter:
	var newChar:BaseCharacter = BaseCharacter.new()
	newChar.id = theID
	
	addExistingCharacter(newChar)
	return newChar

func addExistingCharacter(newChar:BaseCharacter) -> BaseCharacter:
	connectSignalsToCharacter(newChar)
	characters[newChar.id] = newChar
	characterList.append(newChar)
	characterAdded.emit(newChar.id, newChar)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(createCharacter_RPC.bind(newChar.id, newChar.saveData()))
	return newChar

@rpc("authority", "call_remote", "reliable")
func removeCharacter_RPC(theID:String):
	removeCharacterID(theID)

func removeCharacterID(theCharID:String):
	if(!characters.has(theCharID)):
		Log.Printerr("Trying to remove a character that doesn't exist: '"+str(theCharID)+"'")
		return
	GM.main.relationshipSystem.onCharacterIDRemoved(theCharID)
	var theCharInfo:BaseCharacter = characters[theCharID]
	characters.erase(theCharID)
	characterList.erase(theCharInfo)
	characterRemoved.emit(theCharID, theCharInfo)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(removeCharacter_RPC.bind(theCharID))
	theCharInfo.deinit()

func clearCharacters():
	for charID in characters.keys():
		removeCharacterID(charID)

func askCharacterLoadPreset(character:BaseCharacter, preset:CharacterPreset):
	if(Network.isServer()):
		preset.applyToCharacter(character)
	else:
		askCharacterLoadPreset_SERVERRPC.rpc_id(1, character.getID(), preset.saveData())

@rpc("any_peer", "call_remote", "reliable")
func askCharacterLoadPreset_SERVERRPC(characterID:String, _data:Dictionary):
	# Server checks here
	var theCharacter:BaseCharacter = getCharacter(characterID)
	if(!theCharacter):
		return
	var thePreset:CharacterPreset = CharacterPreset.new()
	thePreset.loadData(_data)
	thePreset.applyToCharacter(theCharacter)
	Network.rpcClients(notifyPresetApplied_RPC.bind(characterID))

@rpc("authority", "call_remote", "reliable")
func notifyPresetApplied_RPC(characterID:String):
	var theCharacter:BaseCharacter = getCharacter(characterID)
	if(!theCharacter):
		return
	theCharacter.notifyPresetApplied()

func askCharacterWizardSubmit(character:BaseCharacter, _data:Dictionary):
	if(Network.isServer()):
		characterWizardSubmitDo(character, _data)
	else:
		askCharacterWizardSubmit_SERVERRPC.rpc_id(1, character.getID(), _data)
		
@rpc("any_peer", "call_remote", "reliable")
func askCharacterWizardSubmit_SERVERRPC(characterID:String, _data:Dictionary):
	# Server checks here
	var theCharacter:BaseCharacter = getCharacter(characterID)
	if(!theCharacter):
		return
	characterWizardSubmitDo(theCharacter, _data)

func characterWizardSubmitDo(character:BaseCharacter, _data:Dictionary):
	var newName:String = _data[CharOption.name]
	var newGenderData:Dictionary = _data[CharOption.gender]
	var newSpeciesData:Dictionary = _data[CharOption.species]
	
	character.applyCharChange(CharOption.name, newName)
	character.applyCharChange(CharOption.gender, newGenderData)
	character.applyCharChange(CharOption.species, newSpeciesData)
	
	character.resetToBaseEditorState()

var rareTimer:float = 0.0
var rareI:int = 0 # Index of a current character to call the processRare func for
var veryRareTimer:float = 0.0
var veryRareI:int = 0

func _physics_process(_delta: float) -> void:
	if(Network.isServer()):
		#for charID in characters: #TODO: process far-away npcs less often
		for theCharacter:BaseCharacter in characterList:
			#var character:BaseCharacter = characters[charID]
			theCharacter.processTime(_delta)
		
		if(!characterList.is_empty()):
			rareTimer += _delta
			veryRareTimer += _delta
			
			var theCharAmount:int = characterList.size()
			
			var theShare:float = 1.0/float(characterList.size())
			while(rareTimer >= theShare && !characterList.is_empty()):
				rareTimer -= theShare
				if(rareI < 0 || rareI >= theCharAmount):
					rareI = 0
				characterList[rareI].processRare(1.0)
				rareI += 1
			while(veryRareTimer >= theShare*30.0 && !characterList.is_empty()):
				veryRareTimer -= theShare*30.0
				if(veryRareI < 0 || veryRareI >= theCharAmount):
					veryRareI = 0
				characterList[veryRareI].processVeryRare(30.0)
				veryRareI += 1
	
	if(Network.isServerNotSingleplayer()):
		#for charID in characters:
		for character:BaseCharacter in characterList:
			var charID:String = character.id
			#var character:BaseCharacter = characters[charID]
			var charState:CharState = character.getCharState()
			var charSyncState:SyncState = charState.syncState
			if(charSyncState.getDirtyTime() >= 0.5):
				#print("DIRTY!")
				var dirtyData:=charSyncState.getDelta()
				Network.rpcClients(syncCharState_RPC.bind(charID, dirtyData))
				
				charSyncState.resetDelta()

			var bodyMess := character.getBodyMess()
			if(bodyMess.dirty > 0.0):
				bodyMess.dirty -= _delta
				
				if(bodyMess.dirty <= 0.0):
					Network.rpcClients(syncBodyMess_RPC.bind(charID, bodyMess.saveData()))
			
			var buffSyncState:SyncState = character.buffsHolder.syncState
			if(buffSyncState.getDirtyTime() >= 0.5):
				var dirtyData:=buffSyncState.getDelta()
				Network.rpcClients(syncBuffsState_RPC.bind(charID, dirtyData))
				buffSyncState.resetDelta()

@rpc("authority", "call_remote", "reliable")
func syncCharState_RPC(_characterID:String, _data:PackedByteArray):
	var theCharacter:BaseCharacter = getCharacter(_characterID)
	if(!theCharacter):
		return
	theCharacter.getCharState().syncState.applyDelta(_data)

@rpc("authority", "call_remote", "reliable")
func syncBuffsState_RPC(_characterID:String, _data:PackedByteArray):
	var theCharacter:BaseCharacter = getCharacter(_characterID)
	if(!theCharacter):
		return
	theCharacter.buffsHolder.syncState.applyDelta(_data)

@rpc("authority", "call_remote", "reliable")
func syncBodyMess_RPC(_characterID:String, _data:Dictionary):
	var theCharacter:BaseCharacter = getCharacter(_characterID)
	if(!theCharacter):
		return
	theCharacter.getBodyMess().loadData(_data)

func getSimpleGameTextParserText(_id:String, _command:String, _arg:String) -> SGTPResult:
	if(characters.has(_id)):
		return characters[_id].getSimpleGameTextParserText(_id, _command, _arg)
	return null

func saveNetworkData() -> Bins:
	var ar:Array = [
		Bins.I32, characters.size(),
	]
	for charID in characters:
		ar.append_array([Bins.StrShort, charID])
		ar.append_array([Bins.BINS, characters[charID].saveNetworkData()])
	
	return Bins.saveStartEnd(ar)

func loadNetworkData(_data:Bins):
	clearCharacters()
	_data.loadStart()
	var theCharAmount:int = _data.readI32()
	for _i in range(theCharAmount):
		var charID:String = _data.readStrShort()
		Log.Print("LOADING NETWORKED CHAR "+str(charID))
		var theChar:BaseCharacter=createCharacterCustomID(charID)
		theChar.loadNetworkData(_data.readBins())
	_data.endLoad()

func saveData() -> Dictionary:
	var charactersData:Dictionary = {}
	for charID in characters:
		charactersData[charID] = {
			data = characters[charID].saveData(),
		}
	
	return {
		characters = charactersData,
	}

func loadData(_data:Dictionary):
	clearCharacters()
	
	var newChars:Dictionary = SAVE.loadVar(_data, "characters", {})
	for charID in newChars:
		Log.Print("LOADING CHAR "+str(charID))
		var theChar:BaseCharacter=createCharacterCustomID(charID)
		theChar.loadData(SAVE.loadVar(newChars[charID], "data", {}))

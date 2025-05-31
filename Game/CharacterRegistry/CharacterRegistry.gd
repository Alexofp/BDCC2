extends Node
class_name CharacterRegistry

var characters:Dictionary = {}
var lastUniqueID:int = 0

signal characterAdded(charID, character)
signal characterRemoved(charID, character)

#signal onGenericPartChange(character, id, newpart)
#signal onGenericPartOptionChange(character, id, optionID, newvalue)

func _ready():
	GameInteractor.characterRegistry = self
	#Network.playerConnected.connect(onPlayerConnected)
	#set_multiplayer_authority(Network.getHostID())
	
	GameInteractor.registerOnServerCommand(InteractCommand.GIVE_BODYPART, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeInt, IntComArg.TypeInt, IntComArg.TypeString, IntComArg.TypeDict])
	GameInteractor.registerOnClientCommand(InteractCommand.GIVE_BODYPART, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeInt, IntComArg.TypeInt, IntComArg.TypeString, IntComArg.TypeDict])
	
	GameInteractor.registerOnServerCommand(InteractCommand.BODYPART_CHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeInt, IntComArg.TypeInt, IntComArg.TypeString, IntComArg.TypeAny])
	GameInteractor.registerOnClientCommand(InteractCommand.BODYPART_CHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeInt, IntComArg.TypeInt, IntComArg.TypeString, IntComArg.TypeAny])
	
	GameInteractor.registerOnServerCommand(InteractCommand.CHARACTER_BASESKINCHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeDict])
	GameInteractor.registerOnClientCommand(InteractCommand.CHARACTER_BASESKINCHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeDict])
	
	GameInteractor.registerOnServerCommand(InteractCommand.BODYPART_SKINCHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeInt, IntComArg.TypeString, IntComArg.TypeDict])
	GameInteractor.registerOnClientCommand(InteractCommand.BODYPART_SKINCHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeInt, IntComArg.TypeString, IntComArg.TypeDict])
	
	
	#GameInteractor.registerOnClientCommand(InteractCommand.GIVE_BODYPART, self, "onMyFunctioName", [IntComArgType.Int, IntComArgType.String, IntComArgType.Any])

#func onPlayerConnected(_id:int, _playerInfo:NetworkPlayerInfo):
	#if(Network.isServer() && Network.getMultiplayerID() != _id):
		#Log.Print("Sending full characters data to "+str(_id))
		#applyFullNetworkData.rpc_id(_id, saveFullNetworkData())

func handleNetworkCommand(_command:int, _clientID:int, _data:Array):
	var _isServer:bool = (_clientID!=1)
	
	if(_command == InteractCommand.GIVE_BODYPART):
		var theCharacter:BaseCharacter = getCharacter(_data[0])
		if(!theCharacter):
			return
		var bodypart:GenericPart
		if(_data[1] == BaseCharacter.GENERIC_BODYPARTS && _data[3] != ""):
			bodypart = GlobalRegistry.createBodypart(_data[3])
			bodypart.loadNetworkData(_data[4])
		theCharacter.addGenericPart(_data[1], _data[2], bodypart)
	
	if(_command == InteractCommand.BODYPART_CHANGE):
		var theCharacter:BaseCharacter = getCharacter(_data[0])
		if(!theCharacter):
			return
		var genericPart:GenericPart = theCharacter.getGenericPart(_data[1], _data[2])
		if(!genericPart):
			return
		genericPart.setOptionValue(_data[3], _data[4])
	
	if(_command == InteractCommand.CHARACTER_BASESKINCHANGE):
		var theCharacter:BaseCharacter = getCharacter(_data[0])
		if(!theCharacter):
			return
		var skinTypeData:SkinTypeData = SkinTypeData.new()
		skinTypeData.loadNetworkData(_data[2])
		theCharacter.setBaseSkinTypeData(_data[1], skinTypeData)
	
	if(_command == InteractCommand.BODYPART_SKINCHANGE):
		var theCharacter:BaseCharacter = getCharacter(_data[0])
		if(!theCharacter):
			return
		var skinTypeData:SkinTypeData
		if(!_data[3].is_empty()):
			skinTypeData = SkinTypeData.new()
			skinTypeData.loadNetworkData(_data[3])
		
		theCharacter.setSkinTypeForSlot(_data[1], _data[2])
		theCharacter.setSkinTypeDataForSlot(_data[1], skinTypeData)

func askCharacterChangeBaseSkinTypeData(character:BaseCharacter, newSkinType:String, newSkinTypeData:SkinTypeData):
	GameInteractor.doOnServer(InteractCommand.CHARACTER_BASESKINCHANGE, [character.getID(), newSkinType, newSkinTypeData.saveNetworkData() if newSkinTypeData else {}])

func onCharacterBaseSkinTypeChange(_skinType:String, skinTypeData:SkinTypeData, character:BaseCharacter):
	if(Network.isServerNotSingleplayer()):
		GameInteractor.doOnAllClients(InteractCommand.CHARACTER_BASESKINCHANGE, [character.getID(), _skinType, skinTypeData.saveNetworkData() if skinTypeData else {}])



func askCharacterPartChange(character:BaseCharacter, genericType:int, partSlot:int, _newPartID:String, _newPartData:Dictionary):
	#if(Network.isServer()):
		#var newpart:BodypartBase
		#if(_newPartID != ""):
			#newpart = GlobalRegistry.createBodypart(_newPartID)
			#if(newpart != null):
				#newpart.loadNetworkData(_newPartData)
		#character.addGenericPart(genericType, partSlot, newpart)
	#else:
	GameInteractor.doOnServer(InteractCommand.GIVE_BODYPART, [character.getID(), genericType, partSlot, _newPartID, _newPartData])

func onCharacterGenericPartChance(genericType:int, partSlot:int, newpart:GenericPart, character:BaseCharacter):
	if(Network.isServerNotSingleplayer()):
		GameInteractor.doOnAllClients(InteractCommand.GIVE_BODYPART, [character.getID(), genericType, partSlot, (newpart.id if newpart else ""), newpart.saveNetworkData() if newpart else {}])



func askCharacterPartOptionChange(character:BaseCharacter, genericType:int, partSlot:int, optionID:String, newvalue:Variant):
	GameInteractor.doOnServer(InteractCommand.BODYPART_CHANGE, [character.getID(), genericType, partSlot, optionID, newvalue])

func onCharacterGenericPartOptionChange(genericType:int, partSlot:int, optionID:String, newvalue:Variant, character:BaseCharacter):
	if(Network.isServerNotSingleplayer()):
		GameInteractor.doOnAllClients(InteractCommand.BODYPART_CHANGE, [character.getID(), genericType, partSlot, optionID, newvalue])



func askCharacterBodypartSkinTypeChange(character:BaseCharacter, partSlot:int, skinType:String, skinTypeData:SkinTypeData):
	GameInteractor.doOnServer(InteractCommand.BODYPART_SKINCHANGE, [character.getID(), partSlot, skinType, skinTypeData.saveNetworkData() if skinTypeData else {}])

func onCharacterBodypartSkinTypeChange(partSlot:int, skinType:String, _skinTypeData:SkinTypeData, character:BaseCharacter):
	if(Network.isServerNotSingleplayer()):
		var theBodypart:BodypartBase = character.getBodypart(partSlot)
		GameInteractor.doOnAllClients(InteractCommand.BODYPART_SKINCHANGE, [character.getID(), partSlot, skinType, theBodypart.skinDataOverride.saveNetworkData() if theBodypart.skinDataOverride else {}])


func askCharacterSyncOptionChange(character:BaseCharacter, optionID:String, theValue):
	if(Network.isServer()):
		character.applyCharChange(optionID, theValue)
	else:
		onCharacterSyncOptionChange_RPC.rpc_id(1, character.getID(), optionID, theValue)
		
func onCharacterSyncOptionChange(optionID:String, character:BaseCharacter):
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(onCharacterSyncOptionChange_RPC, [character.getID(), optionID, character.getSyncOptionValue(optionID)])

@rpc("any_peer", "call_remote", "reliable")
func onCharacterSyncOptionChange_RPC(charID:String, optionID:String, theValue):
	var theCharacter:BaseCharacter = getCharacter(charID)
	if(!theCharacter):
		return
	if(optionID in theCharacter.getSyncOptions()):
		theCharacter.applyCharChange(optionID, theValue)


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
	connectSignalsToCharacter(theChar)

func connectSignalsToCharacter(theChar:BaseCharacter):
	theChar.onGenericPartChange.connect(onCharacterGenericPartChance.bind(theChar))
	theChar.onGenericPartOptionChange.connect(onCharacterGenericPartOptionChange.bind(theChar))
	theChar.onBodypartSkinTypeChange.connect(onCharacterBodypartSkinTypeChange.bind(theChar))
	theChar.onBaseSkinTypeChange.connect(onCharacterBaseSkinTypeChange.bind(theChar))
	theChar.onCharOptionChange.connect(onCharacterSyncOptionChange.bind(theChar))
	pass




func createCharacter() -> BaseCharacter:
	var newID := generateNewUniqueID()
	return createCharacterCustomID(newID)

@rpc("authority", "call_remote", "reliable")
func createCharacter_RPC(theID:String, _data:Dictionary):
	var theChar:BaseCharacter = createCharacterCustomID(theID)
	theChar.loadNetworkData(_data)

func createCharacterCustomID(theID:String) -> BaseCharacter:
	var newChar:BaseCharacter = BaseCharacter.new()
	connectSignalsToCharacter(newChar)
	newChar.id = theID
	characters[theID] = newChar
	characterAdded.emit(theID, newChar)
	if(Network.isServerNotSingleplayer()):
		createCharacter_RPC.rpc(theID, newChar.saveNetworkData())
	return newChar

@rpc("authority", "call_remote", "reliable")
func removeCharacter_RPC(theID:String):
	removeCharacterID(theID)

func removeCharacterID(theCharID:String):
	if(!characters.has(theCharID)):
		Log.Printerr("Trying to remove a character that doesn't exist: '"+str(theCharID)+"'")
		return
	var theCharInfo:BaseCharacter = characters[theCharID]
	characters.erase(theCharID)
	characterRemoved.emit(theCharID, theCharInfo)
	if(Network.isServerNotSingleplayer()):
		removeCharacter_RPC.rpc(theCharID)

func clearCharacters():
	for charID in characters.keys():
		removeCharacterID(charID)

func askCharacterWizardSubmit(character:BaseCharacter, _data:Dictionary):
	if(Network.isServer()):
		characterWizardSubmitDo(character, _data)
	else:
		askCharacterWizardSubmit_RPC.rpc_id(1, character.getID(), _data)
		
@rpc("authority", "call_remote", "reliable")
func askCharacterWizardSubmit_RPC(characterID:String, _data:Dictionary):
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
	
func _process(_delta: float) -> void:
	for charID in characters: # TODO: process far-away npcs less often
		var character:BaseCharacter = characters[charID]
		character.processTime(_delta)
	
	if(Network.isServerNotSingleplayer()):
		for charID in characters:
			var character:BaseCharacter = characters[charID]
			var charState:CharState = character.getCharState()
			if(charState.getDirtyTime() >= 0.5):
				#print("DIRTY!")
				var dirtyData:=charState.getDirtyFieldsData()
				Network.rpcClients(syncCharState_RPC, [charID, dirtyData])
				
				charState.clearDirty()

			var bodyMess := character.getBodyMess()
			if(bodyMess.dirty > 0.0):
				bodyMess.dirty -= _delta
				
				if(bodyMess.dirty <= 0.0):
					Network.rpcClients(syncBodyMess_RPC, [charID, bodyMess.saveData()])

@rpc("authority", "call_remote", "reliable")
func syncCharState_RPC(_characterID:String, _data:Dictionary):
	var theCharacter:BaseCharacter = getCharacter(_characterID)
	if(!theCharacter):
		return
	theCharacter.getCharState().applyDirtyFieldsData(_data)

@rpc("authority", "call_remote", "reliable")
func syncBodyMess_RPC(_characterID:String, _data:Dictionary):
	var theCharacter:BaseCharacter = getCharacter(_characterID)
	if(!theCharacter):
		return
	theCharacter.getBodyMess().loadData(_data)

func saveNetworkData() -> Dictionary:
	var charactersData:Dictionary = {}
	for charID in characters:
		charactersData[charID] = {
			data = characters[charID].saveNetworkData(),
		}
	
	return {
		characters = charactersData,
	}

func loadNetworkData(_data:Dictionary):
	clearCharacters()
	
	var newChars:Dictionary = SAVE.loadVar(_data, "characters", {})
	for charID in newChars:
		Log.Print("LOADING CHAR "+str(charID))
		var theChar:BaseCharacter=createCharacterCustomID(charID)
		theChar.loadNetworkData(SAVE.loadVar(newChars[charID], "data", {}))

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
	
	GameInteractor.registerOnServerCommand(InteractCommand.GIVE_BODYPART, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeDict])
	GameInteractor.registerOnClientCommand(InteractCommand.GIVE_BODYPART, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeDict])
	
	GameInteractor.registerOnServerCommand(InteractCommand.BODYPART_CHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeAny])
	GameInteractor.registerOnClientCommand(InteractCommand.BODYPART_CHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeAny])
	
	GameInteractor.registerOnServerCommand(InteractCommand.CHARACTER_BASESKINCHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeDict])
	GameInteractor.registerOnClientCommand(InteractCommand.CHARACTER_BASESKINCHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeDict])
	
	GameInteractor.registerOnServerCommand(InteractCommand.BODYPART_SKINCHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeDict])
	GameInteractor.registerOnClientCommand(InteractCommand.BODYPART_SKINCHANGE, self, "handleNetworkCommand", GameInteractor.CALLTYPE_ARRAY, [IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeString, IntComArg.TypeDict])
	
	
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



func askCharacterPartChange(character:BaseCharacter, genericType:String, partSlot:String, _newPartID:String, _newPartData:Dictionary):
	#if(Network.isServer()):
		#var newpart:BodypartBase
		#if(_newPartID != ""):
			#newpart = GlobalRegistry.createBodypart(_newPartID)
			#if(newpart != null):
				#newpart.loadNetworkData(_newPartData)
		#character.addGenericPart(genericType, partSlot, newpart)
	#else:
	GameInteractor.doOnServer(InteractCommand.GIVE_BODYPART, [character.getID(), genericType, partSlot, _newPartID, _newPartData])

func onCharacterGenericPartChance(genericType:String, partSlot:String, newpart:GenericPart, character:BaseCharacter):
	if(Network.isServerNotSingleplayer()):
		GameInteractor.doOnAllClients(InteractCommand.GIVE_BODYPART, [character.getID(), genericType, partSlot, (newpart.id if newpart else ""), newpart.saveNetworkData() if newpart else {}])



func askCharacterPartOptionChange(character:BaseCharacter, genericType:String, partSlot:String, optionID:String, newvalue:Variant):
	GameInteractor.doOnServer(InteractCommand.BODYPART_CHANGE, [character.getID(), genericType, partSlot, optionID, newvalue])

func onCharacterGenericPartOptionChange(genericType:String, partSlot:String, optionID:String, newvalue:Variant, character:BaseCharacter):
	if(Network.isServerNotSingleplayer()):
		GameInteractor.doOnAllClients(InteractCommand.BODYPART_CHANGE, [character.getID(), genericType, partSlot, optionID, newvalue])



func askCharacterBodypartSkinTypeChange(character:BaseCharacter, partSlot:String, skinType:String, skinTypeData:SkinTypeData):
	GameInteractor.doOnServer(InteractCommand.BODYPART_SKINCHANGE, [character.getID(), partSlot, skinType, skinTypeData.saveNetworkData() if skinTypeData else {}])

func onCharacterBodypartSkinTypeChange(partSlot:String, skinType:String, _skinTypeData:SkinTypeData, character:BaseCharacter):
	if(Network.isServerNotSingleplayer()):
		var theBodypart:BodypartBase = character.getBodypart(partSlot)
		GameInteractor.doOnAllClients(InteractCommand.BODYPART_SKINCHANGE, [character.getID(), partSlot, skinType, theBodypart.skinDataOverride.saveNetworkData() if theBodypart.skinDataOverride else {}])



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

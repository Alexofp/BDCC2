extends RefCounted
class_name CharacterPreset

var bodyparts:Dictionary = {}
var skinTypes:SkinTypeProfile = SkinTypeProfile.new()

var charName:String = "New character"
var lastCharName:String = ""
var gender:GenderPronounsProfile = GenderPronounsProfile.new()
var species:SpeciesProfile = SpeciesProfile.new()
var bodySize:float = 0.0
var thickness:float = 1.0 #0 = thin, 2 = thick
var chubbyness:float = 0.0
var buttSize:float = 0.0
var smoothBody:float = 0.0
var muscles:float = 0.0
var voice:VoiceProfile = VoiceProfile.new()
var walkAnim:String = Doll.WALK_UNISEX
var idleAnim:String = Doll.IDLE_NORMAL1

# no sync
var embedded:bool = false
var filename:String = ""
# end no sync

func getEditorName() -> String:
	if(filename != ""):
		return filename.get_basename().get_file()
	return charName

func loadFromCharacter(_char:BaseCharacter):
	bodyparts.clear()
	for bodypartSlot in _char.bodyparts:
		var bodypartSlotString:String = BodypartSlot.slotToString(bodypartSlot)
		if(bodypartSlotString == ""):
			continue
		var theBodypart:BodypartBase = _char.bodyparts[bodypartSlot]
		bodyparts[bodypartSlotString] = {
			id = theBodypart.id,
			data = theBodypart.saveData(),
		}
	
	skinTypes.loadData(_char.skinTypes.saveData().duplicate(true))
	
	charName = _char.charName
	lastCharName = _char.lastCharName
	gender.loadData(_char.gender.saveData())
	species.loadData(_char.species.saveData())
	bodySize = _char.bodySize
	thickness = _char.thickness
	chubbyness = _char.chubbyness
	buttSize = _char.buttSize
	smoothBody = _char.smoothBody
	muscles = _char.muscles
	voice.loadData(_char.voice.saveData())
	walkAnim = _char.walkAnim
	idleAnim = _char.idleAnim

func applyToCharacter(_char:BaseCharacter):
	_char.applyCharChange(CharOption.name, charName)
	_char.applyCharChange(CharOption.lastName, lastCharName)
	_char.applyCharChange(CharOption.gender, gender.saveData())
	_char.applyCharChange(CharOption.species, species.saveData())
	_char.applyCharChange(CharOption.bodySize, bodySize)
	_char.applyCharChange(CharOption.thickness, thickness)
	_char.applyCharChange(CharOption.chubbyness, chubbyness)
	_char.applyCharChange(CharOption.buttSize, buttSize)
	_char.applyCharChange(CharOption.smoothBody, smoothBody)
	_char.applyCharChange(CharOption.muscles, muscles)
	_char.applyCharChange(CharOption.voice, voice.saveData())
	_char.applyCharChange(CharOption.walkAnim, walkAnim)
	_char.applyCharChange(CharOption.idleAnim, idleAnim)
	
	for bodypartSlot in _char.bodyparts.keys():
		_char.removeGenericPart(BaseCharacter.GENERIC_BODYPARTS, bodypartSlot)
		
	_char.skinTypes.loadData(skinTypes.saveData().duplicate(true))
		
	for bodypartSlotString in bodyparts:
		var bodypartSlot:int = BodypartSlot.slotFromString(bodypartSlotString)
		if(bodypartSlot < 0):
			continue
		var theBodypartEntry:Dictionary = bodyparts[bodypartSlotString]
		var theBodypartID:String = theBodypartEntry["id"] if theBodypartEntry.has("id") else ""
		if(theBodypartID == ""):
			continue
		var theBodypart:BodypartBase = GlobalRegistry.createBodypart(theBodypartID)
		if(!theBodypart):
			continue
		theBodypart.loadData(theBodypartEntry["data"] if theBodypartEntry.has("data") else {})
		_char.addBodypart(bodypartSlot, theBodypart)
	
	_char.notifyPresetApplied()
	
func saveData() -> Dictionary:
	return {
		bodyparts = bodyparts,
		skinTypes = skinTypes.saveData(),
		
		charName = charName,
		lastCharName = lastCharName,
		gender = gender.saveData(),
		species = species.saveData(),
		bodySize = bodySize,
		thickness = thickness,
		chubbyness = chubbyness,
		buttSize = buttSize,
		smoothBody = smoothBody,
		muscles = muscles,
		voice = voice.saveData(),
		walkAnim = walkAnim,
		idleAnim = idleAnim,
	}

func loadData(_data:Dictionary):
	bodyparts = SAVE.loadVar(_data, "bodyparts", {})
	skinTypes.loadData(SAVE.loadVar(_data, "skinTypes", {}))
	
	charName = SAVE.loadVar(_data, "charName", "New character")
	lastCharName = SAVE.loadVar(_data, "lastCharName", "")
	gender.loadData(SAVE.loadVar(_data, "gender", {}))
	species.loadData(SAVE.loadVar(_data, "species", {}))
	bodySize = SAVE.loadVar(_data, "bodySize", 0.0)
	thickness = SAVE.loadVar(_data, "thickness", 1.0)
	chubbyness = SAVE.loadVar(_data, "chubbyness", 0.0)
	buttSize = SAVE.loadVar(_data, "buttSize", 0.0)
	smoothBody = SAVE.loadVar(_data, "smoothBody", 0.0)
	muscles = SAVE.loadVar(_data, "muscles", 0.0)
	voice.loadData(SAVE.loadVar(_data, "voice", {}))
	walkAnim = SAVE.loadVar(_data, "walkAnim", Doll.WALK_UNISEX)
	idleAnim = SAVE.loadVar(_data, "idleAnim", Doll.IDLE_NORMAL1)

func saveToFile(path:String) -> bool:
	var newPreset:CharacterPresetResource = CharacterPresetResource.new()
	newPreset.data = saveData()
	filename = path
	
	return ResourceSaver.save(newPreset, path) == OK

func savePreset(name:String) -> bool:
	name = Util.sanitizeFileName(name)
	if(name == ""):
		return false
	return saveToFile(CharacterPresetHolder.USERPRESETS_FOLDER.path_join(name+".tres"))

func loadFromFile(path:String) -> bool:
	var thePresetResource = ResourceLoader.load(path)
	if(!thePresetResource || !(thePresetResource is CharacterPresetResource)):
		return false
	
	loadData(thePresetResource.data)
	filename = path
	
	return true

func loadPreset(name:String) -> bool:
	return loadFromFile(CharacterPresetHolder.USERPRESETS_FOLDER.path_join(name+".tres"))

func canBeEdited() -> bool:
	return filename.begins_with("user://")

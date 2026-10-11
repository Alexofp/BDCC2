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
var idleAnim:String = "IdleUnisex"
var walkAnim:String = "WalkUnisex"

var personality:Personality = Personality.new()
var fetishHolder:FetishHolder = FetishHolder.new()

# no sync
var embedded:bool = false
var filename:String = ""
var generated:bool = false
# end no sync

func getDescriptionLines(_showSpoilers:bool=true) -> Array[String]:
	var _idlePose:DollAnimBase = GlobalRegistry.getDollAnim(idleAnim)
	var _walkPose:DollAnimBase = GlobalRegistry.getDollAnim(walkAnim)
	
	var theLines:Array[String] = [
		"Name: "+str(charName)
	]
	if(!lastCharName.is_empty()):
		theLines.append("Last name: "+str(lastCharName))
	theLines.append("Gender: "+gender.getEditorName())
	theLines.append("Species: "+species.getName())
	theLines.append("")
	theLines.append("Voice: "+voice.getEditorName())
	theLines.append("Idle type: "+(_idlePose.getVisibleName(idleAnim) if _idlePose else idleAnim))
	theLines.append("Walk type: "+(_walkPose.getVisibleName(walkAnim) if _walkPose else walkAnim))
	theLines.append("")
	theLines.append("Personality:")
	for _stat:String in GlobalRegistry.personalityStats:
		var _persStat:PersonalityStatBase = GlobalRegistry.personalityStats[_stat]
		var _am:float = personality.getStat(_stat)
		if(_showSpoilers):
			theLines.append(_persStat.getVisibleName()+": "+str(Util.roundF(_am*100.0, 1))+"%")
		else:
			theLines.append(_persStat.getVisibleName()+": hidden")
	
	theLines.append("")
	theLines.append("Fetishes:")
	for _fetish:String in GlobalRegistry.fetishes:
		var _fetishRef:FetishBase = GlobalRegistry.fetishes[_fetish]
		var _amPerf:float = fetishHolder.getPerforming(_fetish)
		var _amRec:float = fetishHolder.getReceiving(_fetish)
		if(_showSpoilers):
			theLines.append(_fetishRef.getVisibleName())
			theLines.append("- Performing: "+str(Util.roundF(_amPerf*100.0, 1))+"%")
			theLines.append("- Receiving: "+str(Util.roundF(_amRec*100.0, 1))+"%")
		else:
			theLines.append(_fetishRef.getVisibleName()+": hidden")
		
	return theLines

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
	gender.loadData(_char.gender.saveData().duplicate(true))
	species.loadData(_char.species.saveData().duplicate(true))
	bodySize = _char.bodySize
	thickness = _char.thickness
	chubbyness = _char.chubbyness
	buttSize = _char.buttSize
	smoothBody = _char.smoothBody
	muscles = _char.muscles
	voice.loadData(_char.voice.saveData().duplicate(true))
	walkAnim = _char.walkAnim
	idleAnim = _char.idleAnim
	personality.loadData(_char.personality.saveData().duplicate(true))
	fetishHolder.loadData(_char.fetishHolder.saveData().duplicate(true))

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
	_char.personality.loadData(personality.saveData().duplicate(true))
	_char.fetishHolder.loadData(fetishHolder.saveData().duplicate(true))
		
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
		personality = personality.saveData(),
		fetishHolder = fetishHolder.saveData(),
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
	idleAnim = SAVE.loadVar(_data, "idleAnim", "IdleUnisex")
	if(!GlobalRegistry.getDollAnim(idleAnim)):
		idleAnim = "IdleUnisex"
	walkAnim = SAVE.loadVar(_data, "walkAnim", "WalkUnisex")
	if(!GlobalRegistry.getDollAnim(walkAnim)):
		walkAnim = "WalkUnisex"
	if(_data.has("personality")):
		personality.loadData(SAVE.loadVar(_data, "personality", {}))
	if(_data.has("fetishHolder")):
		fetishHolder.loadData(SAVE.loadVar(_data, "fetishHolder", {}))

func makeCopy() -> CharacterPreset:
	var _newPreset:CharacterPreset = CharacterPreset.new()
	_newPreset.loadData(saveData().duplicate(true))
	_newPreset.filename = filename
	_newPreset.embedded = embedded
	_newPreset.generated = generated
	return _newPreset

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

func setFilenameUserPreset(_name:String) -> bool:
	_name = Util.sanitizeFileName(_name)
	if(_name == ""):
		return false
	filename = CharacterPresetHolder.USERPRESETS_FOLDER.path_join(_name+".tres")
	return true

func doSave() -> bool:
	if(filename.is_empty() || embedded):
		return false
	return saveToFile(filename)

func doLoad() -> bool:
	if(filename.is_empty() || embedded):
		return false
	return loadFromFile(filename)

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

func doResetToDefaultPC():
	var newChar:BaseCharacter = BaseCharacter.new()
	newChar.resetToDefaultPCCharacter()
	loadFromCharacter(newChar)

func doRandomize(_settings:RandomizeSettingsHolder = null):
	if(!_settings):
		_settings = RandomizeSettingsHolder.new()#randomize_settings_list.settings
	var theGen := CharacterGenerator.new()
	_settings.apply(theGen)
	var newChar:BaseCharacter = BaseCharacter.new()
	theGen.generate(newChar)
	loadFromCharacter(newChar)

func isSameAs(_otherPreset:CharacterPreset) -> bool:
	if(_otherPreset == self):
		return true
	if(filename != _otherPreset.filename || filename.is_empty()):
		return false
	#if(charName != _otherPreset.charName):
	#	return false
	return true

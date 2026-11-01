extends RefCounted
class_name StartGameCharHolder

var preset:CharacterPreset
var charType:int = CharacterType.InmateGeneral

func _init() -> void:
	checkPreset()
	#Network.rpcClients(notifyPresetApplied_RPC.bind(character.getID()))
	#character.notifyPresetApplied()
	#GM.characterRegistry.askRandomizeCharacter(character, theSettings)
	if(GM.presets):
		GM.presets.onPresetsRescanned.connect(updatePreset)

func checkPreset():
	if(preset):
		return
	# Shouldn't really happen
	preset = CharacterPreset.new()
	preset.charName = "TEST"
	preset.lastCharName = "MEW"
	preset.generated = true
	preset.embedded = true

func doRandomize():
	checkPreset()
	preset.doRandomize()
	var pickedCharType:CharacterTypeBase = RNG.pickWeightedDict(GlobalRegistry.characterTypeToScore)
	charType = pickedCharType.id if pickedCharType else CharacterType.InmateGeneral

func doResetToDefaultPC():
	checkPreset()
	preset.doResetToDefaultPC()
	charType = CharacterType.InmateGeneral

func isReady() -> bool:
	if(!preset):
		return false
	return true

func isReadyGetReason() -> String:
	if(!preset):
		return "Player preset wasn't picked"
	return ""

func updatePreset():
	if(!GM.presets):
		return
	preset = GM.presets.findPreset(preset)

func getPopulationListName() -> String:
	if(!preset):
		return "!NULL PRESET!"
	return preset.charName+("" if preset.lastCharName.is_empty() else (" "+preset.lastCharName))

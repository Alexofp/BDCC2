extends RefCounted
class_name StartGameCharHolder

var preset:CharacterPreset
# Char type?

func _init() -> void:
	preset = CharacterPreset.new()
	preset.charName = "TEST"
	preset.lastCharName = "MEW"
	#preset.doRandomize()
	preset.generated = true
	preset.embedded = true
	#Network.rpcClients(notifyPresetApplied_RPC.bind(character.getID()))
	#character.notifyPresetApplied()
	#GM.characterRegistry.askRandomizeCharacter(character, theSettings)
	if(GM.presets):
		GM.presets.onPresetsRescanned.connect(updatePreset)
	
func doRandomize():
	preset.doRandomize()

func doResetToDefaultPC():
	preset.doResetToDefaultPC()

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

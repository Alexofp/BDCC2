extends VBoxContainer

@onready var preset_pack_selector: OptionButton = %PresetPackSelector
@onready var preset_list: ItemList = %PresetList

var selectedPack:CharacterPresetPack = null
var presets:Array[CharacterPreset] = []
var selectedPreset:CharacterPreset = null

func _ready() -> void:
	updatePackSelectorList()
	updatePresetList()

func setSelectedPack(_pack:CharacterPresetPack):
	selectedPack = _pack
	updatePackSelectorList()
	updatePresetList()

func setSelectedPreset(_preset:CharacterPreset):
	if(!_preset):
		selectedPreset = null
		updatePresetList()
		return
	for preset in GM.presets.userPresets:
		if(preset == _preset):
			selectedPreset = _preset
			selectedPack = null
			updatePackSelectorList()
			updatePresetList()
			return
	
	for pack in GM.presets.packs:
		for preset in pack.presets:
			if(preset == _preset):
				selectedPreset = _preset
				selectedPack = pack
				updatePackSelectorList()
				updatePresetList()
				return

func updateAll():
	updatePackSelectorList()
	updatePresetList()

func updatePackSelectorList():
	preset_pack_selector.clear()
	
	preset_pack_selector.add_item("User presets")
	if(!selectedPack):
		preset_pack_selector.select(0)
	
	var _i:int = 1
	for pack in GM.presets.packs:
		var packName:String = pack.getEditorName()
		
		preset_pack_selector.add_item(packName)
		if(selectedPack == pack):
			preset_pack_selector.select(_i)
		_i += 1

func updatePresetList():
	preset_list.clear()
	
	presets = GM.presets.userPresets if !selectedPack else selectedPack.presets
	
	var _i:int = 0
	for preset in presets:
		preset_list.add_item(preset.getEditorName())
		if(preset == selectedPreset):
			preset_list.select(_i)
		_i += 1

func _on_preset_pack_selector_item_selected(_index: int) -> void:
	if(_index < 0 || _index > GM.presets.packs.size()):
		return
	
	selectedPreset = null
	if(_index == 0):
		selectedPack = null
	else:
		selectedPack = GM.presets.packs[_index-1]
	
	updatePresetList()

func _on_preset_list_item_selected(_index: int) -> void:
	if(_index < 0 || _index >= presets.size()):
		return
	selectedPreset = presets[_index]

func getSelectedPreset() -> CharacterPreset:
	return selectedPreset

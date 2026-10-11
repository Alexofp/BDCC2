extends VBoxContainer

@onready var preset_pack_selector: OptionButton = %PresetPackSelector
@onready var preset_list: ItemList = %PresetList

const SELECTED_ALL = 0
const SELECTED_USER = 1
const SELECTED_PACK = 2

var selectedMode:int = SELECTED_ALL
var selectedPack:CharacterPresetPack = null
var presets:Array[CharacterPreset] = []
var selectedPreset:CharacterPreset = null
var extraPresets:Array[CharacterPreset] = []

signal onPresetSelected(_preset:CharacterPreset)

func _ready() -> void:
	if(!GM.presets):
		await GlobalRegistry.initialized
	
	updatePackSelectorList()
	updatePresetList()
	GM.presets.onPresetsRescanned.connect(updateAll)

func setSelectedPack(_pack:CharacterPresetPack):
	selectedMode = SELECTED_PACK
	selectedPack = _pack
	updatePackSelectorList()
	updatePresetList()

func setSelectedPresetByPath(_path:String, _callSignal:bool = false, _alwaysSelectAll:bool = false):
	if(_path.is_empty()):
		return
	for preset in GM.presets.userPresets:
		if(preset.filename == _path):
			setSelectedPreset(preset, _callSignal, _alwaysSelectAll)
			return
	for pack in GM.presets.packs:
		for preset in pack.presets:
			if(preset.filename == _path):
				setSelectedPreset(preset, _callSignal, _alwaysSelectAll)
				return
	for preset in extraPresets:
		if(preset.filename == _path):
			setSelectedPreset(preset, _callSignal, _alwaysSelectAll)
			return
	
func setSelectedPreset(_preset:CharacterPreset, _callSignal:bool = false, _alwaysSelectAll:bool = false):
	if(!_preset):
		selectedMode = SELECTED_ALL
		selectedPreset = null
		updatePresetList()
		if(_callSignal):
			onPresetSelected.emit(null)
		return
	for preset:CharacterPreset in extraPresets:
		if(preset == _preset):
			selectedMode = SELECTED_ALL
			selectedPreset = _preset
			selectedPack = null
			updatePackSelectorList()
			updatePresetList()
			if(_callSignal):
				onPresetSelected.emit(selectedPreset)
			return
	
	for preset in GM.presets.userPresets:
		if(preset == _preset):
			selectedMode = SELECTED_USER if !_alwaysSelectAll else SELECTED_ALL
			selectedPreset = _preset
			selectedPack = null
			updatePackSelectorList()
			updatePresetList()
			if(_callSignal):
				onPresetSelected.emit(selectedPreset)
			return
	
	for pack in GM.presets.packs:
		for preset in pack.presets:
			if(preset == _preset):
				selectedMode = SELECTED_PACK if !_alwaysSelectAll else SELECTED_ALL
				selectedPreset = _preset
				selectedPack = pack if !_alwaysSelectAll else null
				updatePackSelectorList()
				updatePresetList()
				if(_callSignal):
					onPresetSelected.emit(selectedPreset)
				return

func updateAll():
	updatePackSelectorList()
	updatePresetList()

func updatePackSelectorList():
	preset_pack_selector.clear()
	
	preset_pack_selector.add_item("All")
	preset_pack_selector.add_item("User presets")
	
	if(selectedMode == SELECTED_ALL):
		preset_pack_selector.select(0)
	if(selectedMode == SELECTED_USER):
		preset_pack_selector.select(1)
	
	var _i:int = 2
	for pack in GM.presets.packs:
		var packName:String = pack.getEditorName()
		
		preset_pack_selector.add_item(packName)
		if(selectedPack == pack):
			preset_pack_selector.select(_i)
		_i += 1

func updatePresetList():
	preset_list.clear()
	
	var presetNames:Array[String] = []
	
	if(selectedMode == SELECTED_ALL):
		presets = []
		presets.append_array(extraPresets)
		for preset in extraPresets:
			presetNames.append("Generated")
			
		presets.append_array(GM.presets.userPresets)
		for preset in GM.presets.userPresets:
			presetNames.append("User presets")
			
		for pack in GM.presets.packs:
			presets.append_array(pack.getPresets())
			for preset in pack.getPresets():
				presetNames.append(pack.getEditorName())
	elif(selectedMode == SELECTED_USER):
		presets = GM.presets.userPresets
	else:
		presets = selectedPack.presets
	
	var _am:int = presetNames.size()
	var _i:int = 0
	for preset in presets:
		if(_i < _am):
			preset_list.add_item(presetNames[_i]+"/"+preset.getEditorName())
		else:
			preset_list.add_item(preset.getEditorName())
		if(preset == selectedPreset):
			preset_list.select(_i)
		_i += 1

func _on_preset_pack_selector_item_selected(_index: int) -> void:
	if(_index < 0 || (_index-2) >= GM.presets.packs.size()):
		return
	
	selectedPreset = null
	if(_index == 0):
		selectedMode = SELECTED_ALL
		selectedPack = null
	elif(_index == 1):
		selectedMode = SELECTED_USER
		selectedPack = null
	else:
		selectedMode = SELECTED_PACK
		selectedPack = GM.presets.packs[_index-2]
	
	updatePresetList()

func _on_preset_list_item_selected(_index: int) -> void:
	if(_index < 0 || _index >= presets.size()):
		return
	selectedPreset = presets[_index]
	onPresetSelected.emit(selectedPreset)

func getSelectedPreset() -> CharacterPreset:
	return selectedPreset

func setExtraPresets(_presets:Array[CharacterPreset]):
	extraPresets = _presets
	updatePresetList()

extends RefCounted
class_name CharacterPresetHolder

const USERPRESETS_FOLDER = "user://Game/UserPresets/"

var packs:Array[CharacterPresetPack] = []
var userPresets:Array[CharacterPreset] = []

func _init() -> void:
	Util.createFolder(USERPRESETS_FOLDER)
	rescanUserPresets()
	loadPacks()
	pass

func loadPacks():
	var packScriptFiles:Array = Util.getScriptsInFolderSmart("res://Presets/", false, true, false)
	
	for filepath in packScriptFiles:
		var thePack = load(filepath).new()
		if(!(thePack is CharacterPresetPack)):
			continue
		
		var theFolder:String = filepath.get_base_dir()
		thePack.filename = filepath
		thePack.presets = loadPacksFromFolder(theFolder)
		packs.append(thePack)

func loadPacksFromFolder(_folder:String) -> Array[CharacterPreset]:
	var result:Array[CharacterPreset] = []
	var thePaths := Util.getFilesInFolderSmart(_folder, "tres", true, false, false)
	
	for path in thePaths:
		var thePreset:CharacterPreset = CharacterPreset.new()
		if(!thePreset.loadFromFile(path)):
			continue
		result.append(thePreset)
	return result

func rescanUserPresets():
	userPresets = loadPacksFromFolder(USERPRESETS_FOLDER)
	#userPresets.clear()
	#
	#var thePaths := Util.getFilesInFolderSmart(USERPRESETS_FOLDER, "tres", true, false, false)
	#
	#for path in thePaths:
		#var thePreset:CharacterPreset = CharacterPreset.new()
		#if(!thePreset.loadFromFile(path)):
			#continue
		#userPresets.append(thePreset)

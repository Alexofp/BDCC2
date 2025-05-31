extends Node
class_name GlobalSettings

const SettingsPath = "user://settings.bdcc2"

var graphics:GraphicsSettings = GraphicsSettings.new()
var sounds:SoundSettings = SoundSettings.new()

signal changedCharTextureQuality

#func _init() -> void:
	#GlobalRegistry.doInit()

func _ready() -> void:
	if(!ShaderPrecompScreen.didPrecomp && ProjectSettings.get("BDCC2/precompile_shaders")): # && false
		doPrecomp.call_deferred()
		return
	loadFromFile()

func doPrecomp():
	get_tree().change_scene_to_file("res://UI/ShaderPrecompScreen/shader_precomp_screen.tscn")
	loadFromFile()

func saveData() -> Dictionary:
	return {
		graphics = graphics.saveData(),
		sounds = sounds.saveData(),
	}

func loadData(_data:Dictionary):
	graphics.loadData(loadVar(_data, "graphics", {}))
	sounds.loadData(loadVar(_data, "sounds", {}))
	
	graphics.applyAllSettings()
	sounds.applyAllSettings()

func loadVar(_data:Dictionary, keyID:String, defaultValue:Variant):
	if(!_data.has(keyID)):
		return defaultValue
	return _data[keyID]

func saveToFile():
	var theData:Dictionary = saveData()
	
	var dataString:String = var_to_str(theData)
	
	var file := FileAccess.open(SettingsPath, FileAccess.WRITE)
	if(file == null):
		Log.error("FAILED TO SAVE SETTINGS: ERROR "+str(FileAccess.get_open_error()))
		return
	file.store_string(dataString)

func loadFromFile():
	if(!FileAccess.file_exists(SettingsPath)):
		Log.Print("Settings file doesn't exist. Game is gonna use default settings.")
		loadData({})
		return
	var file := FileAccess.open(SettingsPath, FileAccess.READ)
	if(file == null):
		Log.error("FAILED TO LOAD SETTINGS: ERROR "+str(FileAccess.get_open_error()))
		return
	var dataString:String = file.get_as_text()
	
	var theDataVar:Variant = str_to_var(dataString)
	if(!(theDataVar is Dictionary)):
		Log.error("FAILED TO LOAD SETTINGS: WRONG FORMAT")
		return
		
	loadData(theDataVar)

var isSavingSettings:bool = false
func triggerSettingsSave(instant:bool = false):
	if(instant):
		saveToFile()
		isSavingSettings = false
		return
	if(isSavingSettings):
		return
	
	isSavingSettings = true
	await get_tree().create_timer(0.1).timeout
	if(isSavingSettings):
		saveToFile()
	isSavingSettings = false

func triggerCharTextureQualityChange():
	changedCharTextureQuality.emit()

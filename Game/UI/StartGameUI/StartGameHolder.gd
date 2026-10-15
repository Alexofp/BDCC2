extends RefCounted
class_name StartGameHolder

var gameModeDef:GameModeDef
var multiplayer:StartGameMultiplayer = StartGameMultiplayer.new()
var playerPreset:StartGameCharHolder = StartGameCharHolder.new()
var population:Array[StartGameCharHolder] = []

func _init() -> void:
	playerPreset.doResetToDefaultPC()

func updateHolder():
	if(!gameModeDef):
		return

	var _popAm:int = gameModeDef.getPopulationSize()
	while(population.size() > _popAm && !population.is_empty()):
		population.pop_back()
	while(population.size() < _popAm):
		var _newChar:StartGameCharHolder = StartGameCharHolder.new()
		_newChar.doRandomize()
		population.append(_newChar)

func isReadyGetReason() -> String:
	if(!gameModeDef):
		return "Game mode is missing"
	if(!playerPreset):
		return "Player preset holder is somehow missing"
	var _prReadyReason:String = playerPreset.isReadyGetReason()
	if(!_prReadyReason.is_empty()):
		return _prReadyReason
	for theCharHolder:StartGameCharHolder in population:
		var theCharReadyReason:String = theCharHolder.isReadyGetReason()
		if(!theCharReadyReason.is_empty()):
			return theCharReadyReason
	return ""

func resetToDefault():
	gameModeDef = GlobalRegistry.createGameModeDef(GameMode.Sandbox)

func getFirstTabSettings() -> Dictionary:
	var theGameModesValues:Array = []
	for theGameModeID:String in GlobalRegistry.getGameModeDefRefs():
		var theGameModeDefRef:GameModeDef = GlobalRegistry.getGameModeDefRef(theGameModeID)
		theGameModesValues.append([theGameModeID, theGameModeDefRef.getName()])
	
	var result:Dictionary = {
		"gamemode": {
			name = "Game mode",
			type = "selector",
			value = gameModeDef.id if gameModeDef else "- nothing -",
			values = theGameModesValues,
		},
	}
	return result

func applyFirstTabSetting(_settingID:String, _value) -> bool:
	if(_settingID == "gamemode"):
		gameModeDef = GlobalRegistry.createGameModeDef(_value)
	return false

func getSecondTabSettings() -> Dictionary:
	return gameModeDef.getSettings() if gameModeDef else {}

func applySecondTabSetting(_settingID:String, _value) -> bool:
	if(gameModeDef):
		return gameModeDef.applySetting(_settingID, _value)
	return false

#func createGameMode() -> GameModeBase:
#	var theScene:PackedScene = load(gameModeDef.scenePath)
#	return theScene.instantiate()

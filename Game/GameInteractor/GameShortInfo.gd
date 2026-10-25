extends RefCounted
class_name GameShortInfo

var prisonName:String = "BDCC"
var playerName:String = "Unknown"
var gameModeID:String = GameMode.Sandbox
var mapPath:String = ""
var timePlayed:int = 0 # Seconds
var gameVersion:String = "0.0.0"

var savePath:String = "" # no save
var corrupted:bool = false # no save

func saveData() -> Dictionary:
	return {
		prisonName = prisonName,
		playerName = playerName,
		gameModeID = gameModeID,
		mapPath = mapPath,
		timePlayed = timePlayed,
		gameVersion = gameVersion,
	}

func loadData(_data:Dictionary):
	prisonName = SAVE.loadStr(_data, "prisonName", "BDCC")
	playerName = SAVE.loadStr(_data, "playerName", "Unknown")
	gameModeID = SAVE.loadStr(_data, "gameModeID", GameMode.Sandbox)
	mapPath = SAVE.loadStr(_data, "mapPath")
	timePlayed = SAVE.loadInt(_data, "timePlayed")
	gameVersion = SAVE.loadStr(_data, "gameVersion", "0.0.0")

static func tryGetInfoFromSavePath(_path:String, _getCorruptOnError:bool = true) -> GameShortInfo:
	var theFile:FileAccess = FileAccess.open(_path, FileAccess.READ)
	if(!theFile):
		return null
	var theCorruptInfo:GameShortInfo = GameShortInfo.new()
	theCorruptInfo.corrupted = true
	theCorruptInfo.savePath = _path
	var theFirstLine:String = theFile.get_line()
	if(theFirstLine.strip_edges() != "{"):
		return theCorruptInfo if _getCorruptOnError else null
	var secondLineMustBe:String = "\""+MainScene.GAME_INFO_KEY+"\": {"
	if(theFile.get_line().strip_edges() != secondLineMustBe):
		return theCorruptInfo if _getCorruptOnError else null
	var theLines:Array[String] = ["{"]
	var _foundDicts:int = 1
	var _tooMany:int = 100
	while(_tooMany > 0 && !theFile.eof_reached()): # Janky but ehh. Just don't store anything complicated in the info tab
		var theLine:String = theFile.get_line()
		if(theLine.is_empty()):
			break
		if(theLine.ends_with("{")):
			_foundDicts += 1
		if(theLine == "},"):
			if(_foundDicts > 0):
				_foundDicts -= 1
			if(_foundDicts <= 0):
				break
		theLines.append(theLine)
		_tooMany -= 1
	theLines.append("}")
	
	var theInfoVarRaw = str_to_var(Util.join(theLines, "\n"))
	if(!(theInfoVarRaw is Dictionary)):
		return theCorruptInfo if _getCorruptOnError else null
	var theInfoVar:Dictionary = theInfoVarRaw
	var theInfo:GameShortInfo = GameShortInfo.new()
	theInfo.savePath = _path
	theInfo.loadData(theInfoVar)
	return theInfo

func getGameModeName() -> String:
	var theGameMode:GameModeDef = GlobalRegistry.getGameModeDefRef(gameModeID)
	if(!theGameMode):
		return "Unknown:"+gameModeID
	return theGameMode.getName()

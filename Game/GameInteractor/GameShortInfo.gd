extends RefCounted
class_name GameShortInfo

var prisonName:String = "BDCC"
var playerName:String = "Unknown"
var gameModeID:String = GameMode.Sandbox
var mapID:String = ""
var timePlayed:int = 0 # Seconds
var gameVersion:String = "0.0.0"
var charAmount:int = 0

var savePath:String = "" # no save
var corrupted:bool = false # no save

func saveData() -> Dictionary:
	return {
		prisonName = prisonName,
		playerName = playerName,
		gameModeID = gameModeID,
		mapID = mapID,
		timePlayed = timePlayed,
		gameVersion = gameVersion,
		charAmount = charAmount,
	}

func loadData(_data:Dictionary):
	prisonName = SAVE.loadStr(_data, "prisonName", "BDCC")
	playerName = SAVE.loadStr(_data, "playerName", "Unknown")
	gameModeID = SAVE.loadStr(_data, "gameModeID", GameMode.Sandbox)
	mapID = SAVE.loadStr(_data, "mapID")
	timePlayed = SAVE.loadInt(_data, "timePlayed")
	gameVersion = SAVE.loadStr(_data, "gameVersion", "0.0.0")
	charAmount = SAVE.loadInt(_data, "charAmount", 0)

func getInfoLinesSmall() -> Array[String]:
	var theLines:Array[String]
	if(corrupted):
		theLines.append(prisonName+" (!CORRUPTED!)")
		theLines.append(savePath.get_file())
		return theLines
	theLines.append(prisonName+" ("+getGameModeName()+")")
	theLines.append(playerName+" (Time played: "+str(Util.getTimeStringShort(timePlayed))+")")
	return theLines

func getInfoLinesFull() -> Array[String]:
	var theLines:Array[String]
	if(corrupted):
		theLines.append(prisonName+" (!CORRUPTED!)")
		theLines.append(savePath.get_file())
		return theLines
	theLines.append("Name: "+prisonName)
	theLines.append("Game mode: "+getGameModeName())
	theLines.append("Player's character name: "+playerName)
	theLines.append("Character amount: "+str(charAmount))
	theLines.append("")
	theLines.append("Time played: "+str(Util.getTimeStringShort(timePlayed)))
	theLines.append("Game version: "+gameVersion)
	theLines.append("Save name: "+savePath.get_file())
	return theLines

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

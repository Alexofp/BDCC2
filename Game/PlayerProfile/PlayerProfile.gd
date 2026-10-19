extends RefCounted
class_name PlayerProfile

const DEBUG_MULTIPLAYER_TEST:bool = true # Will slightly modify the nickname and gid so that we can connect to ourselves

var nickname:String = "Player"
var gid:String = "" # Profile-ID. Randomly-generated id, used to identify the player even if they changed their name

static func generateNewGID(_len:int = 10) -> String:
	var result:String = ""
	var allThings:Array = UtilParsing.ASCIILetters.keys() + UtilParsing.Digits.keys()
	for _i:int in _len:
		result += RNG.pick(allThings)
	return result

func generateNew():
	nickname = "Player"
	gid = generateNewGID()

const MainProfilePath:String = "user://Game/Profile.json"

func saveAsMainProfile():
	DirAccess.make_dir_recursive_absolute(MainProfilePath.get_base_dir())
	var _file := FileAccess.open(MainProfilePath, FileAccess.WRITE)
	_file.store_string(JSON.stringify(saveData(), "\t"))
	_file.close()

func hasMainProfileFile() -> bool:
	return FileAccess.file_exists(MainProfilePath)

func loadMainProfile() -> bool:
	if(!hasMainProfileFile()):
		generateNew()
		saveAsMainProfile()
		debugModifyProfile()
		return false
	var _file := FileAccess.open(MainProfilePath, FileAccess.READ)
	var _content:String = _file.get_as_text()
	
	var _json := JSON.new()
	var _err := _json.parse(_content)
	if(_err != OK):
		Log.Printerr("Failed to read main player profile, Error: "+str(_err))
		generateNew()
		debugModifyProfile()
		return false
	if(!(_json.data is Dictionary)):
		Log.Printerr("Bad player profile json value: "+str(_json.data))
		generateNew()
		debugModifyProfile()
		return false
	loadData(_json.data)
	debugModifyProfile()
	return true

func debugModifyProfile():
	if(!DEBUG_MULTIPLAYER_TEST):
		return
	nickname += "_"+generateNewGID(3)
	gid += "_"+generateNewGID(3)

func saveData() -> Dictionary:
	return {
		nickname = nickname,
		gid = gid,
	}

func loadData(_data:Dictionary):
	nickname = SAVE.loadVar(_data, "nickname", "Player")
	gid = SAVE.loadVar(_data, "gid", "")
	if(gid.is_empty()):
		nickname = "!BadPlayer!"
		gid = generateNewGID()
	

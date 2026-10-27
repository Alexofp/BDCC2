extends Object
class_name SAVE

static func loadVar(_data:Dictionary, _theKey:String, _default):
	if(!_data.has(_theKey)):
		return _default
		
	if(_default != null && typeof(_data[_theKey]) != typeof(_default) && !(typeof(_data[_theKey]) == TYPE_FLOAT && typeof(_default) == TYPE_INT) && !(typeof(_data[_theKey]) == TYPE_STRING_NAME && typeof(_default) == TYPE_STRING)):
		Log.Printerr("Value mismatch when loading. Key is "+str(_theKey)+" Value is '"+str(_data[_theKey])+"' Default is '"+str(_default)+"'")
		return _default

	# Do type checks here. Type of _default must be the same as the type of data[_theKey]
	return _data[_theKey]

# Type-safe versions. Prefer to use these!
static func loadStr(_data:Dictionary, _theKey:String, _default:String = "") -> String:
	return loadVar(_data, _theKey, _default)
static func loadFloat(_data:Dictionary, _theKey:String, _default:float = 0.0) -> float:
	return loadVar(_data, _theKey, _default)
static func loadInt(_data:Dictionary, _theKey:String, _default:int = 0) -> int:
	return loadVar(_data, _theKey, _default)
static func loadArray(_data:Dictionary, _theKey:String, _default:Array = []) -> Array:
	return loadVar(_data, _theKey, _default)
static func loadVec3(_data:Dictionary, _theKey:String, _default:Vector3 = Vector3.ZERO) -> Vector3:
	return loadVar(_data, _theKey, _default)
static func loadArrayOfDicts(_data:Dictionary, _theKey:String, _default:Array[Dictionary] = []) -> Array[Dictionary]:
	var res:Array[Dictionary]
	var theAr:Array = loadArray(_data, _theKey, _default)
	for theA:Dictionary in theAr:
		res.append(theA)
	return res
static func loadDict(_data:Dictionary, _theKey:String, _default:Dictionary = {}) -> Dictionary:
	return loadVar(_data, _theKey, _default)
static func loadBool(_data:Dictionary, _theKey:String, _default:bool = false) -> bool:
	return loadVar(_data, _theKey, _default)
static func loadTransform(_data:Dictionary, _theKey:String, _default:Transform3D = Transform3D.IDENTITY) -> Transform3D:
	return loadVar(_data, _theKey, _default)

static func loadIntoVar(_data:Dictionary, _obj:Object, _theVar:String, _default):
	_obj.set(_theVar, loadVar(_data, _theVar, _default))

static func loadIntoVarIfExists(_data:Dictionary, _obj:Object, _theVar:String):
	if(_data.has(_theVar)):
		_obj.set(_theVar, _data[_theVar])

static func getNodePath(_node:Node) -> NodePath:
	return _node.get_path()

static func loadNodeByPath(_data:Dictionary, _theKey:String) -> Node:
	return GI.get_tree().root.get_node_or_null(SAVE.loadVar(_data, _theKey, NodePath()))

const SAVES_FOLDER:String = "user://Game/Saves/"
const SAVE_EXTENSION:String = "bdcc2"
static func getAllSaves() -> Array[String]:
	if(!DirAccess.dir_exists_absolute(SAVES_FOLDER)):
		return []
	var theSaves:Array[String] = Util.getFilesInFolderSmart(SAVES_FOLDER, [SAVE_EXTENSION], true, false, false, true)
	Util.sortFilePathsByModifiedData(theSaves)
	return theSaves

static func getAllSaveInfos(_getCorruptOnError:bool = true) -> Array[GameShortInfo]:
	var result:Array[GameShortInfo]
	var theSaves:Array[String] = getAllSaves()
	for thePath:String in theSaves:
		var newInfo:GameShortInfo = GameShortInfo.tryGetInfoFromSavePath(thePath, _getCorruptOnError)
		if(!newInfo):
			continue
		result.append(newInfo)
	return result

static func constructSaveFilepath(_name:String) -> String:
	return SAVES_FOLDER.path_join(Util.sanitizeFileName(_name)+"."+SAVE_EXTENSION)

static func findUniqueSaveFilepathFromName(_name:String) -> String:
	return Util.findUniqueFilepath(constructSaveFilepath(_name))

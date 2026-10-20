extends Object
class_name SAVE

static func loadVar(_data:Dictionary, _theKey:String, _default):
	if(!_data.has(_theKey)):
		return _default
		
	if(_default != null && typeof(_data[_theKey]) != typeof(_default) && !(typeof(_data[_theKey]) == TYPE_FLOAT && typeof(_default) == TYPE_INT)):
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

static func loadIntoVar(_data:Dictionary, _obj:Object, _theVar:String, _default):
	_obj.set(_theVar, loadVar(_data, _theVar, _default))

static func loadIntoVarIfExists(_data:Dictionary, _obj:Object, _theVar:String):
	if(_data.has(_theVar)):
		_obj.set(_theVar, _data[_theVar])

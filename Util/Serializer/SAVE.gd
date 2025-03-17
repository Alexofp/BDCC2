extends Object
class_name SAVE

static func loadVar(_data:Dictionary, _theKey:String, _default):
	if(!_data.has(_theKey)):
		return _default
		
	if(_default != null && typeof(_data[_theKey]) != typeof(_default) && !(typeof(_data[_theKey]) == TYPE_FLOAT && typeof(_default) == TYPE_INT)):
		Log.Printerr("Value mismatch when loading. Key is "+str(_theKey)+" Value is '"+str(_data[_theKey])+"' Default is '"+str(_default)+"'")
		
	# Do type checks here. Type of _default must be the same as the type of data[_theKey]
	return _data[_theKey]

static func loadIntoVar(_data:Dictionary, _obj:Object, _theVar:String, _default):
	_obj.set(_theVar, loadVar(_data, _theVar, _default))

static func loadIntoVarIfExists(_data:Dictionary, _obj:Object, _theVar:String):
	if(_data.has(_theVar)):
		_obj.set(_theVar, _data[_theVar])

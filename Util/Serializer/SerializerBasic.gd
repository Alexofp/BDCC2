extends SerializerBase
class_name SerializerBasic

var data:Dictionary = {}

func saveVar(_theKey:String, _theValue):
	data[_theKey] = _theValue

func shouldLoad(_theKey:String) -> bool:
	return true

func loadVar(_theKey:String, _default):
	if(!data.has(_theKey)):
		return _default
	# Do type checks here. Type of _default must be the same as the type of data[_theKey]
	return data[_theKey]

func getData() -> Dictionary:
	return data

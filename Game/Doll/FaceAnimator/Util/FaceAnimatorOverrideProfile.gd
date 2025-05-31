extends RefCounted
class_name FaceAnimatorOverrideProfile

var fields:Dictionary = {}
var values:Dictionary = {}

func isFaceValueOverridden(_faceValue:int) -> bool:
	return fields.has(_faceValue)

func getFaceValueOverride(_faceValue:int, _default = 0.0):
	if(!values.has(_faceValue) || !fields.has(_faceValue)):
		return _default
	return values[_faceValue]

func addOverride(_faceValue:int):
	fields[_faceValue] = true

func setValue(_faceValue:int, _val):
	values[_faceValue] = _val

func removeValue(_faceValue:int):
	if(values.has(_faceValue)):
		values.erase(_faceValue)

func removeOverride(_faceValue:int):
	if(fields.has(_faceValue)):
		fields.erase(_faceValue)

func saveData() -> Dictionary:
	return {
		fields = fields,
		values = values,
	}

func loadData(_data:Dictionary):
	fields = SAVE.loadVar(_data, "fields", {})
	values = SAVE.loadVar(_data, "values", {})

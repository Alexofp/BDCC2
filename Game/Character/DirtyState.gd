extends RefCounted
class_name DirtyState

var dirtyFields:Array = []
var fieldToVarName:Dictionary[int, String] = {}
var dirtyTime:float = 0.0

func markDirty(theOption:int):
	if(!Network.isServerNotSingleplayer()):
		return
	if(dirtyFields.has(theOption)):
		return
	if(!fieldToVarName.has(theOption)):
		assert(false, "Bad field indx: "+str(theOption))
		return
	dirtyFields.append(theOption)

func getFieldValue(_field:int) -> Variant:
	if(fieldToVarName.has(_field)):
		return get(fieldToVarName[_field])
	assert(false, "Bad field indx: "+str(_field))
	return null

func setFieldValue(_field:int, _value:Variant):
	if(fieldToVarName.has(_field)):
		set(fieldToVarName[_field], _value)
		return
	assert(false, "Bad field indx: "+str(_field))

func setCheckDirty(_field:int, _value:Variant):
	if(getFieldValue(_field) == _value):
		return
	setFieldValue(_field, _value)
	markDirty(_field)

func hasDirtyFields() -> bool:
	return !dirtyFields.is_empty()

func getDirtyFieldsData() -> Dictionary:
	var result:Dictionary = {}
	for field in dirtyFields:
		result[field] = getFieldValue(field)
	return result

func applyDirtyFieldsData(_data:Dictionary):
	for field in _data:
		setFieldValue(field, _data[field])

func clearDirty():
	dirtyFields.clear()
	dirtyTime = 0.0

func processDirty(_dt:float):
	if(!dirtyFields.is_empty()):
		dirtyTime += _dt

func getDirtyTime() -> float:
	return dirtyTime

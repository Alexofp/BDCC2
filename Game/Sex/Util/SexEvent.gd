extends RefCounted
class_name SexEvent

var id:String = ""
var args:Array = []

static func make(_id:String, _args:Array = []) -> SexEvent:
	var newEvent:SexEvent = SexEvent.new()
	newEvent.id = _id
	newEvent.args = _args
	return newEvent

func saveData() -> Dictionary:
	return {
		id = id,
		args = args,
	}

func loadData(_data:Dictionary):
	id = SAVE.loadStr(_data, "id")
	args = SAVE.loadArray(_data, "args")

extends Control
class_name VarUIBase

var id
signal onValueChange(id:String, newValue:Variant)

func setData(_data:Dictionary):
	pass

func triggerChange(_newValue):
	onValueChange.emit(id, _newValue)

func onEditorClose():
	pass

func getValue():
	return null

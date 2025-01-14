extends Control
class_name VarUIBase

var id = ""
signal onValueChange(id, newValue)

func setData(_data:Dictionary):
	pass

func triggerChange(_newValue):
	onValueChange.emit(id, _newValue)

func onEditorClose():
	pass

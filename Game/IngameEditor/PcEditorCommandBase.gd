extends RefCounted
class_name PcEditorCommandBase

var id:String = "error"
var pcRef:WeakRef
var tick:int

func do(_args:Dictionary):
	pass

func undo():
	pass

func redo():
	pass

func getPC() -> PlayerEditor:
	if(pcRef == null):
		return null
	return pcRef.get_ref()

func setPC(_thePC):
	pcRef = weakref(_thePC)

extends PcEditorCommandBase

var theInfo

func _init():
	id = "RemoveProp"

func do(_args:Dictionary):
	theInfo = getPC().gatherChildInfo(_args["id"])
	getPC().removeEditorChild(_args["id"])

func undo():
	getPC().addChildFromChildInfo(theInfo)

func redo():
	if(theInfo != null):
		getPC().removeEditorChild(theInfo["id"])

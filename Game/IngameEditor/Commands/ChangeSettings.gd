extends PcEditorCommandBase

var oldSettings
var newSettings
var propID

func _init():
	id = "ChangeSettings"

func do(_args:Dictionary):
	propID = _args["id"]
	newSettings = _args["settings"].duplicate(true)
	oldSettings = getPC().getPropSettingsFullByID(propID).duplicate(true)
	getPC().applySettingsFullToProp(propID, newSettings)

func undo():
	getPC().applySettingsFullToProp(propID, oldSettings)

func redo():
	getPC().applySettingsFullToProp(propID, newSettings)

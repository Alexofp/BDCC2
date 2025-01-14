extends PcEditorCommandBase

var theMap:PCEditorScene
var redoMap:PCEditorScene

func _init():
	id = "ClearMap"

func do(_args:Dictionary):
	theMap = getPC().saveMap()
	getPC().clearMap()

func undo():
	redoMap = getPC().saveMap()
	getPC().clearMap()
	getPC().loadMap(theMap)

func redo():
	theMap = getPC().saveMap()
	getPC().clearMap()
	getPC().loadMap(redoMap)

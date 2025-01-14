extends PcEditorCommandBase

var theID:int = -1
var theTransform:Transform3D
var theProp:PCEditorProp
var settings:Dictionary

func _init():
	id = "PlaceProp"

func do(_args:Dictionary):
	theProp = _args["prop"]
	if(_args.has("settings")):
		settings = _args["settings"].duplicate(true)
	else:
		settings = getPC().getSelectedPropSettingsValues().duplicate(true)
	if(_args.has("gtransform")):
		theID = getPC().addEditorChild(theProp, settings, _args["gtransform"], -1, true)
	elif(_args.has("transform")):
		theID = getPC().addEditorChild(theProp, settings, _args["transform"])
	elif(_args.has("symmetry")):
		theID = getPC().addEditorChildToMousePosSymmetry(theProp, settings, _args["symmetry"], _args["symmetryPoint"] if _args.has("symmetryPoint") else Vector3(0.0, 0.0, 0.0))
	else:
		theID = getPC().addEditorChildToMousePos(theProp, settings)
	theTransform = getPC().getNodeByID(theID).transform

func undo():
	getPC().removeEditorChild(theID)

func redo():
	getPC().addEditorChild(theProp, settings, theTransform, theID)

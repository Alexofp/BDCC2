extends Area3D
class_name Interactable

@export var actionsResources:Array[InteractActionResource] = []
var actions:Array[InteractAction] = []

func _ready() -> void:
	for actionResource in actionsResources:
		actions.append(actionResource.createAction())

signal onInteract(user, action)

func getActions(_interactor:Interactor, _user = null) -> Array[InteractAction]:
	return actions

func getActionsFinal(_interactor:Interactor, _user = null) -> Array[InteractAction]:
	var theActions:Array[InteractAction] = getActions(_interactor, _user)
	for action in theActions:
		action.interactable = self
	return theActions

func doInteract(who, action:InteractAction):
	onInteract.emit(who, action)
	print("INTERACT! "+str(action.id))

func newAction(theID:String, theName:String, theArgs:Array = []) -> InteractAction:
	var theAction:InteractAction = InteractAction.new()
	theAction.id = theID
	theAction.name = theName
	theAction.args = theArgs
	return theAction

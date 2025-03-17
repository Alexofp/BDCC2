extends Resource
class_name InteractActionResource

@export var id:String = ""
@export var name:String = "New action"
@export var priority:int = 0
@export var args:Array = []
@export var disabled:bool = false
@export var hidden:bool = false
@export var onlyWhenStanding:bool = false

func createAction() -> InteractAction:
	var newAction:InteractAction = InteractAction.new()
	newAction.id = id
	newAction.name = name
	newAction.priority = priority
	newAction.args = args
	newAction.disabled = disabled
	newAction.hidden = hidden
	newAction.onlyWhenStanding = onlyWhenStanding
	return newAction

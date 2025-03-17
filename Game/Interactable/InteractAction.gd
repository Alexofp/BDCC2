extends RefCounted
class_name InteractAction

@export var id:String = ""
@export var name:String = "New action"
@export var priority:int = 0
@export var args:Array = []
@export var disabled:bool = false
@export var hidden:bool = false
@export var onlyWhenStanding:bool = false

var allowedUsers:Array = []

var interactable:Interactable

func andSetPriority(newPrio:int) -> InteractAction:
	priority = newPrio
	return self

func getName(_user) -> String:
	return name

func isDisabled(_user) -> bool:
	return disabled

func isHidden(_user) -> bool:
	#print(_user if _user is CharacterPawn else _user.getPawn())
	#print(allowedUsers)
	if(onlyWhenStanding):
		if(_user && (_user is DollController)):
			if(!_user.canSit()):
				return true
	if(!allowedUsers.is_empty()):
		#print(allowedUsers, " ", _user if _user is CharacterPawn else _user.getPawn())
		var actualUser = _user if _user is CharacterPawn else _user.getPawn()
		
		if(!allowedUsers.has(actualUser)):
			return true
	return hidden

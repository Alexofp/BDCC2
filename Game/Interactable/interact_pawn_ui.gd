extends Control
class_name InteractUI

@onready var actions_list: ItemList = %ActionsList

var selectedActionIndex:int = 0

var interactorRef:WeakRef

#@export var interactor:Interactor
#@export var user:Node3D

var cachedActions:Array[InteractActionBaked] = []

#func _ready():
	#setInteractorAndUser(interactor, user)
	#interactor = null
	#user = null

func setInteractor(_newInteractor:PawnInteractor):
	if(!_newInteractor):
		interactorRef = null
		return
	interactorRef = weakref(_newInteractor)

func getInteractor() -> PawnInteractor:
	if(interactorRef == null):
		return null
	return interactorRef.get_ref()

func getPawn() -> CharacterPawn:
	if(interactorRef == null):
		return null
	return getInteractor().pawn

func calculateActions() -> Array[InteractActionBaked]:
	var theInteractor := getInteractor()
	#var theUser = getUser()
	if(theInteractor == null):
		return []
	return theInteractor.getQuickActionsFinal()

func getActions() -> Array[InteractActionBaked]:
	return cachedActions

func selectNextAction() -> bool:
	var theActions := getActions()
	#selectedActionIndex += 1
	#if(selectedActionIndex >= theActions.size()):
		#selectedActionIndex = 0
	#updateSelectedAction()
	if(selectedActionIndex < (theActions.size()-1)):
		selectedActionIndex += 1
		updateSelectedAction()
		return true
	return false
	
func selectPrevAction() -> bool:
	#selectedActionIndex -= 1
	#if(selectedActionIndex < 0):
		#var theActions := getActions()
		#selectedActionIndex = theActions.size()-1
		#if(selectedActionIndex < 0):
			#selectedActionIndex = 0
	#updateSelectedAction()
	if(selectedActionIndex > 0):
		selectedActionIndex -= 1
		updateSelectedAction()
		return true
	return false

func doSelectedAction():
	updateActionsCache()
	var theActions := getActions()
	if(selectedActionIndex >= 0 && selectedActionIndex < theActions.size()):
		var anAction:InteractActionBaked = theActions[selectedActionIndex]
		
		#print("DO QUICK ACTION!!!")
		GI.askDoPawnAction(getPawn(), anAction)
		#GI.askDoAction(getUser(), anAction)

func updateSelectedAction():
	actions_list.clear()
	
	var theActions:=getActions()

	if(selectedActionIndex >= theActions.size()):
		selectedActionIndex = theActions.size()-1
	if(selectedActionIndex < 0):
		selectedActionIndex = 0
	
	#var theUser = getUser()
	
	var _i:int = 0
	for action in theActions:
		var isDisabled:bool = action.disabled
		actions_list.add_item(("(Disabled) " if isDisabled else "")+action.name, null, !isDisabled)
		
		if(selectedActionIndex == _i):
			actions_list.select(_i)
			actions_list.ensure_current_is_visible()
		
		_i += 1

func updateActionsCache():
	cachedActions = calculateActions()

func hasActions() -> bool:
	return !getActions().is_empty()

func _process(_delta: float) -> void:
	updateActionsCache()
	updateSelectedAction()
	processPlayerInput()
	
	visible = hasActions()
	#print(getUser())

var eatenScroll:bool = false
func processPlayerInput():
	#print("meow")
	eatenScroll = false
	if(UIHandler.hasAnyUIVisible()):
		return
	if(Input.is_action_just_pressed("game_interact_next")):
		if(selectNextAction()):
			eatenScroll = true
	if(Input.is_action_just_pressed("game_interact_prev")):
		if(selectPrevAction()):
			eatenScroll = true
	if(Input.is_action_just_pressed("game_interact")):
		doSelectedAction()

func didScrollThisFrame() -> bool:
	return eatenScroll

func canScrollUp() -> bool:
	var theActions:=getActions()
	if(selectedActionIndex >= (theActions.size()-1)):
		return true
	return false

func canScrollDown() -> bool:
	if(selectedActionIndex <= 0):
		return true
	return false

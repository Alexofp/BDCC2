extends Area3D
class_name Interactor

@export var actionsSync:Array = []: set = onActionsSync
@export var user:Node3D

var interactables:Array[Interactable] = []

var actionsBaked:Array[InteractActionBaked] = []	
var actionsCache:Array[InteractAction] = []

func onActionsSync(_newActionsRaw:Array):
	actionsSync = _newActionsRaw
	actionsBaked = []
	for actionEntry in actionsSync:
		var newBakedAction := InteractActionBaked.new()
		newBakedAction.name = actionEntry["name"]
		newBakedAction.uniqueID = actionEntry["id"]
		newBakedAction.disabled = actionEntry["dis"]
		actionsBaked.append(newBakedAction)

func _process(_delta: float) -> void:
	if(!Network.isServer()):
		return
	actionsCache=calculateActions()
	actionsSync = actionsToDictArray(actionsCache)

func getUser() -> Node3D:
	return user

func getActionsFinal() -> Array[InteractActionBaked]:
	return actionsBaked

func actionsToDictArray(_actions:Array[InteractAction]) -> Array:
	var result:Array = []
	var _user := getUser()
	
	var _i:int = 0
	for action in _actions:
		if(action.isHidden(_user)):
			continue
		result.append({
			#id = action.id,
			id = _i,
			name = action.getName(_user),
			dis = action.isDisabled(_user),
		})
		_i += 1
	
	return result

func calculateActions() -> Array[InteractAction]:
	var _user = getUser()
	var result:Array[InteractAction]= []
	
	for interactable in interactables:
		var theActions:Array[InteractAction] = interactable.getActionsFinal(self, _user)
		for anAction in theActions:
			if(anAction.isHidden(_user)):
				continue
			result.append(anAction)
	
	var actionByDistance:Dictionary = {}
	for action in result:
		var theDistance:float = global_position.distance_squared_to(action.interactable.global_position) if action.interactable != null else 100.0
		actionByDistance[action] = theDistance
		
	result.sort_custom(func(a, b): return actionByDistance[a] < actionByDistance[b])
	
	return result

func doActionByID(theActionIndx:int):
	if(theActionIndx < 0 || theActionIndx >= actionsCache.size()):
		return
	doAction(actionsCache[theActionIndx])

func doAction(theAction:InteractAction):
	if(!(theAction in actionsCache)):
		assert(false, "Tried to use do an action that is not possible")
		return
	if(!theAction.interactable):
		assert(false, "Interactable doesn't exist")
		return
	theAction.interactable.doInteract(getUser(), theAction)

func _on_area_entered(area: Area3D) -> void:
	if(area is Interactable):
		interactables.append(area)
		area.tree_exiting.connect(onInteractableExitedTree.bind(area))
		#print("INTERACTABLES: "+str(interactables.size()))
		
func _on_area_exited(area: Area3D) -> void:
	if(interactables.has(area)):
		interactables.erase(area)
		area.tree_exiting.disconnect(onInteractableExitedTree.bind(area))
		#print("INTERACTABLES: "+str(interactables.size()))

func onInteractableExitedTree(area:Interactable):
	if(interactables.has(area)):
		interactables.erase(area)
		area.tree_exiting.disconnect(onInteractableExitedTree.bind(area))
		#print("INTERACTABLES: "+str(interactables.size()))

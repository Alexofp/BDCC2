extends Area3D
class_name PawnInteractor

var pawn:CharacterPawn

var nearbyPawns:Array[PawnInteractor] = []
var interactables:Array[PawnInteractable] = []

var cachedCategories:Array[InteractCategory]
var targetToCachedCategory:Dictionary[Node, InteractCategory]
signal onCachedCategoriesUpdate

#var cachedQuickActionCategories:Array[InteractCategory]
#var targetToQuickActionCachedCategory:Dictionary[Node, InteractCategory]

var cachedQuickActions:Array[InteractQuickAction]
@export var actionsSync:Array[Array]: set = onActionsSync # [ [name, indx, dis, actionID], [name, indx, dis, actionID] ]
var actionsBaked:Array[InteractActionBaked] = []	

func onActionsSync(_newActionsRaw:Array[Array]):
	actionsSync = _newActionsRaw
	actionsBaked = []
	for actionEntry in actionsSync:
		var newBakedAction := InteractActionBaked.new()
		newBakedAction.name = actionEntry[0]
		newBakedAction.uniqueID = actionEntry[1]
		#newBakedAction.subCategory = actionEntry[2]
		newBakedAction.actionID = actionEntry[3]
		newBakedAction.disabled = actionEntry[4]
		actionsBaked.append(newBakedAction)

var cachedActionsBig:Array[InteractQuickAction]
@export var actionsBigSync:Array[Array]#: set = onActionsBigSync
#func onActionsBigSync(_newActionsRaw:Array[Array]):
	#actionsBigSync = _newActionsRaw

func _physics_process(_delta: float) -> void:
	if(Network.isServer()):
		if(!pawn.isControlledByAnyPlayer()):
			return
		
		updateQuickActionsInteractor()
		updateActionsBigInteractor()
		
		actionsSync = actionsToSyncArray(cachedQuickActions)
		actionsBigSync = actionsBigToSyncArray(cachedActionsBig)
		#print(actionsSync)

func actionsToSyncArray(_actions:Array[InteractQuickAction]) -> Array[Array]:
	var result:Array[Array] = []
	#var _user := getUser()
	var theContext := pawn.pawnActionContext
	var _i:int = 0
	for action in _actions:
		var theEntry := action.action
		var theAction:PawnActionBase= theEntry.action
		if(!theAction):
			result.append([
				"Unknown", _i, [], "", true
			])
			_i += 1
			continue
		
		theContext.target = action.target
		theContext.args = theEntry.args
		
		result.append([
			theAction.getVisibleName(theContext), _i, [], theAction.id, theEntry.disabled,
		])
		_i += 1
	theContext.clearContext()
	return result

func actionsBigToSyncArray(_actions:Array[InteractQuickAction]) -> Array[Array]:
	var result:Array[Array] = []
	#var _user := getUser()
	var theContext := pawn.pawnActionContext
	var _i:int = 0
	for action in _actions:
		var theEntry := action.action
		var theAction:PawnActionBase= theEntry.action
		if(!theAction):
			result.append([
				"Unknown", _i, [], "", false,
			])
			_i += 1
			continue
		
		theContext.target = action.target
		theContext.args = theEntry.args
		
		result.append([
			theAction.getVisibleName(theContext), _i, theEntry.subCategory, theAction.id, theEntry.disabled
		])
		_i += 1
	theContext.clearContext()
	return result

func updateActionsBigInteractor():
	var newQuickActions:Array[InteractQuickAction]
	if(!pawn):
		return

	if(true):
		var selfActions := pawn.getActionsBigSelf()
		
		for entry in selfActions:
			var newQuickAction := InteractQuickAction.new()
			newQuickAction.target = pawn
			newQuickAction.action = entry
			newQuickActions.append(newQuickAction)

	cachedActionsBig = newQuickActions

func updateQuickActionsInteractor():
	var newQuickActions:Array[InteractQuickAction]
	if(!pawn):
		return

	if(true):
		var selfActions := pawn.getQuickActionsSelf()
		
		for entry in selfActions:
			var newQuickAction := InteractQuickAction.new()
			newQuickAction.target = pawn
			newQuickAction.action = entry
			newQuickActions.append(newQuickAction)

	for otherPawnInteractor in nearbyPawns:
		var otherPawn := otherPawnInteractor.pawn
		if(!otherPawn):
			continue
		
		var otherPawnActions := otherPawn.getQuickActions(pawn)
		for entry in otherPawnActions:
			var newQuickAction := InteractQuickAction.new()
			newQuickAction.target = otherPawn
			newQuickAction.action = entry
			newQuickActions.append(newQuickAction)
	
	var theContext := pawn.pawnActionContext
	for theInteractable in interactables:
		var theInteractableActions := theInteractable.getQuickInteractActions(pawn)
		for entry in theInteractableActions:
			theContext.target = theInteractable.target
			theContext.args = entry.args
			if(!entry.action.canStartAction(theContext)):
				continue
			
			var newQuickAction := InteractQuickAction.new()
			newQuickAction.target = theInteractable.target
			newQuickAction.action = entry
			newQuickActions.append(newQuickAction)
	theContext.clearContext()
	
	cachedQuickActions = newQuickActions

func getQuickActions() -> Array[InteractQuickAction]:
	return cachedQuickActions

func getQuickActionsFinal() -> Array[InteractActionBaked]:
	return actionsBaked

func doBakedAction(_indx:int, _actionID:String):
	#var _indx:int = _action.uniqueID
	#var _actionID:String = _action.actionID
	if(_indx < 0 || _indx >= cachedQuickActions.size()):
		return
	var theQuickAction := cachedQuickActions[_indx]
	if(_actionID != theQuickAction.action.action.id): #Pure perfection
		# Sanity check
		return
	
	if(!pawn):
		return
	pawn.doInteractEntryDo(theQuickAction.action, theQuickAction.target)

func doBakedActionInteraction(_indx:int, _actionID:String):
	#var _indx:int = _action.uniqueID
	#var _actionID:String = _action.actionID
	if(_indx < 0 || _indx >= cachedActionsBig.size()):
		return
	var theQuickAction := cachedActionsBig[_indx]
	if(_actionID != theQuickAction.action.action.id): #Pure perfection
		# Sanity check
		return
	
	if(!pawn):
		return
	pawn.doInteractEntryDo(theQuickAction.action, theQuickAction.target)

func findInteractEntryDo(_indx:int, _target, _actionID:String) -> InteractEntryDo:
	if(!targetToCachedCategory.has(_target)):
		return null
	var theCategory := targetToCachedCategory[_target]
	
	if(_indx < 0 || _indx >= theCategory.interactEntries.size()):
		return null
	
	var theEntry:InteractEntryBase = theCategory.interactEntries[_indx]
	if(theEntry is InteractEntryDo):
		if(theEntry.action.id != _actionID):
			return null
		
		return theEntry
	return null
	
func updateInteractor():
	cachedCategories.clear()
	targetToCachedCategory.clear()
	if(!pawn):
		onCachedCategoriesUpdate.emit()
		return
	
	#var theContext := pawn.pawnActionContext
	#theContext.target = pawn
	
	if(true):
		var newCategory := InteractCategory.new()
		newCategory.categoryName = "You"
		newCategory.target = pawn
		newCategory.distance = -99.9 # To make sure its first
		newCategory.interactEntries = pawn.getInteractEntriesSelf()
		newCategory.supplyContextCheckCanDo(pawn.pawnActionContext)
		cachedCategories.append(newCategory)
		targetToCachedCategory[newCategory.target] = newCategory
	
	for otherPawnInteractor in nearbyPawns:
		var otherPawn := otherPawnInteractor.pawn
		if(!otherPawn):
			continue
		var theChar := otherPawn.getCharacter()
		if(!theChar):
			continue
		#theContext.target = otherPawn
		var newCategory := InteractCategory.new()
		newCategory.categoryName = theChar.getFullName() + getDistanceSuffix(self, otherPawnInteractor)#otherPawn.getCharID()
		newCategory.target = otherPawn
		newCategory.distance = otherPawn.getGlobalPos().distance_squared_to(pawn.getGlobalPos())
		newCategory.interactEntries = otherPawn.getInteractEntries(pawn)
		newCategory.supplyContextCheckCanDo(pawn.pawnActionContext)
		cachedCategories.append(newCategory)
		targetToCachedCategory[newCategory.target] = newCategory
	
	for theInteractable in interactables:
		var newCategory:InteractCategory = theInteractable.getInteractEntryCategory(pawn)
		if(!newCategory):
			continue
		if(theInteractable.target is Node3D):
			newCategory.distance = pawn.getGlobalPos().distance_squared_to(theInteractable.target.global_position)
		newCategory.supplyContextCheckCanDo(pawn.pawnActionContext)
		newCategory.categoryName += getDistanceSuffix(self, theInteractable)
		cachedCategories.append(newCategory)
		targetToCachedCategory[newCategory.target] = newCategory
	
	cachedCategories.sort_custom(func(a:InteractCategory, b:InteractCategory): return a.distance < b.distance)
	
	onCachedCategoriesUpdate.emit()

func getDistanceSuffix(_node1:Node3D, _node2:Node3D) -> String:
	if(!_node1 || !_node2):
		return ""
	var theDist:float = _node1.global_position.distance_to(_node2.global_position)
	
	return " ("+str(Util.roundF(theDist, 1))+"m)"

func askUpdateInteractor():
	if(Network.isServer()):
		updateInteractor()
	else:
		cachedCategories.clear()
		targetToCachedCategory.clear()
		onCachedCategoriesUpdate.emit()
		
		GI.askUpdateInteractor(self)
		#askUpdateInteractor_SERVER.rpc_id(1)
	
func saveCategoriesData() -> Bins:
	var Ar:Array = [
		Bins.U16, cachedCategories.size(),
	]
	for category in cachedCategories:
		Ar.append_array([
			Bins.BINS, category.saveNetworkData(),
		])
	return Bins.saveStartEnd(Ar)

func loadCategoriesData(_data:Bins):
	_data.loadStart()
	var catAm:int = _data.readU16()
	cachedCategories.clear()
	targetToCachedCategory.clear()
	
	for _i in catAm:
		var newCat:InteractCategory = InteractCategory.new()
		newCat.loadNetworkData(_data.readBins())
		cachedCategories.append(newCat)
		targetToCachedCategory[newCat.target] = newCat
	
	_data.endLoad()
	onCachedCategoriesUpdate.emit()

func setPawn(_p:CharacterPawn):
	pawn = _p

func _on_area_entered(area: Area3D) -> void:
	if(area is PawnInteractor):
		if(!nearbyPawns.has(area)):
			nearbyPawns.append(area)
			area.tree_exiting.connect(onPawnInteractorExitedTree.bind(area))
			#print("NEW PAWN NEARBY: "+str(area))
	elif(area is PawnInteractable):
		if(!interactables.has(area)):
			interactables.append(area)
			area.tree_exiting.connect(onInteractableExitedTree.bind(area))
			

func _on_area_exited(area: Area3D) -> void:
	if(area is PawnInteractor):
		if(nearbyPawns.has(area)):
			nearbyPawns.erase(area)
			area.tree_exiting.disconnect(onPawnInteractorExitedTree.bind(area))
			#print("NO MORE PAWN NEARBY: "+str(area))
	elif(area is PawnInteractable):
		if(interactables.has(area)):
			interactables.erase(area)
			area.tree_exiting.disconnect(onInteractableExitedTree.bind(area))

#area.tree_exiting.connect(onInteractableExitedTree.bind(area))
#area.tree_exiting.disconnect(onInteractableExitedTree.bind(area))

func onInteractableExitedTree(area:PawnInteractable):
	if(interactables.has(area)):
		interactables.erase(area)
		area.tree_exiting.disconnect(onInteractableExitedTree.bind(area))

func onPawnInteractorExitedTree(area:PawnInteractor):
	if(nearbyPawns.has(area)):
		nearbyPawns.erase(area)
		area.tree_exiting.disconnect(onPawnInteractorExitedTree.bind(area))

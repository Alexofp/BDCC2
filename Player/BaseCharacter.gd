extends Node
class_name BaseCharacter

var id:String = "error"
var rootBodypart:BaseBodyBodypart
signal onRootChanged(newroot)
signal onBodypartAdded(whatpart, slot, newbodypart)
signal onBodypartRemoved(whatpart, slot, removedbodypart)
signal onBodypartChanged
signal onBaseSkinDataChanged(newdata)
signal onBodypartOptionsRecalculated(part)
signal onInventoryChanged(event)

var baseSkinData:BaseSkinData = BaseSkinData.new()

var inventory:Inventory = Inventory.new()

func _init():
	inventory.setCharacter(self)
	inventory.connect("inventoryChanged", onInventoryChangedCallback)
	setRoot(GlobalRegistry.createBodypart("FeminineBodyNew"))
	
	#var head = getRootBodypart().setBodypart(BodypartSlot.Head, BaseHeadBodypart.new())
	#head.setBodypart(BodypartSlot.LeftEar, BaseEarBodypart.new())
	#head.setBodypart(BodypartSlot.RightEar, BaseEarBodypart.new())

	#getRootBodypart().setBodypart(BodypartSlot.Legs, BaseLegsBodypart.new())
	
	#inventory.equipItem(GlobalRegistry.createItem("TestTShirt"))

func onInventoryChangedCallback(event: InventoryChangedEvent):
	print("INVENTORY EVENT: "+event.getReadableInfo())
	emit_signal("onInventoryChanged", event)

func getID() -> String:
	return id

func getName() -> String:
	return "Error"

func getRootBodypart() -> BaseBodyBodypart:
	return rootBodypart

func setRoot(newroot: BaseBodyBodypart):
	rootBodypart = newroot
	rootBodypart.rootRef = weakref(self)

func replaceRoot(newroot: BaseBodyBodypart):
	var currentRoot = rootBodypart
	
	var toAddLater = {}
	
	for bodypartSlot in currentRoot.getBodyparts().keys():
		toAddLater[bodypartSlot] = currentRoot.getBodyparts()[bodypartSlot]
		currentRoot.removeBodypart(bodypartSlot)
	
	rootBodypart.rootRef = null
	rootBodypart = null
	setRoot(newroot)
	emit_signal("onRootChanged", newroot)
	emit_signal("onBodypartChanged")
	
	for partSlot in toAddLater:
		newroot.setBodypart(partSlot, toAddLater[partSlot])
	
	

func tellBodypartAdded(whatpart: BaseBodypart, slot: String, newpart: BaseBodypart):
	emit_signal("onBodypartAdded", whatpart, slot, newpart)
	emit_signal("onBodypartChanged")

func tellBodypartRemoved(whatpart: BaseBodypart, slot: String, removedpart: BaseBodypart):
	emit_signal("onBodypartRemoved", whatpart, slot, removedpart)
	emit_signal("onBodypartChanged")

func getBaseSkinData() -> BaseSkinData:
	return baseSkinData

func setBaseSkinData(newData: BaseSkinData):
	if(baseSkinData == newData):
		return
	baseSkinData = newData
	emit_signal("onBaseSkinDataChanged", baseSkinData)

func getAllBodyparts() -> Array:
	if(rootBodypart == null):
		return []
	var result = [rootBodypart]
	
	var toCheck = [rootBodypart]
	while(!toCheck.is_empty()):
		var theBodypart:BaseBodypart = toCheck.pop_back()
		
		for childBodypart in theBodypart.getBodyparts().values():
			if(childBodypart == null):
				continue
			result.append(childBodypart)
			toCheck.append(childBodypart)
	
	return result

func onPartOptionsRecalculated(part: BaseBodypart):
	emit_signal("onBodypartOptionsRecalculated", part)

func getBodypartByPath(path:Array) -> BaseBodypart:
	var currentPart:BaseBodypart = rootBodypart
	
	for bodypartSlot in path:
		if(!currentPart.hasBodypart(bodypartSlot)):
			return null
		
		currentPart = currentPart.getBodypart(bodypartSlot)
	
	return currentPart

func getInventory() -> Inventory:
	return inventory

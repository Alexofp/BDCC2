extends Node
class_name BaseCharacter

var id:String = "error"
var rootBodypart:BaseBodyBodypart
signal onBodypartAdded(whatpart, slot, newbodypart)
signal onBodypartRemoved(whatpart, slot, removedbodypart)
signal onBaseSkinDataChanged(newdata)
signal onBodypartOptionsRecalculated(part)

var baseSkinData:BaseSkinData = BaseSkinData.new()

func _init():
	setRoot(GlobalRegistry.createBodypart("FeminineBody"))
	
	#var head = getRootBodypart().setBodypart(BodypartSlot.Head, BaseHeadBodypart.new())
	#head.setBodypart(BodypartSlot.LeftEar, BaseEarBodypart.new())
	#head.setBodypart(BodypartSlot.RightEar, BaseEarBodypart.new())

	#getRootBodypart().setBodypart(BodypartSlot.Legs, BaseLegsBodypart.new())

func getID() -> String:
	return id

func getName() -> String:
	return "Error"

func getRootBodypart() -> BaseBodyBodypart:
	return rootBodypart

func setRoot(newroot: BaseBodyBodypart):
	rootBodypart = newroot
	rootBodypart.rootRef = weakref(self)

func tellBodypartAdded(whatpart: BaseBodypart, slot: String, newpart: BaseBodypart):
	emit_signal("onBodypartAdded", whatpart, slot, newpart)

func tellBodypartRemoved(whatpart: BaseBodypart, slot: String, removedpart: BaseBodypart):
	emit_signal("onBodypartRemoved", whatpart, slot, removedpart)

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

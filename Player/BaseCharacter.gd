extends Node
class_name BaseCharacter

var id:String = "error"
var rootBodypart:BaseBodyBodypart
signal onBodypartAdded(whatpart, slot, newbodypart)
signal onBodypartRemoved(whatpart, slot, removedbodypart)

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

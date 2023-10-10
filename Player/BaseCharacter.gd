extends Node
class_name BaseCharacter

var id:String = "error"
var rootBodypart:BaseBodyBodypart
signal onBodypartChanged(whatpart, slot, newbodypart)

func _init():
	setRoot(BaseBodyBodypart.new())
	
	var head = getRootBodypart().setBodypart(BodypartSlot.Head, BaseHeadBodypart.new())
	head.setBodypart(BodypartSlot.LeftEar, BaseEarBodypart.new())
	#head.setBodypart(BodypartSlot.RightEar, BaseEarBodypart.new())

func getID() -> String:
	return id

func getName() -> String:
	return "Error"

func getRootBodypart() -> BaseBodyBodypart:
	return rootBodypart

func setRoot(newroot: BaseBodyBodypart):
	rootBodypart = newroot
	rootBodypart.rootRef = weakref(self)

func onBodypartChange(whatpart: BaseBodypart, slot: String, newpart: BaseBodypart):
	emit_signal("onBodypartChanged", whatpart, slot, newpart)

extends GenericPart
class_name BodypartBase

func getBodypartSlots() -> Array:
	return BodypartSlot.getFromType(getBodypartType())

func supportsSlot(slot:String) -> bool:
	return slot in getBodypartSlots()

func getBodypartType() -> String:
	return ""

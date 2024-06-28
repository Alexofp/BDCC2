extends GenericPart
class_name ExtraPart

func _init():
	super._init()

func onParentBodypartOptionChanged(_optionID: String, _value):
	onParentBodypartOptionChanges(_optionID, _value)

func applyToDoll(_theDoll:Doll, _dollPart:DollPart):
	pass

func onParentBodypartOptionChanges(_optionID: String, _value):
	#print("I SEE IT ",_partID," ",_optionID)
	pass

#func getItem() -> ItemBase:
#	return getPart()


func applyPartTags(_partTags:Dictionary):
	pass


extends RefCounted
class_name BaseCharChange

enum {
	NOTHING,
	PART,
	PART_OPTION,
	CHAR_OPTION,
	PART_FILTER,
	AUTO_SKIN_UPDATE,
}

var changeType:int = NOTHING

var genericType:int
var slot:int
var optionID:String
var value:Variant


func getType() -> int:
	return changeType

static func createPartChange(theGenericType:int, theSlot:int) -> BaseCharChange:
	var result := BaseCharChange.new()
	result.changeType = PART
	result.genericType = theGenericType
	result.slot = theSlot
	return result

static func createPartOptionChange(theGenericType:int, theSlot:int, theOptionID:String, newvalue:Variant) -> BaseCharChange:
	var result := BaseCharChange.new()
	result.changeType = PART_OPTION
	result.genericType = theGenericType
	result.slot = theSlot
	result.optionID = theOptionID
	result.value = newvalue
	return result
	
static func createCharOptionChange(theChangeID:String) -> BaseCharChange:
	var result := BaseCharChange.new()
	result.changeType = CHAR_OPTION
	result.optionID = theChangeID
	return result

static func createPartFilterUpdate() -> BaseCharChange:
	var result := BaseCharChange.new()
	result.changeType = PART_FILTER
	return result
	
static func createAutoSkinUpdate() -> BaseCharChange:
	var result := BaseCharChange.new()
	result.changeType = AUTO_SKIN_UPDATE
	return result

func saveData() -> Dictionary:
	return {
		changeType = changeType,
		genericType = genericType,
		slot = slot,
		optionID = optionID,
		value = value,
	}

func loadData(_data:Dictionary):
	changeType = SAVE.loadVar(_data, "changeType", NOTHING)
	genericType = SAVE.loadVar(_data, "genericType", 0)
	slot = SAVE.loadVar(_data, "slot", 0)
	optionID = SAVE.loadVar(_data, "optionID", "")
	value = SAVE.loadVar(_data, "value", null)

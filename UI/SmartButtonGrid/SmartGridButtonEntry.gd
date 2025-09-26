extends RefCounted
class_name SmartGridButtonEntry

const BUTTON_ACTION = 0
const BUTTON_BACK = 1
const BUTTON_CATEGORY = 2

var buttonIndx:int = -1

var buttonName:String = "Fill me!"
var buttonDisabled:bool = false
var buttonType:int = BUTTON_ACTION
var buttonCategory:Array = []

var actionID:String = ""
var actionArgs:Array = []

static func make(_name:String, _actionID:String, _args:Array = [], _category:Array = []) -> SmartGridButtonEntry:
	var theEntry := SmartGridButtonEntry.new()
	theEntry.buttonName = _name
	theEntry.actionID = _actionID
	theEntry.actionArgs = _args
	theEntry.buttonCategory = _category
	return theEntry
	
static func makeIndex(_indx:int, _name:String, _actionID:String, _args:Array = [], _category:Array = []) -> SmartGridButtonEntry:
	var theEntry := SmartGridButtonEntry.new()
	theEntry.buttonIndx = _indx
	theEntry.buttonName = _name
	theEntry.actionID = _actionID
	theEntry.actionArgs = _args
	theEntry.buttonCategory = _category
	return theEntry

static func makeDisabled(_name:String, _category:Array = []) -> SmartGridButtonEntry:
	var theEntry := SmartGridButtonEntry.new()
	theEntry.buttonName = _name
	theEntry.buttonDisabled = true
	theEntry.buttonCategory = _category
	return theEntry
	
static func makeDisabledIndex(_indx:int, _name:String, _category:Array = []) -> SmartGridButtonEntry:
	var theEntry := SmartGridButtonEntry.new()
	theEntry.buttonIndx = _indx
	theEntry.buttonName = _name
	theEntry.buttonDisabled = true
	theEntry.buttonCategory = _category
	return theEntry

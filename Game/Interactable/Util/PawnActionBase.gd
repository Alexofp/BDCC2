extends RefCounted
class_name PawnActionBase

var id:String = ""
var alwaysCheckedSelf:bool = false
var alwaysCheckedOtherPawn:bool = false
var alwaysCheckedSelfQuickAction:bool = false
var alwaysCheckedOtherPawnQuickAction:bool = false

func getVisibleName(_context:PawnActionContext) -> String:
	return "CHANGE ME"

func canDoAction(_context:PawnActionContext) -> bool:
	return true

func doAction(_context:PawnActionContext) -> bool:
	return true

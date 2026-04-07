extends RefCounted
class_name SexTask

const CumInsideVaginal := "CumInsideVaginal"
const CumInsideAnal := "CumInsideAnal"
const ReceiveCumInsideVaginal := "ReceiveCumInsideVaginal"
const ReceiveCumInsideAnal := "ReceiveCumInsideAnal"
const Undress := "Undress"
const TieUp := "TieUp"
const WearStrapon := "WearStrapon"
const CumTribadism := "CumTribadism"
const CompletedTask := "CompletedTask" # Just a dummy task

var id:String = ""
var actor:String = "" # Character id of the one who wants to do the task
var target:String = "" # Character id of the target
#var args:Array
var score:float = 1.0

static func create(_id:String, _actor:String, _target:String) -> SexTask: #, _args:Array = []
	var theTask := SexTask.new()
	theTask.id = _id
	theTask.actor = _actor
	theTask.target = _target
	#theTask.args = _args
	return theTask

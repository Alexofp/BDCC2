extends RefCounted
class_name SexEngineResult

var participants:Dictionary[String, Participant] # Char ID -> Participant
var didAnything:bool
var domsLostGrip:bool

class Participant:
	var charID:String
	var role:int # = SexRole.Dom

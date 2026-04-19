extends RefCounted
class_name SexEngineResult

var participants:Dictionary[String, Participant] # Char ID -> Participant
var didAnything:bool
var domsLostGrip:bool

func fillFromSexEngine(_sexEngine:SexEngine):
	didAnything = true
	domsLostGrip = _sexEngine.lostGrip
	
	for charID in _sexEngine.participants:
		var theParticipant := _sexEngine.participants[charID]
		
		var newSexResultParticipant := Participant.new()
		newSexResultParticipant.fillFromInfo(theParticipant)
		participants[charID] = newSexResultParticipant

class Participant:
	var charID:String
	var role:int # = SexRole.Dom
	var satisfaction:float = 0.0 # number between 0.0 and 1.0, how much did this participant enjoy the sex
	var satisfactionRaw:float = 0.0
	var frustrationRaw:float = 0.0
	var orgasms:int = 0

	func fillFromInfo(_info:SexParticipantInfo):
		charID = _info.getID()
		role = _info.role
		satisfactionRaw = _info.ai.satisfaction
		frustrationRaw = _info.ai.frustration
		
		var theTotalAm:float = satisfactionRaw + frustrationRaw
		if(theTotalAm <= 0.1): # to prevent division by zero
			theTotalAm = 0.1
		satisfaction = satisfactionRaw / theTotalAm
		
		orgasms = _info.orgasmAmount

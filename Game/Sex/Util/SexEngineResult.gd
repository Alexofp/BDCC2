extends RefCounted
class_name SexEngineResult

var participants:Dictionary[String, Participant] # Char ID -> Participant
var didAnything:bool
var domsLostGrip:bool
var mode:int = SexEngine.MODE_NORMAL

func getSatisfactionCharID(_charID:String) -> float:
	if(!participants.has(_charID)):
		return 0.5
	return participants[_charID].satisfaction

func fillFromSexEngine(_sexEngine:SexEngine):
	didAnything = true
	domsLostGrip = _sexEngine.lostGrip
	mode = _sexEngine.sexMode
	
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
	var orgasmsDenied:int = 0

	func fillFromInfo(_info:SexParticipantInfo):
		charID = _info.getID()
		role = _info.role
		satisfactionRaw = _info.ai.satisfaction
		frustrationRaw = _info.ai.frustration
		
		var theTotalAm:float = satisfactionRaw + frustrationRaw
		if(theTotalAm <= 0.01): # to prevent division by zero
			theTotalAm = 0.01
			satisfaction = 0.5
		elif(theTotalAm < 1.0):
			satisfaction = (satisfactionRaw / theTotalAm)*theTotalAm + 0.5*(1.0 - theTotalAm)
		else:
			satisfaction = satisfactionRaw / theTotalAm
		
		orgasms = _info.orgasmAmount
		orgasmsDenied = _info.orgasmsDeniedAmount

func generateText(_sex:SexEngine) -> String:
	var result:Array[String] = []
	result.append("The sex has ended.")
	if(mode == SexEngine.MODE_FORCED):
		result.append("- The sex has ended in the forced mode!")
	if(domsLostGrip):
		result.append("- The dom has lost grip on the sub!")
	result.append("")
	result.append("Participants:")
	for _charID in participants:
		var theResultParticipant := participants[_charID]
		var theCharacter := GM.main.characterRegistry.getCharacter(_charID)
		if(!theCharacter):
			continue
		result.append(theCharacter.getFullName()+" ("+SexRole.getName(theResultParticipant.role)+")")
		result.append("Satisfaction: "+str(Util.roundF(theResultParticipant.satisfaction*100.0, 1))+"%")
		result.append("Times came: "+str(theResultParticipant.orgasms))
		if(theResultParticipant.orgasmsDenied > 0):
			result.append("Times denied: "+str(theResultParticipant.orgasmsDenied))
		
		result.append("")
	
	return Util.join(result, "\n")

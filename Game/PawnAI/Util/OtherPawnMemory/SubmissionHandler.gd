extends RefCounted
class_name SubmissionHandler

var pawn:CharacterPawn

var dominance:float = 0.0 # Basically a timer
var obeyCharID:String
var obeyPawn:CharacterPawn
var obeyTask:int = ObeyTask.Nothing

func setPawn(_p:CharacterPawn):
	pawn = _p

func isObeying() -> bool:
	if(obeyPawn):
		return true
	return false

func refreshDominance():
	if(!isObeying()):
		return
	dominance = 1.0

func checkObeyPawn():
	if(obeyPawn):
		if(obeyCharID.is_empty()):
			obeyPawn = null
			onObeyPawnChanged()
			return
	else:
		if(!obeyCharID.is_empty()):
			var thePawn := GM.main.pawn_registry.getPawn(obeyCharID)
			if(thePawn):
				obeyPawn = thePawn
			else:
				obeyCharID = ""
			onObeyPawnChanged()

func onObeyPawnChanged():
	pass

func setObeyPawn(_otherPawn:CharacterPawn):
	if(obeyPawn == _otherPawn):
		return
	
	if(!_otherPawn):
		obeyPawn = null
		obeyCharID = ""
		dominance = 0.0
		onObeyPawnChanged()
		return
	obeyCharID = _otherPawn.getID()
	obeyPawn = _otherPawn
	dominance = 1.0
	obeyTask = ObeyTask.Follow
	onObeyPawnChanged()

func shouldIgnoreAttacksTowards(_otherPawn:CharacterPawn) -> bool:
	if(_otherPawn == obeyPawn):
		return true
	return false

func processSubmission(_dt:float):
	checkObeyPawn()
	
	if(!obeyPawn):
		return
	
	dominance -= _dt * 0.01
	if(dominance <= 0.0):
		setObeyPawn(null)

func isObeyingPawn(_pawn:CharacterPawn) -> bool:
	return obeyPawn == _pawn

func getHoverText() -> String:
	if(!obeyPawn):
		return ""
	return "( Dominated by "+obeyPawn.getCharacter().getName()+" ("+str(Util.roundF(dominance*100.0, 1))+"%), task="+ObeyTask.getName(obeyTask)+" )"

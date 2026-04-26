extends RefCounted
class_name SubmissionHandler

var pawn:CharacterPawn

var dominance:float = 0.0 # Basically a timer
var obeyCharID:String
var obeyPawn:CharacterPawn
var obeyTask:int = ObeyTask.Nothing

var obeyPose:String = ""
var obeyPoseHands:String = ""

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

func canBeDominated() -> bool:
	if(isObeying()):
		return false
	#if(pawn.isDoingSex() || pawn.isDoingSomething()):
	if(pawn.isDoingSex()):
		return false
	return true

func canBeEasilyDominatedBy(_otherPawn:CharacterPawn) -> bool:
	if(!canBeDominated()):
		return false
	if(!pawn.isDefeated()):
		return false
	return true

func tryMakeObeyPawn(_otherPawn:CharacterPawn) -> bool:
	if(!canBeDominated()):
		return false
	if(!_otherPawn):
		return false
	setObeyPawn(_otherPawn)
	return obeyPawn == _otherPawn

func stopObeing(_otherPawn:CharacterPawn):
	if(obeyPawn != _otherPawn):
		return
	setObeyPawn(null)

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

# Added this code to poseHandler instead
#func processRare(_dt:float):
	#if(isObeying()):
		#return
	#pawn.poseHandler.idle = ""
	#pawn.poseHandler.arms = ""

func processSubmission(_dt:float):
	checkObeyPawn()
	
	if(!obeyPawn):
		return
	
	if(pawn.isLeashedBy(obeyPawn)):
		dominance += _dt * 0.05
	else:
		dominance -= _dt * 0.01
	if(dominance <= 0.0):
		setObeyPawn(null)
		return
	dominance = clampf(dominance, 0.0, 1.0)
	#if(!obeyPose.is_empty()):
	#	pawn.

func isObeyingPawn(_pawn:CharacterPawn) -> bool:
	return obeyPawn == _pawn

func getHoverText() -> String:
	if(!obeyPawn):
		return ""
	if(pawn.isDoingSex()):
		return ""
	return "( Dominated by "+obeyPawn.getCharacter().getName()+" ("+str(Util.roundF(dominance*100.0, 1))+"%), task="+ObeyTask.getName(obeyTask)+" )"

func getOverallSubmissionValue() -> float:
	return dominance

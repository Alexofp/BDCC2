extends AIActionBase

# If got stuck (xz-ignore-y position doesn't change):
# Try jumping first
# Move to a random direction?
# If still stuck, teleport to the next node, whatever

var target:Vector3 = Vector3(0.0, 0.0, 0.0)
var stuckTimer:int = 0
var savedPos:Vector3 = Vector3(0.0, 0.0, 0.0)
var completeDistance:float = 2.0
var run:bool = false

func _init() -> void:
	id = "GoTo"

func start(_args:Array):
	if(_args.is_empty()):
		failAction()
		return
	target = _args[0]
	goTowards(target)
	savedPos = getPosNoY()

func onEnd():
	stopWalking()

func processAction(_dt:float):
	#getDistSquaredTo(target) < 10.0 && 
	var theNavAgent := getAI().getNavAgent()
	
	if((theNavAgent.is_navigation_finished() && theNavAgent.target_position.distance_squared_to(target) <= (completeDistance*completeDistance)*0.5) || getPawn().global_position.distance_squared_to(target) <= (completeDistance*completeDistance)):
		completeAction()

func think():
	var thePawn := getPawn()
	var curPoseSpot := GM.sitManager.getSeatOfPawn(thePawn)
	if(curPoseSpot):
		var theHandler := curPoseSpot.getHandler()
		if(theHandler is PropHandlerBase):
			var ourSlot:String = theHandler.getSlotOfPawn(thePawn)
			if(ourSlot.is_empty()):
				return
			
			if(!theHandler.canGetUpFromSlot(ourSlot)):
				impossibleAction()
				return
			
			# Replace with a SitProp action?
			#theHandler.setSitter(ourSlot, null)
			var _doAct := thePawn.doInteractEntryDo(InteractEntryDo.create(
				"SitProp", [ourSlot],
			), theHandler)
		return
	
	if(thePawn.isLeashedByAnyone() && !thePawn.submission.isObeying()):
		stopWalking()
		if(!thePawn.isDoingSomething()):
			var _doAct := thePawn.doInteractEntryDo(InteractEntryDo.create(
				"LeashFreeSelf",
			), thePawn)
		return
		
	goTowards(target, run)
	var curPos := getPosNoY()
	var theDist := curPos.distance_squared_to(savedPos)
	#print(theDist)
	if(theDist < 0.5 && getPawn().canMove()):
		stuckTimer += 1
		if(stuckTimer >= 8):
			teleportToNextPathPosition()
			stuckTimer = 0
		elif((stuckTimer % 3) == 2):
			doJump()
	elif(stuckTimer > 0):
		stuckTimer = int(stuckTimer * 0.5)
	
	savedPos = curPos
	
	#if(RNG.chance(20)):
	#	startSubAction("Wait")

func getDebugText() -> String:
	return "pos:"+strSmart(target)+",timer:"+strSmart(stuckTimer)

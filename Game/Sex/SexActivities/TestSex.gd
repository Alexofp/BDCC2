extends SexMainActivity

const SEX_SPEED_SLOW = 0
const SEX_SPEED_NORMAL = 1
const SEX_SPEED_FAST = 2

const ROLE_TOP = "top"
const ROLE_BOTTOM = "bottom"

const SEX_SPEEDS = [
	SEX_SPEED_SLOW, SEX_SPEED_NORMAL, SEX_SPEED_FAST
]
const SEX_SPEEDS_ANIM = [
	"slow", "sex", "fast",
]
var sexSpeed:int = SEX_SPEED_SLOW

func _init():
	id = SexActivity.TestSex

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_TOP, ROLE_BOTTOM])
	
func start_run():
	playAnim(AnimScene.TestSex, "tease", {dom={id=ROLE_TOP}, sub=ROLE_BOTTOM})

func start_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	var penetrateEnabled:bool = isReadyToPenetrate(ROLE_TOP) && isZoneReadyToBePenetrated(ROLE_BOTTOM, ZoneCover.Vagina)
	var penetrateScore:float = taskScore(ROLE_TOP, SexTask.CumInsideVaginal, [getRoleID(ROLE_BOTTOM)])
	addAction(action("Penetrate").setEnabled(penetrateEnabled).setScore(penetrateScore).consent().do("startSex"))
	
func start_do(_role:String, _id:String, _args:Array):
	if(_id == "startSex"):
		sexSpeed = SEX_SPEED_SLOW
		pushDelay(0.3)
		pushSetState("sex")

func playCurrentSexAnim():
	playAnim(AnimScene.TestSex, SEX_SPEEDS_ANIM[sexSpeed], {dom={id=ROLE_TOP, guidePenisVag="sub"}, sub=ROLE_BOTTOM})

func sex_run():
	playCurrentSexAnim()

func sex_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	if(sexSpeed < SEX_SPEED_FAST):
		addAction(action("Faster").setScore(0.1).do("sex_faster"))
	if(sexSpeed > SEX_SPEED_SLOW):
		addAction(action("Slower").do("sex_slower"))
	addAction(action("Pause").do("pause"))

func sex_do(_role:String, _id:String, _args:Array):
	if(_id == "sex_slower"):
		sexSpeed -= 1
		playCurrentSexAnim()
	if(_id == "sex_faster"):
		sexSpeed += 1
		playCurrentSexAnim()
	if(_id == "pause"):
		setState("inside")

func subDoCum():
	doOrgasm(ROLE_BOTTOM, ROLE_TOP, SexOrgasmType.Vaginal, SexOrgasmCause.Penis, SexOrgasmIntensity.Normal)
	playOneShot("bottomCum")

func domDoCum():
	sexSpeed = SEX_SPEED_SLOW
	doOrgasm(ROLE_TOP, ROLE_BOTTOM, SexOrgasmType.Penile, SexOrgasmCause.Vagina, SexOrgasmIntensity.Normal)
	setState("cuminside")
	pushDelay(5.0)
	pushSetState("inside")
	
	completeTask(ROLE_TOP, SexTask.CumInsideVaginal, [getRoleID(ROLE_BOTTOM)])
	#taskScore(ROLE_TOP, SexTask.CumInsideVaginal, [getRoleID(ROLE_BOTTOM)])
	#taskScore(ROLE_TOP, SexTask.Undress, [getRoleID(ROLE_BOTTOM)])
	#scoreStop(ROLE_TOP)

func canSatisfyTask(_info:SexParticipantInfo, _taskID:String, _args:Array) -> bool:
	if(_taskID == SexTask.CumInsideVaginal && _args.size()>0 && _args[0] == getRoleID(ROLE_BOTTOM)):
		return true
	return false

func getSubTasks(_info:SexParticipantInfo, _taskID:String, _args:Array) -> Array:
	if(_taskID == SexTask.CumInsideVaginal):
		var result:Array = []
		var theChar := _info.getChar()
		var theTarget := GM.characterRegistry.getCharacter(_args[0])
		
		if(theChar && theChar.isZoneCovered(ZoneCover.Penis)):
			result.append(task(SexTask.Undress, [_info.getID()]))
		if(theTarget && theTarget.isZoneCovered(ZoneCover.Vagina)):
			result.append(task(SexTask.Undress, [_args[0]]))
		
		return result
	return []

func sex_process(_dt:float):
	if(isReadyToCum(ROLE_BOTTOM)):
		subDoCum()
	if(!isQueueBusy() && isReadyToCum(ROLE_TOP)):
		domDoCum()

func cuminside_run():
	playAnim(AnimScene.TestSex, "cum", {dom={id=ROLE_TOP, guidePenisVag="sub"}, sub=ROLE_BOTTOM})

func inside_run():
	playAnim(AnimScene.TestSex, "inside", {dom={id=ROLE_TOP, guidePenisVag="sub"}, sub=ROLE_BOTTOM})
	
func inside_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	addAction(action("Fuck more").setScore(1.0-scoreStop(ROLE_TOP)).do("fuckmore"))
	addAction(action("Pull out").setScore(scoreStop(ROLE_TOP)).do("pullout"))

func inside_do(_role:String, _id:String, _args:Array):
	if(_id == "pullout"):
		setState("")
	if(_id == "fuckmore"):
		setState("sex")

func getActions(_role:String):
	if(!canDoDomActions(_role)):
		return
	addAction(action("Stop sex").setScore(scoreStop(ROLE_TOP)).do("stopSex"))

func doAction(_role:String, _id:String, _args:Array):
	if(_id == "stopSex"):
		pushDelayCanCancel(0.5, _role)
		pushEvent(SexEvent.make("stopSex"))

func doEvent(_event:SexEvent):
	if(_event.id == "stopSex"):
		addActionText("They decide to stop fucking!")
		endActivity()

func getExpressionState(_role:String) -> int:
	if(state in ["sex"]):
		if(_role == ROLE_TOP):
			return DollExpressionState.SexGiving
		return DollExpressionState.SexReceiving
	return DollExpressionState.Normal

func onAnimEvent(_animID:String, _animState:String, _eventID:String, _args:Variant):
	if(_animID == AnimScene.TestSex):
		if(_eventID == "plap"):
			var _dt:float = 1.0
			
			#if(state == "slow"):
			processVaginalSex(ROLE_TOP, ROLE_BOTTOM, 0.5)
			addAutomoan(ROLE_BOTTOM, _dt*2.0, 25.0)
			#if(state == "sex"):
				#processVaginalSex(ROLE_TOP, ROLE_BOTTOM, 1.0)
				#addAutomoan(ROLE_BOTTOM, _dt*2.0, 25.0)
			#if(state == "fast" || state == "inside"):
				#processVaginalSex(ROLE_TOP, ROLE_BOTTOM, 1.5)
				#addAutomoan(ROLE_BOTTOM, _dt*2.0, 25.0)

func doProcess(_dt:float):
	if(state == "sex"):
		exposeFetish(ROLE_TOP, ROLE_BOTTOM, Fetish.SexVaginal, _dt*0.02)
	else:
		exposeFetish(ROLE_TOP, ROLE_BOTTOM, Fetish.SexVaginal, _dt*0.01)
	

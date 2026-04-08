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
const SEX_AROUSAL_GAIN = [
	1.0, 2.0, 4.0,
]

const MAINFETISH = Fetish.Tribadism

const MAINANIM = AnimScene.Tribadism

func _init():
	id = SexActivity.Tribadism
	poseSupport = true
	
	canDoTasks = {
		SexTask.CumTribadism: true,
	}

func isActivitySupported(_sexEngine:SexEngine) -> bool:
	if(_sexEngine.getParticipants().size() != 2):
		return false
	if(!doesSexEngineHaveAnyPossiblePoses(_sexEngine)):
		return false
	return true

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_info == _target || !_info.canDoDomActions() || _sexEngine.hasMainActivity()):
		return
	if(!_info.getChar().hasReachableVagina() || !_target.getChar().hasReachableVagina()):
		return
	var theScore:float = _info.taskScore(SexTask.CumTribadism, _target)
	addAction(action("Tribadism")
	.setCat(CATEGORY_SEX)
	.setScore(theScore)
	.expose(_info, _target, MAINFETISH)
	.consent([_target], conTexts("{top.You} {top.youVerb ask} to rub pussies with {bottom.you}.", "{top.You} {top.youVerb try|tries} to force tribadism with {bottom.you}.", {top=_info,bottom=_target}))
	.start({ROLE_TOP:_info,ROLE_BOTTOM:_target}, {})
	)

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_TOP, ROLE_BOTTOM])
	pickRandomPose()
	doPoseText(ROLE_TOP, "start", {},
	"{top.You} {top.youVerb interlock} legs with {bottom.you}!")
	
func start_run():
	playAnim(MAINANIM, "tease", {dom={id=ROLE_TOP}, sub=ROLE_BOTTOM})

func start_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	#var penetrateEnabled:bool = isReadyToPenetrate(ROLE_TOP) && isZoneReadyToBePenetrated(ROLE_BOTTOM, getPenetrateZone())
	var startScore:float = taskScore(ROLE_TOP, SexTask.CumTribadism, ROLE_BOTTOM)
	addAction(action("Rub pussies")
	#.setEnabled(penetrateEnabled)
	.setScore(startScore)
	.consent([ROLE_BOTTOM], conTexts("{top.You} {top.youVerb want} to start rubbing pussies with {bottom.you}.", "{top.You} {top.youVerb try|tries} to force pussy rubbing with {bottom.you}."))
	.do("startSex")
	)
	
func start_do(_role:String, _id:String, _args:Array):
	if(_id == "startSex"):
		#sexSpeed = SEX_SPEED_SLOW
		setState("sex")
		doText(ROLE_TOP, "{top.You} {top.youVerb start} rubbing pussies with {bottom.you}!")

func playCurrentSexAnim():
	playAnim(MAINANIM, SEX_SPEEDS_ANIM[sexSpeed], {dom=ROLE_TOP, sub=ROLE_BOTTOM})

func sex_run():
	playCurrentSexAnim()

func sex_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	if(sexSpeed < SEX_SPEED_FAST):
		var fasterScore:float = 0.1
		if(sexSpeed == SEX_SPEED_SLOW):
			fasterScore = 0.05 + maxf((getArousal(_role)-0.2)/0.8, 0.0)*0.5
		if(sexSpeed == SEX_SPEED_NORMAL):
			fasterScore = 0.05 + maxf((getArousal(_role)-0.5)/0.5, 0.0)*0.5
		
		addAction(action("Faster").setScore(fasterScore).do("sex_faster"))
	if(sexSpeed > SEX_SPEED_SLOW):
		addAction(action("Slower").do("sex_slower"))
	addAction(action("Pause").do("pause"))
	
	if(isReadyToCum(ROLE_TOP) && isReadyToCum(ROLE_BOTTOM)):
		addAction(action("Double orgasm!")
			.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			.setScore(1.0)
			.do("orgasm"))
		addAction(action("Delay orgasms")
			.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			.setScore(0.0)
			.do("delayCum"))
		addAction(action("Deny sub")
			.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			.setScore(0.0)
			.do("orgasm", [true]))
	elif(isReadyToCum(_role)):
		addAction(action("Orgasm!")
			.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			.setScore(1.0)
			.do("orgasm"))
		addAction(action("Delay orgasm")
			.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			.setScore(0.0)
			.do("delayCum"))
	elif(isReadyToCum(ROLE_BOTTOM)):
		addAction(action("Allow sub orgasm")
			.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			.setScore(1.0)
			.do("orgasm"))
		addAction(action("Deny sub")
			.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			.setScore(0.0)
			.do("delayCum"))

func sex_do(_role:String, _id:String, _args:Array):
	if(_id == "sex_slower"):
		sexSpeed -= 1
		playCurrentSexAnim()
		doText(_role, "{top.You} {top.youVerb start} rubbing pussies with {bottom.you} slower.")
	if(_id == "sex_faster"):
		sexSpeed += 1
		playCurrentSexAnim()
		doText(_role, "{top.You} {top.youVerb start} rubbing pussies with {bottom.you} faster.")
	if(_id == "pause"):
		setState("")
		doText(_role, "{top.You} {top.youVerb pause} the pussy rubbing.")
	if(_id == "orgasm"):
		#domDoCum()
		completeTask(ROLE_TOP, SexTask.CumTribadism, ROLE_BOTTOM)
		var isDeny:bool = (!_args.is_empty() && _args[0])
		sexSpeed = SEX_SPEED_SLOW
		if(isReadyToCum(ROLE_TOP) && isReadyToCum(ROLE_BOTTOM) && !isDeny):
			setState("orgasmBoth")
			doText(ROLE_BOTTOM, "Double orgasm! Both, {top.you} and {bottom.you} cum together!")
		elif(isReadyToCum(ROLE_TOP)):
			setState("orgasm1")
			if(isDeny):
				doText(ROLE_BOTTOM, "{top.You} {top.youVerb deny|denies} {bottom.you} and {top.youVerb cum} alone!")
			else:
				doText(ROLE_BOTTOM, "{top.You} {top.youVerb cum}!")
		else:
			setState("orgasm2")
			doText(ROLE_BOTTOM, "{bottom.You} {bottom.youVerb cum}!")
			
		if(isReadyToCum(ROLE_TOP)):
			doOrgasm(ROLE_TOP, ROLE_BOTTOM, SexOrgasmType.Vaginal, SexOrgasmCause.Vagina, SexOrgasmIntensity.Normal)
			addAutomoan(ROLE_TOP, 20.0, 20.0)
		if(isReadyToCum(ROLE_BOTTOM) && !isDeny):
			doOrgasm(ROLE_BOTTOM, ROLE_TOP, SexOrgasmType.Vaginal, SexOrgasmCause.Vagina, SexOrgasmIntensity.Normal)
			addAutomoan(ROLE_BOTTOM, 25.0, 25.0)
			
		pushDelay(5.0)
		pushSetState("")

	if(_id == "delayCum"):
		var domDelayed:bool = false
		var subDelayed:bool = false
		if(isReadyToCum(ROLE_TOP)):
			domDelayed = true
			addArousal(ROLE_TOP, -0.5)
		if(isReadyToCum(ROLE_BOTTOM)):
			subDelayed = true
			addArousal(ROLE_BOTTOM, -0.5)
		if(domDelayed && subDelayed):
			doText(_role, "{top.You} {top.youVerb delay} both orgasms!")
		elif(domDelayed):
			doText(_role, "{top.You} {top.youVerb delay} {top.yourHis} orgasm!")
		else:
			doText(_role, "{top.You} {top.youVerb delay} {bottom.your} orgasm!")

func getSubSexTasks(_sexEngine:SexEngine, _task:SexTask) -> Array[SexTask]:
	return [
		undressTask(_task.actor, _task.target, [ZoneCover.Vagina]),
		undressTask(_task.actor, _task.actor, [ZoneCover.Vagina]),
	]

func getSubSexTasksExtra(_role:String) -> Array[SexTask]:
	return undressExtraForPose(pose, getRoleID(_role))

func canSatisfyTask(_task:SexTask) -> bool:
	if(isTaskOurs(_task, SexTask.CumTribadism, ROLE_TOP, ROLE_BOTTOM)):
		return true
	return false

func sex_process(_dt:float):
	#if(isReadyToCum(ROLE_BOTTOM)):
	#	subDoCum()
	#if(!isQueueBusy() && isReadyToCum(ROLE_TOP)):
	#	domDoCum()
	pass

func orgasmBoth_run():
	playAnim(MAINANIM, "orgasmBoth", {dom=ROLE_TOP, sub=ROLE_BOTTOM})

func orgasm1_run():
	playAnim(MAINANIM, "orgasm1", {dom=ROLE_TOP, sub=ROLE_BOTTOM})

func orgasm2_run():
	playAnim(MAINANIM, "orgasm2", {dom=ROLE_TOP, sub=ROLE_BOTTOM})

func getActions(_role:String):
	if(!canDoDomActions(_role)):
		if(!isForced()):
			addAction(action("Ask stop sex")
			.setScore(0.0)
			.setCooldown("askStop", 5.0)
			.consent([ROLE_TOP], conTexts("{bottom.You} {bottom.youVerb ask} to stop the penetrative sex."))
			.do("stopSex"))
		return
	if(state != "inside"): #Maybe make it so you can only stop sex if not sexing?
		addAction(action("Stop sex").setScore(scoreStop(ROLE_TOP)).do("stopSex"))

func doAction(_role:String, _id:String, _args:Array):
	if(_id == "stopSex"):
		doText(_role, "{top.You} decided to stop fucking {bottom.you}.")
		endActivity()

func doEvent(_event:SexEvent):
	pass

func getExpressionState(_role:String) -> int:
	if(state in ["sex"]):
		if(_role == ROLE_TOP):
			return DollExpressionState.SexGiving
		return DollExpressionState.SexReceiving
	return DollExpressionState.Normal

#func onAnimEvent(_animID:String, _animState:String, _eventID:String, _args:Variant):
	#if(_animID == MAINANIM):
		#if(_eventID == "plap"):
			##processSex(getPenetrateZone(), ROLE_TOP, ROLE_BOTTOM, 0.5)
			#addAutomoan(ROLE_BOTTOM, 2.0, 25.0)

func doProcess(_dt:float):
	if(state == "sex"):
		stimulate(ROLE_TOP, S_VAGINA, ROLE_BOTTOM, S_VAGINA, I_NORMAL, MAINFETISH, _dt*0.02*SEX_AROUSAL_GAIN[sexSpeed])
		addAutomoan(ROLE_TOP, _dt*1.5, 10.0)
		addAutomoan(ROLE_BOTTOM, _dt*1.5, 14.0)
		exposeFetish(ROLE_TOP, ROLE_BOTTOM, MAINFETISH, _dt*0.02)
	else:
		exposeFetish(ROLE_TOP, ROLE_BOTTOM, MAINFETISH, _dt*0.01)
	

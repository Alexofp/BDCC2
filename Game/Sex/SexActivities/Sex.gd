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
var isVaginal:bool = false
var didSubJustCumTimer:float = 0.0
const SEX_AROUSAL_GAIN = [
	1.0, 2.0, 4.0,
]

func getFetish() -> String:
	if(isVaginal):
		return Fetish.SexVaginal
	return Fetish.SexAnal

var pose:String = ""

func _init():
	id = SexActivity.Sex

func getCumInsideTask() -> String:
	if(isVaginal):
		return SexTask.CumInsideVaginal
	return SexTask.CumInsideAnal

func getPenetrateZone() -> int:
	if(isVaginal):
		return ZoneCover.Vagina
	return ZoneCover.Anus

# Do this based on pose availability instead
const SUPPORTED_ACTIVITIES = [
	SexType.OnTheFloor,
	SexType.InStocks,
	SexType.AgainstWall,
]

func isActivitySupported(_sexEngine:SexEngine) -> bool:
	if(_sexEngine.getParticipants().size() != 2):
		return false
	if(!SUPPORTED_ACTIVITIES.has(_sexEngine.getSexTypeID())):
		return false
	return true

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_info == _target || !_info.canDoDomActions() || _sexEngine.hasMainActivity()):
		return
	if(_target.getChar().hasReachableVagina()):
		var vagSexScore:float = _info.taskScore(SexTask.CumInsideVaginal, [_target.getID()])
		addAction(action("Vaginal sex")
		.setCat(CATEGORY_SEX)
		.setScore(vagSexScore)
		.expose(_info, _target, Fetish.SexVaginal)
		.consent([_target], conTexts("{top.You} {top.youVerb ask} to have vaginal sex with {bottom.you}.", "{top.You} {top.youVerb try|tries} to force vaginal sex with {bottom.you}.", {top=_info,bottom=_target}))
		.start({ROLE_TOP:_info,ROLE_BOTTOM:_target}, {vaginal=true})
		)

	if(_target.getChar().hasReachableAnus()):
		var analSexScore:float = _info.taskScore(SexTask.CumInsideAnal, [_target.getID()])
		addAction(action("Anal sex")
		.setCat(CATEGORY_SEX)
		.setScore(analSexScore)
		.expose(_info, _target, Fetish.SexAnal)
		.consent([_target], conTexts("{top.You} {top.youVerb ask} to have anal sex with {bottom.you}.", "{top.You} {top.youVerb try|tries} to force anal sex with {bottom.you}.", {top=_info,bottom=_target}))
		.start({ROLE_TOP:_info,ROLE_BOTTOM:_target}, {vaginal=false})
		)

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_TOP, ROLE_BOTTOM])
	pose = pickRandomPose()
	isVaginal = _args["vaginal"] if _args.has("vaginal") else false
	doText(ROLE_TOP, "{top.You} {top.youVerb grab} {bottom.your} wrists and {top.youVerb prepare} to fuck {bottom.yourHis} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+"!")
	
func start_run():
	playPoseOrAnim(pose, AnimScene.TestSex, "tease", {dom={id=ROLE_TOP}, sub=ROLE_BOTTOM}, {hole=(AnimSceneHole.Vagina if isVaginal else AnimSceneHole.Anus)})

func start_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	var penetrateEnabled:bool = isReadyToPenetrate(ROLE_TOP) && isZoneReadyToBePenetrated(ROLE_BOTTOM, getPenetrateZone())
	var penetrateScore:float = taskScore(ROLE_TOP, getCumInsideTask(), [getRoleID(ROLE_BOTTOM)])
	var zoneName := zoneLewdName(ROLE_BOTTOM, ZoneCover.Vagina if isVaginal else ZoneCover.Anus)
	addAction(action("Penetrate")
	.setEnabled(penetrateEnabled)
	.setScore(penetrateScore)
	.consent([], conTexts("{top.You} {top.youVerb want} to penetrate {bottom.your} "+zoneName+".", "{top.You} {top.youVerb try|tries} to forcefully penetrate {bottom.your} "+zoneName+"."))
	.do("startSex")
	)
	
func start_do(_role:String, _id:String, _args:Array):
	if(_id == "startSex"):
		sexSpeed = SEX_SPEED_SLOW
		pushDelay(0.3)
		pushSetState("sex")
		doText(ROLE_TOP, "{top.You} {top.youVerb start} fucking {bottom.your} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+"!")

func playCurrentSexAnim():
	playPoseOrAnim(pose, AnimScene.TestSex, SEX_SPEEDS_ANIM[sexSpeed], {dom=ROLE_TOP, sub=ROLE_BOTTOM}, {hole=(AnimSceneHole.Vagina if isVaginal else AnimSceneHole.Anus)})

func sex_run():
	playCurrentSexAnim()

func sex_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	if(sexSpeed < SEX_SPEED_FAST):
		var fasterScore:float = 0.1
		if(sexSpeed == SEX_SPEED_SLOW):
			fasterScore = 0.05 + max((getArousal(_role)-0.2)/0.8, 0.0)*0.5
		if(sexSpeed == SEX_SPEED_NORMAL):
			fasterScore = 0.05 + max((getArousal(_role)-0.5)/0.5, 0.0)*0.5
		
		addAction(action("Faster").setScore(fasterScore).do("sex_faster"))
	if(sexSpeed > SEX_SPEED_SLOW):
		addAction(action("Slower").do("sex_slower"))
	addAction(action("Pause").do("pause"))
	
	if(isReadyToCum(ROLE_TOP)):
		addAction(action("Cum inside!")
			.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			.setScore(0.2 if didSubJustCumTimer <= 0.0 else 1.0)
			.do("cumInside"))
		addAction(action("Delay orgasm")
			.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			.setScore(0.0)
			.do("delayCum"))

func sex_do(_role:String, _id:String, _args:Array):
	if(_id == "sex_slower"):
		sexSpeed -= 1
		playCurrentSexAnim()
		doText(_role, "{top.You} {top.youVerb start} fucking {bottom.your} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+" slower.")
	if(_id == "sex_faster"):
		sexSpeed += 1
		playCurrentSexAnim()
		doText(_role, "{top.You} {top.youVerb start} fucking {bottom.your} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+" faster!")
	if(_id == "pause"):
		setState("inside")
		doText(_role, "{top.You} {top.youVerb pause} the fucking.")
	if(_id == "cumInside"):
		domDoCum()
	if(_id == "delayCum"):
		addArousal(ROLE_TOP, -0.5)
		doText(_role, "{top.You} {top.youVerb delay} {top.yourHis} orgasm.")
	
func subDoCum():
	didSubJustCumTimer = 2.0 # Makes the dom more eager to cum
	doOrgasm(ROLE_BOTTOM, ROLE_TOP, SexOrgasmType.Vaginal if isVaginal else SexOrgasmType.Anal, SexOrgasmCause.Penis, SexOrgasmIntensity.Normal)
	playOneShot("bottomCum")
	doText(ROLE_BOTTOM, "{bottom.You} {bottom.youVerb cum}!")

func domDoCum():
	sexSpeed = SEX_SPEED_SLOW
	if(getArousal(ROLE_BOTTOM) >= 0.96): # To make sure sub cums too
		processSex(getPenetrateZone(), ROLE_TOP, ROLE_BOTTOM, 1.0)
	doOrgasm(ROLE_TOP, ROLE_BOTTOM, SexOrgasmType.Penile, SexOrgasmCause.Vagina if isVaginal else SexOrgasmCause.Anus, SexOrgasmIntensity.Normal)
	doText(ROLE_TOP, "{top.You} {top.youVerb start} cumming inside {bottom.your} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+"!")
	setState("cuminside")
	pushDelay(5.0)
	pushSetState("inside")
	
	completeTask(ROLE_TOP, getCumInsideTask(), [getRoleID(ROLE_BOTTOM)])

func canSatisfyTask(_info:SexParticipantInfo, _taskID:String, _args:Array) -> bool:
	if(_taskID == getCumInsideTask() && _args.size()>0 && _args[0] == getRoleID(ROLE_BOTTOM)):
		return true
	return false

func getSubTasks(_info:SexParticipantInfo, _taskID:String, _args:Array) -> Array:
	if(_taskID in [SexTask.CumInsideVaginal, SexTask.CumInsideAnal]):
		var result:Array = []
		var theChar := _info.getChar()
		var theTarget := GM.characterRegistry.getCharacter(_args[0])
		
		if(theChar && theChar.isZoneCovered(ZoneCover.Penis)):
			result.append(task(SexTask.Undress, [_info.getID()]))
		if((_taskID == SexTask.CumInsideVaginal) && theTarget && theTarget.isZoneCovered(ZoneCover.Vagina)):
			result.append(task(SexTask.Undress, [_args[0]]))
		if((_taskID == SexTask.CumInsideAnal) && theTarget && theTarget.isZoneCovered(ZoneCover.Anus)):
			result.append(task(SexTask.Undress, [_args[0]]))
		
		return result
	return []

func sex_process(_dt:float):
	if(isReadyToCum(ROLE_BOTTOM)):
		subDoCum()
	#if(!isQueueBusy() && isReadyToCum(ROLE_TOP)):
	#	domDoCum()

func cuminside_run():
	playPoseOrAnim(pose, AnimScene.TestSex, "cum", {dom=ROLE_TOP, sub=ROLE_BOTTOM}, {hole=(AnimSceneHole.Vagina if isVaginal else AnimSceneHole.Anus)})

func inside_run():
	playPoseOrAnim(pose, AnimScene.TestSex, "inside", {dom=ROLE_TOP, sub=ROLE_BOTTOM}, {hole=(AnimSceneHole.Vagina if isVaginal else AnimSceneHole.Anus)})
	
func inside_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	addAction(action("Fuck more").setScore(1.0-scoreStop(ROLE_TOP)).do("fuckmore"))
	addAction(action("Pull out").setScore(scoreStop(ROLE_TOP)).do("pullout"))

func inside_do(_role:String, _id:String, _args:Array):
	if(_id == "pullout"):
		doText(_role, "{top.You} {top.youVerb pull} {top.yourHis} {top.penis} out.")
		setState("")
	if(_id == "fuckmore"):
		doText(_role, "{top.You} {top.youVerb continue} to fuck {bottom.your} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+"!")
		setState("sex")

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
	
	if(canDoDomActions(_role)):# && state == "tease"):
		addPosePickActions("pickPose")
	
func doAction(_role:String, _id:String, _args:Array):
	if(_id == "stopSex"):
		doText(_role, "{top.You} decided to stop fucking {bottom.you}.")
		endActivity()

	if(_id == "pickPose"):
		pose = setPoseFromPickAction(pose, _args)
		doText(_role, "{"+_role+".You} {"+_role+".youVerb switch|switches} the pose!")
		doRun()

func doEvent(_event:SexEvent):
	pass

func getExpressionState(_role:String) -> int:
	if(state in ["sex"]):
		if(_role == ROLE_TOP):
			return DollExpressionState.SexGiving
		return DollExpressionState.SexReceiving
	return DollExpressionState.Normal

func onAnimEvent(_animID:String, _animState:String, _eventID:String, _args:Variant):
	#if(_animID == AnimScene.TestSex):
		#if(_eventID == "plap"):
			#processSex(getPenetrateZone(), ROLE_TOP, ROLE_BOTTOM, 0.5)
			#addAutomoan(ROLE_BOTTOM, 2.0, 25.0)
	pass

func doProcess(_dt:float):
	if(didSubJustCumTimer > 0.0):
		didSubJustCumTimer -= _dt
		if(didSubJustCumTimer < 0.0):
			didSubJustCumTimer = 0.0
		
	#if(state == "sex"):
	#	exposeFetish(ROLE_TOP, ROLE_BOTTOM, Fetish.SexVaginal if isVaginal else Fetish.SexAnal, _dt*0.02)
	#else:
	#	exposeFetish(ROLE_TOP, ROLE_BOTTOM, Fetish.SexVaginal if isVaginal else Fetish.SexAnal, _dt*0.01)
	
	if(state == "sex"):
		stimulate(ROLE_TOP, S_PENIS, ROLE_BOTTOM, S_VAGINA if isVaginal else S_ANUS, I_NORMAL, getFetish(), _dt*0.02*SEX_AROUSAL_GAIN[sexSpeed])
		#addAutomoan(ROLE_TOP, _dt*1.5, 10.0)
		addAutomoan(ROLE_BOTTOM, _dt*1.5, 25.0)
		exposeFetish(ROLE_TOP, ROLE_BOTTOM, getFetish(), _dt*0.02)
	else:
		exposeFetish(ROLE_TOP, ROLE_BOTTOM, getFetish(), _dt*0.01)

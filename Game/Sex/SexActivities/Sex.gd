extends SexMainActivity

const SEX_SPEED_SLOW = 0
const SEX_SPEED_NORMAL = 1
const SEX_SPEED_FAST = 2

const ROLE_TOP := "top"
const ROLE_BOTTOM := "bottom"

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

func _init():
	id = SexActivity.Sex
	poseSupport = true
	
	canDoTasks = {
		SexTask.CumInsideVaginal: true,
		SexTask.CumInsideAnal: true,
	}

func getCumInsideTask() -> String:
	if(isVaginal):
		return SexTask.CumInsideVaginal
	return SexTask.CumInsideAnal

func getPenetrateZone() -> int:
	if(isVaginal):
		return ZoneCover.Vagina
	return ZoneCover.Anus

# Do this based on pose availability instead
#const SUPPORTED_ACTIVITIES = [ # Can remove me
	#SexType.OnTheFloor,
	#SexType.InStocks,
	#SexType.AgainstWall,
#]

func isActivitySupported(_sexEngine:SexEngine) -> bool:
	if(_sexEngine.getParticipants().size() != 2):
		return false
	#if(!SUPPORTED_ACTIVITIES.has(_sexEngine.getSexTypeID())):
	#	return false
	if(!doesSexEngineHaveAnyPossiblePoses(_sexEngine)):
		return false
	return true


func getSubSexTasks(_sexEngine:SexEngine, _task:SexTask) -> Array[SexTask]:
	var theSubUndress:Array[int] = []
	if(_task.id == SexTask.CumInsideVaginal):
		theSubUndress.append(ZoneCover.Vagina)
	if(_task.id == SexTask.CumInsideAnal):
		theSubUndress.append(ZoneCover.Anus)
	
	return [
		undressTask(_task.actor, _task.actor, [ZoneCover.Penis]),
		undressTask(_task.actor, _task.target, theSubUndress),
		SexTask.create(SexTask.WearStrapon, _task.actor, _task.actor),
	]

func canSatisfyTask(_task:SexTask) -> bool:
	if(isTaskOurs(_task, getCumInsideTask(), ROLE_TOP, ROLE_BOTTOM)):
		return true
	return false

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_info == _target || !_info.canDoDomActions() || _sexEngine.hasMainActivity()):
		return
	if(_target.getChar().hasReachableVagina()):
		var vagSexScore:float = _info.taskScore(SexTask.CumInsideVaginal, _target)
		addAction(action("Vaginal sex")
		.setRoles({ROLE_TOP: _info, ROLE_BOTTOM: _target})
		.setCat(CATEGORY_SEX)
		.setScore(vagSexScore)
		.expose(ROLE_TOP, ROLE_BOTTOM, Fetish.SexVaginal)
		.consent([ROLE_BOTTOM], conTexts("{top.You} {top.youVerb ask} to have vaginal sex with {bottom.you}.", "{top.You} {top.youVerb try|tries} to force vaginal sex with {bottom.you}."))
		.start(id, {ROLE_TOP:_info,ROLE_BOTTOM:_target}, {vaginal=true})
		)

	if(_target.getChar().hasReachableAnus()):
		var analSexScore:float = _info.taskScore(SexTask.CumInsideAnal, _target)
		addAction(action("Anal sex")
		.setRoles({ROLE_TOP: _info, ROLE_BOTTOM: _target})
		.setCat(CATEGORY_SEX)
		.setScore(analSexScore)
		.expose(ROLE_TOP, ROLE_BOTTOM, Fetish.SexAnal)
		.consent([ROLE_BOTTOM], conTexts("{top.You} {top.youVerb ask} to have anal sex with {bottom.you}.", "{top.You} {top.youVerb try|tries} to force anal sex with {bottom.you}."))
		.start(id, {ROLE_TOP:_info,ROLE_BOTTOM:_target}, {vaginal=false})
		)

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_TOP, ROLE_BOTTOM])
	pickRandomPose()
	isVaginal = _args["vaginal"] if _args.has("vaginal") else false
	
	doPoseText(ROLE_TOP, "start", {zone=zoneLewdName(ROLE_BOTTOM, getPenetrateZone())},
	"{top.You} {top.youVerb grab} {bottom.your} wrists and {top.youVerb prepare} to fuck {bottom.yourHis} %%zone%%!")
	
func start_run():
	playAnim(AnimScene.TestSex, "tease", {dom={id=ROLE_TOP}, sub=ROLE_BOTTOM}, {hole=(AnimSceneHole.Vagina if isVaginal else AnimSceneHole.Anus)})

func start_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	var penetrateEnabled:bool = isReadyToPenetrate(ROLE_TOP) && isZoneReadyToBePenetrated(ROLE_BOTTOM, getPenetrateZone())
	var penetrateScore:float = taskScore(ROLE_TOP, getCumInsideTask(), ROLE_BOTTOM)
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
	playAnim(AnimScene.TestSex, SEX_SPEEDS_ANIM[sexSpeed], {dom=ROLE_TOP, sub=ROLE_BOTTOM}, {hole=(AnimSceneHole.Vagina if isVaginal else AnimSceneHole.Anus)})

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
	
	completeTask(ROLE_TOP, getCumInsideTask(), ROLE_BOTTOM)

func sex_process(_dt:float):
	if(isReadyToCum(ROLE_BOTTOM)):
		subDoCum()
	#if(!isQueueBusy() && isReadyToCum(ROLE_TOP)):
	#	domDoCum()

func cuminside_run():
	playAnim(AnimScene.TestSex, "cum", {dom=ROLE_TOP, sub=ROLE_BOTTOM}, {hole=(AnimSceneHole.Vagina if isVaginal else AnimSceneHole.Anus)})

func inside_run():
	playAnim(AnimScene.TestSex, "inside", {dom=ROLE_TOP, sub=ROLE_BOTTOM}, {hole=(AnimSceneHole.Vagina if isVaginal else AnimSceneHole.Anus)})
	
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

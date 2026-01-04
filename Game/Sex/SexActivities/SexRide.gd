extends SexMainActivity

const SEX_SPEED_SLOW = 0
const SEX_SPEED_NORMAL = 1
const SEX_SPEED_FAST = 2

const ROLE_TOP = "top" # The one with the penis
const ROLE_BOTTOM = "bottom" # The one who rides

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

const MAINANIM = AnimScene.SexCowgirl

func getFetish() -> String:
	if(isVaginal):
		return Fetish.SexVaginal
	return Fetish.SexAnal

func getCumInsideTask() -> String:
	if(isVaginal):
		return SexTask.ReceiveCumInsideVaginal
	return SexTask.ReceiveCumInsideAnal

func getPenetrateZone() -> int:
	if(isVaginal):
		return ZoneCover.Vagina
	return ZoneCover.Anus

func canSatisfyTask(_info:SexParticipantInfo, _taskID:String, _args:Array) -> bool:
	if(_taskID == getCumInsideTask() && _args.size()>0 && _args[0] == getRoleID(ROLE_TOP)):
		return true
	return false

func getSubTasks(_info:SexParticipantInfo, _taskID:String, _args:Array) -> Array:
	if(_taskID in [SexTask.ReceiveCumInsideVaginal, SexTask.ReceiveCumInsideAnal]):
		var result:Array = []
		var theChar := _info.getChar()
		var theTarget := GM.characterRegistry.getCharacter(_args[0])
		
		if(theTarget && theTarget.isZoneCovered(ZoneCover.Penis)):
			result.append(task(SexTask.Undress, [_args[0]]))
		if((_taskID == SexTask.ReceiveCumInsideVaginal) && theChar && theChar.isZoneCovered(ZoneCover.Vagina)):
			result.append(task(SexTask.Undress, [_info.getID()]))
		if((_taskID == SexTask.ReceiveCumInsideAnal) && theChar && theChar.isZoneCovered(ZoneCover.Anus)):
			result.append(task(SexTask.Undress, [_info.getID()]))
		
		return result
	return []

func run():
	if(state == "sex"):
		playCurrentSexAnim()
		return
	if(state == "cuminside"):
		playAnim(MAINANIM, "cum", {dom=ROLE_TOP, sub=ROLE_BOTTOM}, {hole=getAnimSceneHole()})
		return
	if(state == "inside"):
		playAnim(MAINANIM, "inside", {dom=ROLE_TOP, sub=ROLE_BOTTOM}, {hole=getAnimSceneHole()})
		return
	
	playAnim(MAINANIM, "tease", {dom={id=ROLE_TOP}, sub=ROLE_BOTTOM}, {hole=getAnimSceneHole()})

func playCurrentSexAnim():
	playAnim(MAINANIM, SEX_SPEEDS_ANIM[sexSpeed], {dom=ROLE_TOP, sub=ROLE_BOTTOM}, {hole=getAnimSceneHole()})

func getAnimSceneHole() -> int:
	if(isVaginal):
		return AnimSceneHole.Vagina
	return AnimSceneHole.Anus

func _init():
	id = SexActivity.SexRide

func isActivitySupported(_sexEngine:SexEngine) -> bool:
	if(_sexEngine.getParticipants().size() != 2):
		return false
	if(_sexEngine.getSexTypeID() != SexType.OnTheFloor): #Check if we have 'animations' for this sex type instead?
		return false
	return true

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_info == _target || !_info.canDoDomActions() || _sexEngine.hasMainActivity()):
		return
	
	if(_info.getChar().hasReachableVagina()):
		var theRideScore:float = _info.taskScore(SexTask.ReceiveCumInsideVaginal, [_target.getID()])
		addAction(action("Ride (vaginal)")
		.setCat(CATEGORY_SEX)
		.setScore(theRideScore)
		.expose(_target, _info, Fetish.SexVaginal)
		.consent([_target], conTexts("{top.You} {top.youVerb ask} to have vaginal sex with {bottom.you} in a cowgirl position.", "{top.You} {top.youVerb try|tries} to force vaginal sex with {bottom.you} in a cowgirl position.", {top=_info,bottom=_target}))
		.start({ROLE_TOP:_target,ROLE_BOTTOM:_info}, {vaginal=true})
		)
	if(_info.getChar().hasReachableAnus()):
		var theRideScore:float = _info.taskScore(SexTask.ReceiveCumInsideAnal, [_target.getID()])
		addAction(action("Ride (anal)")
		.setCat(CATEGORY_SEX)
		.setScore(theRideScore)
		.expose(_target, _info, Fetish.SexAnal)
		.consent([_target], conTexts("{top.You} {top.youVerb ask} to have anal sex with {bottom.you} in a cowgirl position.", "{top.You} {top.youVerb try|tries} to force anal sex with {bottom.you} in a cowgirl position.", {top=_info,bottom=_target}))
		.start({ROLE_TOP:_target,ROLE_BOTTOM:_info}, {vaginal=false})
		)


func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_TOP, ROLE_BOTTOM])
	isVaginal = _args["vaginal"] if _args.has("vaginal") else false
	doText(ROLE_TOP, "{bottom.You} {bottom.youVerb stradle} {top.your} hips and {bottom.youVerb prepare} to ride {top.yourHis} penis with {bottom.yourHis} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+"!")
	
func start_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	var penetrateEnabled:bool = isReadyToPenetrate(ROLE_TOP) && isZoneReadyToBePenetrated(ROLE_BOTTOM, getPenetrateZone())
	var startScore:float = taskScore(ROLE_BOTTOM, getCumInsideTask(), [getRoleID(ROLE_TOP)])
	#var zoneName := zoneLewdName(ROLE_BOTTOM, ZoneCover.Vagina if isVaginal else ZoneCover.Anus)
	addAction(action("Start riding")
	.setEnabled(penetrateEnabled)
	.setScore(startScore)
	.consent([], conTexts("{"+_role+".You} {"+_role+".youVerb want} to start riding.", "{"+_role+".You} {"+_role+".youVerb try|tries} to force the sex."))
	.do("startSex")
	)
	
	addAction(action("Swap with sub")
	#.setEnabled(penetrateEnabled)
	.setScore(0.0)
	.consent([ROLE_TOP], conTexts("{top.You} {top.youVerb want} to swap spots with {bottom.you}.", "{top.You} {top.youVerb try|tries} to swap spots with {bottom.you}."))
	.do("swapSpots")
	)
	
func start_do(_role:String, _id:String, _args:Array):
	if(_id == "startSex"):
		#sexSpeed = SEX_SPEED_SLOW
		setState("sex")
		var zoneName := zoneLewdName(ROLE_BOTTOM, ZoneCover.Vagina if isVaginal else ZoneCover.Anus)
		doText(ROLE_TOP, "{bottom.You} {bottom.youVerb start} riding {top.your} cock with {bottom.yourHis} "+zoneName+"!")
	if(_id == "swapSpots"):
		swapRoles(ROLE_TOP, ROLE_BOTTOM)
		doRun()
		doText(ROLE_TOP, "{top.You} {top.youVerb swap} spots with {bottom.you}!")

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
		addAction(action("Orgasm!")
			.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			.setScore(0.2 if didSubJustCumTimer <= 0.0 else 1.0)
			.do("orgasm"))
		addAction(action("Delay orgasm")
			.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			.setScore(0.0)
			.do("delayCum"))

func sex_do(_role:String, _id:String, _args:Array):
	if(_id == "sex_slower"):
		sexSpeed -= 1
		playCurrentSexAnim()
		doText(_role, "{bottom.You} {bottom.youVerb start} riding {top.you} slower.")
	if(_id == "sex_faster"):
		sexSpeed += 1
		playCurrentSexAnim()
		doText(_role, "{bottom.You} {bottom.youVerb start} riding {top.you} faster.")
	if(_id == "pause"):
		setState("inside")
		doText(_role, "{top.You} {top.youVerb pause} the fucking.")
	if(_id == "orgasm"):
		domDoCum()

	if(_id == "delayCum"):
		addArousal(ROLE_TOP, -0.5)
		if(_role == ROLE_TOP):
			doText(_role, "{top.You} {top.youVerb delay} {top.yourHis} orgasm.")
		else:
			doText(_role, "{bottom.You} {bottom.youVerb delay} {top.your} orgasm.")

func sex_process(_dt:float):
	if(isReadyToCum(ROLE_BOTTOM)):
		subDoCum()
	#if(!isQueueBusy() && isReadyToCum(ROLE_TOP)):
	#	domDoCum()
	pass

func inside_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	addAction(action("Ride more").setScore(1.0-scoreStop(ROLE_TOP)).do("fuckmore"))
	addAction(action("Pull out").setScore(scoreStop(ROLE_TOP)).do("pullout"))

func inside_do(_role:String, _id:String, _args:Array):
	if(_id == "pullout"):
		if(_role == ROLE_TOP):
			doText(_role, "{top.You} {top.youVerb pull} {top.yourHis} {top.penis} out.")
		else:
			doText(_role, "{bottom.You} {bottom.youVerb make} {top.you} pull {top.yourHis} {top.penis} out.")
		setState("")
	if(_id == "fuckmore"):
		if(_role == ROLE_TOP):
			doText(_role, "{top.You} {top.youVerb make} {bottom.you} ride {top.yourHis} {top.penis} more with {bottom.yourHis} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+"!")
		else:
			doText(_role, "{bottom.You} {bottom.youVerb continue} to ride {top.yourHis} {top.penis} with {bottom.yourHis} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+"!")
		setState("sex")

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
	
	completeTask(ROLE_BOTTOM, getCumInsideTask(), [getRoleID(ROLE_TOP)])

func getActions(_role:String):
	if(!canDoDomActions(_role)):
		if(!isForced()):
			addAction(action("Ask stop sex")
			.setScore(0.0)
			.setCooldown("askStop", 5.0)
			.consent([], conTexts("{"+_role+".You} {"+_role+".youVerb ask} to stop the penetrative sex."))
			.do("stopSex"))
		return
	if(state != "inside"): #Maybe make it so you can only stop sex if not sexing?
		addAction(action("Stop sex").setScore(scoreStop(ROLE_TOP)).do("stopSex"))

func doAction(_role:String, _id:String, _args:Array):
	if(_id == "stopSex"):
		doText(_role, "{"+_role+".You} decided to stop the riding.")
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
	if(didSubJustCumTimer > 0.0):
		didSubJustCumTimer -= _dt
		if(didSubJustCumTimer < 0.0):
			didSubJustCumTimer = 0.0
	
	if(state == "sex"):
		stimulate(ROLE_TOP, S_PENIS, ROLE_BOTTOM, S_VAGINA if isVaginal else S_ANUS, I_NORMAL, getFetish(), _dt*0.02*SEX_AROUSAL_GAIN[sexSpeed])
		addAutomoan(ROLE_TOP, _dt*1.5, 10.0)
		addAutomoan(ROLE_BOTTOM, _dt*1.5, 14.0)
		exposeFetish(ROLE_TOP, ROLE_BOTTOM, getFetish(), _dt*0.02)
	else:
		exposeFetish(ROLE_TOP, ROLE_BOTTOM, getFetish(), _dt*0.01)
	

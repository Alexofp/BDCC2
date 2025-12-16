extends SexMainActivity

const SEX_SPEED_SLOW = 0
const SEX_SPEED_NORMAL = 1
const SEX_SPEED_FAST = 2

const ROLE_TOP = "top"

const SEX_SPEEDS = [
	SEX_SPEED_SLOW, SEX_SPEED_NORMAL, SEX_SPEED_FAST
]
const SEX_SPEEDS_ANIM = [
	"rubSlow", "rub", "rubFast",
]
const SEX_AROUSAL_GAIN = [
	1.0, 1.5, 3.0,
]
var sexSpeed:int = SEX_SPEED_SLOW

func _init():
	id = SexActivity.SoloRub

func isActivitySupported(_sexEngine:SexEngine) -> bool:
	if(_sexEngine.getParticipants().size() != 1):
		return false
	if(_sexEngine.getSexTypeID() != SexType.Solo): #Check if we have 'animations' for this sex type instead?
		return false
	return true

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_info != _target || !_info.canDoDomActions() || _sexEngine.hasMainActivity()):
		return
	var vagSexScore:float = _info.taskScore(SexTask.CumInsideVaginal, [_target.getID()])
	addAction(action("Pussy masturbation")
	.setScore(vagSexScore)
	.expose(_info, _target, Fetish.SexVaginal)
	#.consent([_target], conTexts("{top.You} {top.youVerb ask} to have vaginal sex with {bottom.you}.", "{top.You} {top.youVerb try|tries} to force vaginal sex with {bottom.you}.", {top=_info,bottom=_target}))
	.start({ROLE_TOP:_info}, {})
	)

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_TOP])
	#isVaginal = _args["vaginal"] if _args.has("vaginal") else false
	#doText(ROLE_TOP, "{top.You} {top.youVerb grab} {bottom.your} wrists and {top.youVerb prepare} to fuck {bottom.yourHis} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+"!")
	doText(ROLE_TOP, "{top.You} {top.youVerb bring} {top.yourHis} hand to {top.yourHis} "+zoneLewdName(ROLE_TOP, ZoneCover.Vagina))
	
func start_run():
	playAnim(AnimScene.SoloSex, "rubTease", {dom={id=ROLE_TOP}}, {})

func start_actions(_role:String):
	if(!canDoDomActions(_role)):
		return
	var penetrateEnabled:bool = true#isReadyToPenetrate(ROLE_TOP) && isZoneReadyToBePenetrated(ROLE_BOTTOM, getPenetrateZone())
	var penetrateScore:float = 1.0#taskScore(ROLE_TOP, getCumInsideTask(), [getRoleID(ROLE_BOTTOM)])
	#var zoneName := zoneLewdName(ROLE_TOP, ZoneCover.Vagina)
	addAction(action("Rub pussy")
	.setEnabled(penetrateEnabled)
	.setScore(penetrateScore)
	#.consent([], conTexts("{top.You} {top.youVerb start} rubbing {bottom.your} "+zoneName+"."))
	.do("startSex")
	)

func start_do(_role:String, _id:String, _args:Array):
	if(_id == "startSex"):
		#sexSpeed = SEX_SPEED_SLOW
		setState("sex")
		doText(ROLE_TOP, "{top.You} {top.youVerb start} rubbing {top.your} "+zoneLewdName(ROLE_TOP, ZoneCover.Vagina)+"!")
		#pushDelay(0.3)
		#pushSetState("sex")
		#doText(ROLE_TOP, "{top.You} {top.youVerb start} fucking {bottom.your} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+"!")

func playCurrentSexAnim():
	playAnim(AnimScene.SoloSex, SEX_SPEEDS_ANIM[sexSpeed], {dom=ROLE_TOP}, {})

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
	
	#if(isReadyToCum(_role)):
		#addAction(action("Cum inside!")
			#.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			#.setScore(0.2 if didSubJustCumTimer <= 0.0 else 1.0)
			#.do("cumInside"))
		#addAction(action("Delay orgasm")
			#.setOverridePriority(OVERRIDE_PRIORITY_ORGASM)
			#.setScore(0.0)
			#.do("delayCum"))

func sex_do(_role:String, _id:String, _args:Array):
	if(_id == "sex_slower"):
		sexSpeed -= 1
		playCurrentSexAnim()
		doText(_role, "{top.You} {top.youVerb start} rubbing {top.your} "+zoneLewdName(ROLE_TOP, ZoneCover.Vagina)+" slower.")
	if(_id == "sex_faster"):
		sexSpeed += 1
		playCurrentSexAnim()
		doText(_role, "{top.You} {top.youVerb start} rubbing {top.your} "+zoneLewdName(ROLE_TOP, ZoneCover.Vagina)+" faster!")
	if(_id == "pause"):
		setState("")
		doText(_role, "{top.You} {top.youVerb pause} the masturbation.")
	#if(_id == "cumInside"):
		#domDoCum()
	#if(_id == "delayCum"):
		#addArousal(_role, -0.5)
		#doText(_role, "{top.You} {top.youVerb delay} {top.yourHis} orgasm.")

#func subDoCum():
	##didSubJustCumTimer = 2.0 # Makes the dom more eager to cum
	#doOrgasm(ROLE_TOP, ROLE_TOP, SexOrgasmType.Vaginal, SexOrgasmCause.Hand, SexOrgasmIntensity.Normal)
	##playOneShot("bottomCum")
	#doText(ROLE_TOP, "{top.You} {top.youVerb cum}!")

func domDoCum():
	sexSpeed = SEX_SPEED_SLOW
	doOrgasm(ROLE_TOP, ROLE_TOP, SexOrgasmType.Vaginal, SexOrgasmCause.Hand, SexOrgasmIntensity.Normal)
	doText(ROLE_TOP, "{top.You} {top.youVerb cum}!")
	setState("rubOrgasm")
	pushDelay(4.0)
	pushSetState("")
	addAutomoan(ROLE_TOP, 25.0, 25.0)
	
	#completeTask(ROLE_TOP, getCumInsideTask(), [getRoleID(ROLE_BOTTOM)])
#
#func canSatisfyTask(_info:SexParticipantInfo, _taskID:String, _args:Array) -> bool:
	#if(_taskID == getCumInsideTask() && _args.size()>0 && _args[0] == getRoleID(ROLE_BOTTOM)):
		#return true
	#return false
#
#func getSubTasks(_info:SexParticipantInfo, _taskID:String, _args:Array) -> Array:
	#if(_taskID in [SexTask.CumInsideVaginal, SexTask.CumInsideAnal]):
		#var result:Array = []
		#var theChar := _info.getChar()
		#var theTarget := GM.characterRegistry.getCharacter(_args[0])
		#
		#if(theChar && theChar.isZoneCovered(ZoneCover.Penis)):
			#result.append(task(SexTask.Undress, [_info.getID()]))
		#if(theTarget && theTarget.isZoneCovered(ZoneCover.Vagina)):
			#result.append(task(SexTask.Undress, [_args[0]]))
		#
		#return result
	#return []
#
func sex_process(_dt:float):
	if(isReadyToCum(ROLE_TOP)):
		domDoCum()
	##if(!isQueueBusy() && isReadyToCum(ROLE_TOP)):
	##	domDoCum()
#
func rubOrgasm_run():
	playAnim(AnimScene.SoloSex, "rubOrgasm", {dom=ROLE_TOP})

#func inside_run():
	#playAnim(AnimScene.TestSex, "inside", {dom=ROLE_TOP, sub=ROLE_BOTTOM}, {hole=(AnimSceneHole.Vagina if isVaginal else AnimSceneHole.Anus)})
	#
#func inside_actions(_role:String):
	#if(!canDoDomActions(_role)):
		#return
	#addAction(action("Fuck more").setScore(1.0-scoreStop(ROLE_TOP)).do("fuckmore"))
	#addAction(action("Pull out").setScore(scoreStop(ROLE_TOP)).do("pullout"))
#
#func inside_do(_role:String, _id:String, _args:Array):
	#if(_id == "pullout"):
		##TODO: special {top.penis} macros
		#doText(_role, "{top.You} {top.youVerb pull} {top.yourHis} cock out.")
		#setState("")
	#if(_id == "fuckmore"):
		#doText(_role, "{top.You} {top.youVerb continue} to fuck {bottom.your} "+zoneLewdName(ROLE_BOTTOM, getPenetrateZone())+"!")
		#setState("sex")

func getActions(_role:String):
	#if(state != "inside"): #Maybe make it so you can only stop sex if not sexing?
	addAction(action("Stop masturbation").setScore(scoreStop(ROLE_TOP)).do("stopSex"))

func doAction(_role:String, _id:String, _args:Array):
	if(_id == "stopSex"):
		doText(_role, "{top.You} decided to stop masturbating.")
		endActivity()

func getExpressionState(_role:String) -> int:
	if(state in ["sex"]):
		return DollExpressionState.SexGiving
	return DollExpressionState.Normal

#func onAnimEvent(_animID:String, _animState:String, _eventID:String, _args:Variant):
	#if(_animID == AnimScene.TestSex):
		#if(_eventID == "plap"):
			#processSex(getPenetrateZone(), ROLE_TOP, ROLE_BOTTOM, 0.5)
			#addAutomoan(ROLE_BOTTOM, 2.0, 25.0)
#
func doProcess(_dt:float):
	#if(didSubJustCumTimer > 0.0):
		#didSubJustCumTimer -= _dt
		#if(didSubJustCumTimer < 0.0):
			#didSubJustCumTimer = 0.0
		#
	if(state == "sex"):
		stimulate(ROLE_TOP, S_HANDS, ROLE_TOP, S_VAGINA, I_NORMAL, Fetish.SexVaginal, _dt*0.02*SEX_AROUSAL_GAIN[sexSpeed])
		#processSex(getPenetrateZone(), ROLE_TOP, ROLE_BOTTOM, 0.5)
		addAutomoan(ROLE_TOP, _dt*1.5, 10.0)
		#exposeFetish(ROLE_TOP, ROLE_BOTTOM, Fetish.SexVaginal if isVaginal else Fetish.SexAnal, _dt*0.02)
	#else:
		#exposeFetish(ROLE_TOP, ROLE_BOTTOM, Fetish.SexVaginal if isVaginal else Fetish.SexAnal, _dt*0.01)
	#

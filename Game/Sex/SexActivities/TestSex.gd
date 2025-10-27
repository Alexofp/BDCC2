extends SexMainActivity

const SEX_SPEED_SLOW = 0
const SEX_SPEED_NORMAL = 1
const SEX_SPEED_FAST = 2

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
	setupRoles(_roles, ["dom", "sub"])
	
func start_run():
	playAnim(AnimScene.TestSex, "tease", {dom={id="dom"}, sub="sub"})

func start_actions(_role:String):
	addActionEasy("Penetrate", 1.0, "startSex")

func start_do(_role:String, _id:String, _args:Array):
	if(_id == "startSex"):
		sexSpeed = SEX_SPEED_SLOW
		pushDelay(0.3)
		pushSetState("sex")

func playCurrentSexAnim():
	playAnim(AnimScene.TestSex, SEX_SPEEDS_ANIM[sexSpeed], {dom={id="dom", guidePenisVag="sub"}, sub="sub"})

func sex_run():
	playCurrentSexAnim()

func sex_actions(_role:String):
	if(sexSpeed < SEX_SPEED_FAST):
		addActionEasy("Faster", 1.0, "sex_faster")
	if(sexSpeed > SEX_SPEED_SLOW):
		addActionEasy("Slower", 1.0, "sex_slower")
	addActionEasy("Pause", 0.0, "pause")

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
	doOrgasm("sub", "dom", SexOrgasmType.Vaginal, SexOrgasmCause.Penis, SexOrgasmIntensity.Normal)
	playOneShot("bottomCum")

func domDoCum():
	sexSpeed = SEX_SPEED_SLOW
	doOrgasm("dom", "sub", SexOrgasmType.Penile, SexOrgasmCause.Vagina, SexOrgasmIntensity.Normal)
	setState("cuminside")
	pushDelay(5.0)
	pushSetState("inside")

func sex_process(_dt:float):
	if(isReadyToCum("sub")):
		subDoCum()
	if(!isQueueBusy() && isReadyToCum("dom")):
		domDoCum()

func cuminside_run():
	playAnim(AnimScene.TestSex, "cum", {dom={id="dom", guidePenisVag="sub"}, sub="sub"})

func inside_run():
	playAnim(AnimScene.TestSex, "inside", {dom={id="dom", guidePenisVag="sub"}, sub="sub"})
	
func inside_actions(_role:String):
	addActionEasy("Fuck more", 1.0, "fuckmore")
	addActionEasy("Pull out", 1.0, "pullout")

func inside_do(_role:String, _id:String, _args:Array):
	if(_id == "pullout"):
		setState("")
	if(_id == "fuckmore"):
		setState("sex")

func getActions(_role:String):
	addActionEasy("Stop sex", 0.0, "stopSex")

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
		if(_role == "dom"):
			return DollExpressionState.SexGiving
		return DollExpressionState.SexReceiving
	return DollExpressionState.Normal

func onAnimEvent(_animID:String, _animState:String, _eventID:String, _args:Variant):
	if(_animID == AnimScene.TestSex):
		if(_eventID == "plap"):
			var _dt:float = 1.0
			
			#if(state == "slow"):
			processVaginalSex("dom", "sub", 0.5)
			addAutomoan("sub", _dt*2.0, 25.0)
			#if(state == "sex"):
				#processVaginalSex("dom", "sub", 1.0)
				#addAutomoan("sub", _dt*2.0, 25.0)
			#if(state == "fast" || state == "inside"):
				#processVaginalSex("dom", "sub", 1.5)
				#addAutomoan("sub", _dt*2.0, 25.0)

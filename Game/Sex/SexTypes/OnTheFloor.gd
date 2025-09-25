extends SexTypeBase

const ROLE_DOM = "dom"
const ROLE_SUB = "sub"

func _init() -> void:
	id = SexType.OnTheFloor

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_DOM, ROLE_SUB])
	
func onStart():
	pass

func start_run():
	playAnim(AnimScene.SexStart, "start", {dom="dom", sub="sub"})

func start_actions(_role:String):
	if(!getSexEngine().sexActivity):
		addAction("Standing sex", 1.0, "startSex")
		addAction("Stop", 1.0, "stopSex")

func start_do(_role:String, _action:SexAction):
	if(_action.id == "startSex"):
		Log.Print("STARTING SEX")
		pushActionText("SEX IS STARTING")
		#pushDelay(0.5)
		
		pushDelayCanCancel(0.5, _role)
		pushAutoAction(_role, "startSex_actually")
		pushCancelCatcher("startSex_cancel")
		
		#pushCancelStopper()
#		pushEventCanCancel(0.5, _role, "eventID", [], "eventIDCancel")
#		pushEventSmart(smartEvent(0.5, "eventID", []).canCancel(true).canceledBy([_role]).orElse("eventID2").requiresConsent(true))
		
		#pushActionText("ALMOST THERE!")
		#pushDelay(0.5)
		#pushEvent(SexEvent.make("startSex"))
		#pushAutoAction(_role, "startSex_actually")
	if(_action.id == "startSex_actually"):
		addActionText("SEX HAS STARTED")
		startMainActivity(SexActivity.TestSex, {dom=getRoleID("dom"), sub=getRoleID("sub")})
	if(_action.id == "stopSex"):
		pushDelay(0.5)
		pushAutoAction(_role, "stopSex_actually")
	if(_action.id == "stopSex_actually"):
		getSexEngine().stopSex()
	if(_action.id == "startSex_cancel"):
		addActionText("ACTION CANCELED!")

func start_event(_eventID:String, _args:Array):
	if(_eventID == "startSex"):
		startMainActivity(SexActivity.TestSex, {dom=getRoleID("dom"), sub=getRoleID("sub")})

func isDom(_role:String) -> bool:
	if(_role == ROLE_DOM):
		return true
	return false

func isSub(_role:String) -> bool:
	if(_role == ROLE_SUB):
		return true
	return false

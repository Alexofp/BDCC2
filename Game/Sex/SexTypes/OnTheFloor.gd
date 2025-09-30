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
	if(!hasMainActivity()):
		if(canDoDomActions(_role)):
			addAction(action("Standing sex").consent(5.0).do("startSex_pre").delayCancel(0.5).do("startSex"))
			addAction(action("Stop").delayCancel(0.5).do("stopSex"))

func start_do(_role:String, _id:String, _args:Array):
	if(_id == "startSex_pre"):
		Log.Print("STARTING SEX")
		addActionText("SEX IS STARTING")
		#pushDelay(0.5)
		
		#pushDelayCanCancel(0.5, _role)
		#pushAutoAction(_role, "startSex_actually")
		#pushCancelCatcher("startSex_cancel")
		
		#pushCancelStopper()
#		pushEventCanCancel(0.5, _role, "eventID", [], "eventIDCancel")
#		pushEventSmart(smartEvent(0.5, "eventID", []).canCancel(true).canceledBy([_role]).orElse("eventID2").requiresConsent(true))
		
		#pushActionText("ALMOST THERE!")
		#pushDelay(0.5)
		#pushEvent(SexEvent.make("startSex"))
		#pushAutoAction(_role, "startSex_actually")
	if(_id == "startSex"):
		addActionText("SEX HAS STARTED")
		startMainActivity(SexActivity.TestSex, {dom=getRoleID("dom"), sub=getRoleID("sub")})
	if(_id == "stopSex"):
		getSexEngine().stopSex()

func start_event(_eventID:String, _args:Array):
	if(_eventID == "startSex"):
		startMainActivity(SexActivity.TestSex, {dom=getRoleID("dom"), sub=getRoleID("sub")})

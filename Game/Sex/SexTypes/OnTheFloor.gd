extends SexTypeBase

const ROLE_DOM = "dom"
const ROLE_SUB = "sub"

func _init() -> void:
	id = SexType.OnTheFloor

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_DOM, ROLE_SUB])
	
func onStart():
	playAnim(AnimScene.SexStart, "start", {dom="dom", sub="sub"})

func onMainActivityEnded(_activityID:String):
	playAnim(AnimScene.SexStart, "start", {dom="dom", sub="sub"})
	pass

func getActions(_role:String) -> Array:
	var actions:Array = []
	if(!getSexEngine().sexActivity):
		actions.append(action("startSex", "Standing sex", {
			SexActionMod.CONSENT_TEXT: "SEX IS OFFERED",
			SexActionMod.ACTION_TEXT: "SEX IS STARTING",
			SexActionMod.CONSENT_ALL: true,
			SexActionMod.DELAY: 0.5,
			SexActionMod.ROLES: [ROLE_DOM],
		}))
		actions.append(action("stopSex", "Stop", {
			SexActionMod.DELAY: 1.0,
			SexActionMod.ROLES: [ROLE_DOM],
			SexActionMod.CONSENT_ALL: true,
		}))
	
	return actions

#func doAction(_role:String, actionID:String, _theAction:Dictionary):
	#if(actionID == "startSex"):
		#doDelayedAction(0.5, _role, "startSex", {})
	#if(actionID == "stopSex"):
		#getSexEngine().stopSex()
		
func doAction(_role:String, _actionID:String, _action:Dictionary): #onDelayedAction
	if(_actionID == "startSex"):
		Log.Print("STARTING SEX")
		startMainActivity(SexActivity.TestSex, {dom=getRoleID("dom"), sub=getRoleID("sub")})
	if(_actionID == "stopSex"):
		getSexEngine().stopSex()

func isDom(_role:String) -> bool:
	if(_role == ROLE_DOM):
		return true
	return false

func isSub(_role:String) -> bool:
	if(_role == ROLE_SUB):
		return true
	return false

func getAnimScenePath() -> String:
	return "res://AnimScenes/Scenes/TestSexAnim/test_sex_scene.tscn"

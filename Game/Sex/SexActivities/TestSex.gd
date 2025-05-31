extends SexActivityBase

var someTimer:float = 0.0

var state:String = ""

func _init():
	id = SexActivity.TestSex

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, ["dom", "sub"])
	
func onStart():
	playAnim(AnimScene.TestSex, "tease", {dom={id="dom"}, sub="sub"})

func doProcess(_dt:float):
	someTimer += _dt
	#if(someTimer >= 10.0):
	#	endActivity()

func getAnimScenePath() -> String:
	return "res://AnimScenes/Scenes/TestSexAnim/test_sex_scene.tscn"

func getActions(_role:String) -> Array:
	var actions:Array = []
	
	actions.append(action("bottomCum", "CUM!",{
	}))
	actions.append(action("topCum", "CUM TOP!",{
	}))
	
	if(state == ""):
		actions.append(action("startSex", "Penetrate",{
			SexActionMod.DELAY: 0.5,
		}))
	if(state == "inside"):
		actions.append(action("startSex", "Fuck more",{
			SexActionMod.DELAY: 0.5,
		}))
		actions.append(action("teaseSex", "Pull out",{
			SexActionMod.DELAY: 0.5,
		}))
	if(state == "sex" || state == "slow"):
		actions.append(action("fastSex", "Faster",{
			SexActionMod.DELAY: 0.5,
		}))
		actions.append(action("teaseSex", "Slower",{
			SexActionMod.DELAY: 0.5,
		}))
	if(state == "fast"):
		actions.append(action("startSex", "Slower",{
			SexActionMod.DELAY: 0.5,
		}))
	
	actions.append(action("stopSex", "Stop sex",{
			SexActionMod.DELAY: 0.5,
		}))
	
	return actions

func onDelayedActionStarted(_role:String, _actionID:String, _action:Dictionary):
	#addActionText(str(_action))
	pass
	
		
func doAction(_role:String, _actionID:String, _action:Dictionary): #onDelayedAction
	if(_actionID == "bottomCum"):
		doOrgasm("sub", "dom", SexOrgasmType.Vaginal, SexOrgasmCause.Penis, SexOrgasmIntensity.Normal)
		playOneShot("bottomCum")
	if(_actionID == "topCum"):
		doOrgasm("dom", "sub", SexOrgasmType.Penile, SexOrgasmCause.Vagina, SexOrgasmIntensity.Normal)
		state = "inside"
		playAnim(AnimScene.TestSex, "cum", {dom={id="dom", guidePenisVag="sub"}, sub="sub"})
	if(_actionID == "stopSex"):
		addActionText("They decide to stop fucking!")
		#Log.Print("Stopping sex")
		endActivity()
	if(_actionID == "startSex"):
		if(state == ""):
			addActionText("They slam their cock inside!")
		state = "slow"
		playAnim(AnimScene.TestSex, "slow", {dom={id="dom", guidePenisVag="sub"}, sub="sub"})
	if(_actionID == "fastSex"):
		addActionText("They fuck them faster!")
		if(state == "sex"):
			state = "fast"
			playAnim(AnimScene.TestSex, "fast", {dom={id="dom", guidePenisVag="sub"}, sub="sub"})
		else:
			state = "sex"
			playAnim(AnimScene.TestSex, "sex", {dom={id="dom", guidePenisVag="sub"}, sub="sub"})
	if(_actionID == "teaseSex"):
		if(state == "slow" || state == "inside"):
			state = ""
			playAnim(AnimScene.TestSex, "tease", {dom={id="dom"}, sub="sub"})
		else:
			state = "sex"
			playAnim(AnimScene.TestSex, "sex", {dom={id="dom"}, sub="sub"})
	
func getExpressionState(_role:String) -> int:
	if(state in ["sex", "fast"]):
		if(_role == "dom"):
			return DollExpressionState.SexGiving
		return DollExpressionState.SexReceiving
	return DollExpressionState.Normal

func processSex(_dt:float):
	#if(state == "slow"):
		#processVaginalSex(_dt, "dom", "sub", 0.5)
		#addAutomoan("sub", _dt*2.0, 25.0)
	#if(state == "sex"):
		#processVaginalSex(_dt, "dom", "sub", 1.0)
		#addAutomoan("sub", _dt*2.0, 25.0)
	#if(state == "fast"):
		#processVaginalSex(_dt, "dom", "sub", 1.5)
		#addAutomoan("sub", _dt*2.0, 25.0)
	#
	if(getRoleChar("sub").getArousal() >= 1.0):
		doAction("sub", "bottomCum", {})
	
	if(getRoleChar("dom").getArousal() >= 1.0):
		doAction("dom", "topCum", {})

func onAnimEvent(_animID:String, _animState:String, _eventID:String, _args:Variant):
	if(_animID == AnimScene.TestSex):
		if(_eventID == "plap"):
			var _dt:float = 1.0
			
			#if(state == "slow"):
			processVaginalSex(_dt, "dom", "sub", 0.5)
			addAutomoan("sub", _dt*2.0, 25.0)
			#if(state == "sex"):
				#processVaginalSex(_dt, "dom", "sub", 1.0)
				#addAutomoan("sub", _dt*2.0, 25.0)
			#if(state == "fast" || state == "inside"):
				#processVaginalSex(_dt, "dom", "sub", 1.5)
				#addAutomoan("sub", _dt*2.0, 25.0)

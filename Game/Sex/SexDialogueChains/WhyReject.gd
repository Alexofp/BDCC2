extends SexDialogueChain

func _init() -> void:
	id = "WhyReject"
	importantChain = true

func _lines():
	addLine(ROLE_MAIN, ROLE_TARGET, "SexRejectWhy", "whyReject", SCORE_KIND)
	addLine(ROLE_MAIN, ROLE_TARGET, "SexRejectStartForce", "startForce", SCORE_ANGRY).addAnger(ROLE_MAIN, 1.0).addResistance(ROLE_TARGET, 0.5)

func _onLine(_line:SexDialogueLine):
	if(_line.actionID == "whyReject"):
		setState("whyReject")
	elif(_line.actionID == "startForce"):
		addFear(ROLE_TARGET, 0.1)
		_line.chain.handler.sex.setSexMode(SexEngine.MODE_FORCED)
		stopMe()

func whyReject_lines():
	addLine(ROLE_TARGET, ROLE_MAIN, "SexRejectNoWant", "noWant")
	addLine(ROLE_TARGET, ROLE_MAIN, "SexRejectMistake", "mistake", SCORE_CONSTANT, 0.0)
	addLine(ROLE_TARGET, ROLE_MAIN, "SexRejectMakeMe", "makeMe", SCORE_CONSTANT, 0.1) # score_brat?

func whyReject_onLine(_line:SexDialogueLine):
	if(_line.actionID == "makeMe"):
		setState("makeMe")
	if(_line.actionID == "mistake"):
		stopMe()
	if(_line.actionID == "noWant"):
		setState("noWant")

func makeMe_lines():
	addLine(ROLE_MAIN, ROLE_TARGET, "SexRejectMakeMeOkay", "okay").addAnger(ROLE_MAIN, 1.0).addResistance(ROLE_TARGET, 0.5)
	
func makeMe_onLine(_line:SexDialogueLine):
	if(_line.actionID == "okay"):
		_line.chain.handler.sex.setSexMode(SexEngine.MODE_FORCED)
		stopMe()

func noWant_lines():
	addLine(ROLE_MAIN, ROLE_TARGET, "SexRejectNoWantAccept", "okay", SCORE_KIND)
	addLine(ROLE_MAIN, ROLE_TARGET, "SexRejectNoWantDeny", "angry", SCORE_ANGRY).addAnger(ROLE_MAIN, 0.6).addResistance(ROLE_TARGET, 0.5)

func noWant_onLine(_line:SexDialogueLine):
	if(_line.actionID == "okay"):
		getRole(ROLE_MAIN).ai.cancelCurrentGoal()
		stopMe()
	if(_line.actionID == "angry"):
		stopMe()

func onIgnore():
	if(getState() == "whyReject"):
		if(RNG.chance(30)):
			getRole(ROLE_MAIN).ai.cancelCurrentGoal()
		addAnger(ROLE_MAIN, 0.6)
	stopMe()

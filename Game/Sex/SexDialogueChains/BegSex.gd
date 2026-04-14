extends SexDialogueChain

func _init() -> void:
	id = "BegSex"
	#importantChain = true

func _lines():
	addXLines(2, ROLE_MAIN, ROLE_TARGET, "SexBegSexMore", "breedMe", SCORE_NOT_RESISTING)
	addXLines(2, ROLE_MAIN, ROLE_TARGET, "SexBegSexStop", "pleaseStop", SCORE_RESISTING)

func breedMe_lines():
	addXLines(3, ROLE_TARGET, ROLE_MAIN, "SexBegSexMoreReact", "breedReact")
	addIgnoreActionAI(ROLE_TARGET, ROLE_MAIN, SCORE_CONSTANT, 0.5)

func breedMe_onLine(_line:SexDialogueLine):
	stopMe()

func pleaseStop_lines():
	addXLines(3, ROLE_TARGET, ROLE_MAIN, "SexBegSexStopReactDeny", "stopReactDeny")
	addXLines(3, ROLE_TARGET, ROLE_MAIN, "SexBegSexStopReactAgree", "stopReactAgree", SCORE_KIND, 0.1 if isForced() else 1.0)

func pleaseStop_onLine(_line:SexDialogueLine):
	if(_line.actionID == "stopReactDeny"):
		stopMe()
	if(_line.actionID == "stopReactAgree"):
		getRole(ROLE_TARGET).ai.cancelCurrentGoal() # Probably should ban it too and regenerate all others that are of this type?
		stopMe()
	

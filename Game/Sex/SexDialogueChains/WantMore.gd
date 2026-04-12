extends SexDialogueChain

func _init() -> void:
	id = "WantMore"
	importantChain = true

func _lines():
	addLine(ROLE_MAIN, ROLE_TARGET, "SexWantMore", "wantMore")

func wantMore_lines():
	addLine(ROLE_TARGET, ROLE_MAIN, "SexWantMoreYes", "yes")
	addLine(ROLE_TARGET, ROLE_MAIN, "SexWantMoreEnough", "enough")
	# up to you (random)

func wantMore_onLine(_line:SexDialogueLine):
	if(_line.actionID == "yes"):
		# Add an extra goal to the main npc
		getRole(ROLE_MAIN).ai.generateGoals(1)
		stopMe()
	if(_line.actionID == "enough"):
		# Allow the sex to end?
		handler.wantStop = true
		stopMe()
	

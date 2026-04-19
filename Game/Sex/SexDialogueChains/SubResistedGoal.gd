extends SexDialogueChain

func _init() -> void:
	id = "SubResistedGoal"
	importantChain = true

func _lines():
	#addXLines(3, ROLE_MAIN, ROLE_TARGET, "SexTease", "tease")
	addLine(ROLE_MAIN, ROLE_TARGET, "SexSubResistedGoal", "angry")

func _onLine(_line:SexDialogueLine):
	stopMe()

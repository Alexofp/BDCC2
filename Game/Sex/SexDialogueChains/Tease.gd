extends SexDialogueChain

func _init() -> void:
	id = "Tease"
	#importantChain = true

func _lines():
	addXLines(3, ROLE_MAIN, ROLE_TARGET, "SexTease", "tease")

func _onLine(_line:SexDialogueLine):
	stopMe()

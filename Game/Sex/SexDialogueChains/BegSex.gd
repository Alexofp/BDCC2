extends SexDialogueChain

func _init() -> void:
	id = "BegSex"
	#importantChain = true

func _lines():
	addXLines(2, ROLE_MAIN, ROLE_TARGET, "SexBegSexBreed", "breedMe", SCORE_KIND)
	addXLines(2, ROLE_MAIN, ROLE_TARGET, "SexBegSexStop", "pleaseStop", SCORE_ANGRY)

func breedMe_lines():
	addXLines(3, ROLE_TARGET, ROLE_MAIN, "SexBegSexBreedReact", "breedReact")

func breedMe_onLine(_line:SexDialogueLine):
	stopMe()

func pleaseStop_lines():
	addXLines(3, ROLE_TARGET, ROLE_MAIN, "SexBegSexStopReact", "stopReact")

func pleaseStop_onLine(_line:SexDialogueLine):
	stopMe()
	

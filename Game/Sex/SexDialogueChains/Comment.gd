extends SexDialogueChain
class_name SexComment

const SubResisted := "SubResisted"
const CameInsideVagina := "CameInsideVagina"
const CameInsideAnus := "CameInsideAnus"
const DeniedByDom := "DeniedByDom"

func _init() -> void:
	id = "Comment"
	#importantChain = true

func onEnd():
	var theMain := getRole(ROLE_MAIN)
	if(theMain):
		theMain.ai.clearCommentTopics()
		
var processed:Dictionary[String, bool] = {}
var allComments:Dictionary[String, float]
func _lines():
	allComments = getRole(ROLE_MAIN).ai.getCommentTopics(getRole(ROLE_TARGET).getID())
	
	checkMultiAnswerComment(CameInsideVagina, ["good", "bad"], [SCORE_KIND, SCORE_ANGRY], [3.0, 3.0])
	checkMultiAnswerComment(CameInsideAnus, ["good", "bad"], [SCORE_KIND, SCORE_ANGRY], [3.0, 3.0])
	
	for theCommentID in allComments:
		if(processed.has(theCommentID)):
			continue
		addXLines(3, ROLE_MAIN, ROLE_TARGET, "SexComment"+theCommentID, theCommentID)
	
	addIgnoreActionAI(ROLE_MAIN, ROLE_TARGET)
	
func _onLine(_line:SexDialogueLine):
	stopMe()

func checkMultiAnswerComment(_line:String, _answers:Array[String], _scoringStrategies:Array[int] = [], _scoreMults:Array[float] = []) -> bool:
	if(allComments.has(_line)):
		processed[_line] = true
		var ansAm:int = _answers.size()
		for _i in ansAm:
			addXLines(2, ROLE_MAIN, ROLE_TARGET, "SexComment"+_line+"_"+_answers[_i], _line+"_"+_answers[_i], _scoringStrategies[_i] if _i < _scoringStrategies.size() else SCORE_CONSTANT, _scoreMults[_i] if _i < _scoreMults.size() else 1.0)
		
		return true
	return false

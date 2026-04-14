extends RefCounted
class_name SexDialogueLine

var actionID:String
var line:String
var finalLines:Array[String]
var chain:SexDialogueChain
var main:SexParticipantInfo
var target:SexParticipantInfo
var lineGenerated:bool = false
var score:float = 1.0
var onlyAI:bool = false

func calculateArgs() -> Dictionary[String, Variant]:
	var theSex:SexEngine = chain.handler.getSex()
	
	var theArgs:Dictionary[String, Variant] = {}
	theArgs["amountStarted"] = chain.handler.getAmountStarted(chain.id)
	theArgs["mainActivity"] = theSex.sexActivity.id if theSex.sexActivity else ""
	theArgs["sexType"] = theSex.getSexTypeID()
	return theArgs

func calculateFinalLine() -> bool:
	var theResult := GM.main.reactionSystem.reactPawnGenerate(main.getPawn(), line, target.getPawn(), calculateArgs())
	if(!theResult):
		finalLines = ["NOT_FOUND:"+str(line)]
		return true
	#finalText = theResult.line
	finalLines = [theResult.line]
	lineGenerated = true
	return true

func calculateXFinalLines(_amount:int) -> bool:
	var theContext := GM.main.reactionSystem.prepareContext(main.getPawn(), target.getPawn(), calculateArgs())
	
	var theResult := GM.main.reactionSystem.generateXReactions(line, theContext, _amount)
	if(theResult.is_empty()):
		finalLines = ["NOT_FOUND:"+str(line)]
		return true
	finalLines.clear()
	for theLine in theResult:
		finalLines.append(theLine.line)
	lineGenerated = true
	return true

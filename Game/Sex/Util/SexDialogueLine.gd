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
var effects:Array = []

const EFFECT_AFFECT_SATISFACTION := 0
const EFFECT_STOP_CHAIN := 1
const EFFECT_ANGER := 2
const EFFECT_RESISTANCE := 3
const EFFECT_LUST := 4
const EFFECT_LUST_ALL := 5

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

func affectSatisfaction(_role:int, _amount:float) -> SexDialogueLine:
	effects.append([EFFECT_AFFECT_SATISFACTION, _role, _amount])
	return self

func addAnger(_role:int, _amount:float) -> SexDialogueLine:
	effects.append([EFFECT_ANGER, _role, _amount])
	return self

func addResistance(_role:int, _amount:float) -> SexDialogueLine:
	effects.append([EFFECT_RESISTANCE, _role, _amount])
	return self

func addLust(_role:int, _amount:float) -> SexDialogueLine:
	effects.append([EFFECT_LUST, _role, _amount])
	return self

func addLustAll(_amount:float) -> SexDialogueLine:
	effects.append([EFFECT_LUST_ALL, _amount])
	return self

func stopChain(_role:int, _amount:float) -> SexDialogueLine:
	effects.append([EFFECT_STOP_CHAIN])
	return self

func doEffects():
	for theEffectEntry in effects:
		var theEffectType:int = theEffectEntry[0]
		
		if(theEffectType == EFFECT_AFFECT_SATISFACTION):
			var theInfo := chain.getRole(theEffectEntry[1])
			if(!theInfo):
				continue
			theInfo.ai.affectSatisfaction(theEffectEntry[2])
		elif(theEffectType == EFFECT_ANGER):
			var theInfo := chain.getRole(theEffectEntry[1])
			if(!theInfo):
				continue
			theInfo.ai.addAnger(theEffectEntry[2])
			if(!theInfo.canDoDomActions()):
				theInfo.ai.addResistance(theEffectEntry[2])
		elif(theEffectType == EFFECT_RESISTANCE):
			var theInfo := chain.getRole(theEffectEntry[1])
			if(!theInfo):
				continue
			theInfo.ai.addResistance(theEffectEntry[2])
			if(theInfo.canDoDomActions()):
				theInfo.ai.addAnger(theEffectEntry[2])
		elif(theEffectType == EFFECT_LUST):
			var theInfo := chain.getRole(theEffectEntry[1])
			if(!theInfo):
				continue
			theInfo.ai.addLust(theEffectEntry[2])
		elif(theEffectType == EFFECT_LUST_ALL):
			for theInfo in chain.participantToRole:
				theInfo.ai.addLust(theEffectEntry[1])
		elif(theEffectType == EFFECT_STOP_CHAIN):
			chain.stopMe()

extends RefCounted
class_name SexDialogueHandler

var sex:SexEngine
var chains:Array[SexDialogueChain] = []
var amountStarted:Dictionary[String, int] = {} # chain id = amount started

var noAnswerTimer:float = 0.0
var wantStop:bool = false

func setSex(_sex:SexEngine):
	sex = _sex

func tryAddChain(_chainID:String, _main:SexParticipantInfo, _target:SexParticipantInfo, _args:Array = []) -> SexDialogueChain:
	if(haveChainID(_chainID)): # Should probably check if this chain has our main/target
		return null
	
	var theChain := GlobalRegistry.createSexDialogueChain(_chainID)
	if(!theChain):
		return null
	
	theChain.setupChain(self, _main, _target)
	chains.append(theChain)
	theChain.start(_args)
	
	if(!amountStarted.has(_chainID)):
		amountStarted[_chainID] = 1
	else:
		amountStarted[_chainID] += 1
	
	if(theChain.wasDeleted):
		return null
	return theChain

func clearChains():
	chains.clear()

func removeChain(_chain:SexDialogueChain):
	if(_chain.wasDeleted):
		return
	chains.erase(_chain)
	_chain.wasDeleted = true
	#_chain.handler = null

func process(_dt:float):
	var chainAm:int = chains.size()
	for _i in chainAm:
		var _indx:int = chainAm - _i - 1
		var theChain := chains[_indx]
		if(noAnswerTimer <= 0.0):
			theChain.timeOutTime += _dt
		theChain.checkShouldBeStopped()
	
	if(noAnswerTimer > 0.0):
		noAnswerTimer -= _dt

func ignoreAllChainsThatNeedsAnsweringBy(_participant:SexParticipantInfo):
	var chainAm:int = chains.size()
	for _i in chainAm:
		var _indx:int = chainAm - _i - 1
		var theChain := chains[_indx]
		
		for theLine in theChain.currentLines:
			if(theLine.main == _participant):
				theChain.onIgnoreAll()
				break

func doAnswer(_line:SexDialogueLine, _lineIndx:int = -1):
	var theChain := _line.chain
	if(theChain.wasDeleted):
		return
		
	var thePawn := _line.main.getPawn()
	if(thePawn):
		thePawn.sayAdvanced(CharacterPawn.parseSayTextToArray(_line.finalLines[_lineIndx] if _lineIndx >= 0 else RNG.pick(_line.finalLines)))
	var theTarget := _line.target.getPawn()
	if(theTarget):
		theTarget.clearSay()
	
	theChain.doLine(_line)
	noAnswerTimer = 2.0


func canDoDialogue() -> bool:
	return noAnswerTimer <= 0.0

func getActionsFor(_participant:SexParticipantInfo) -> Array[InteractEntryDo]:
	if(noAnswerTimer > 0.0):
		return []
	var result:Array[InteractEntryDo] = []
	
	var haveSomethingToSay:bool = false
	for theChain in chains:
		for theLine in theChain.currentLines:
			if(theLine.main != _participant):
				continue
			
			var _i:int = 0
			for theTextLine in theLine.finalLines:
				result.append(InteractEntryDo.create("SexDialogueAction", [
					theTextLine, "say", theLine, _i,
				]))#.setDisabled(theAction.disabled).setSubCategory(theAction.category))
				_i += 1
				haveSomethingToSay = true

	if(haveSomethingToSay):
		result.append(InteractEntryDo.create("SexDialogueAction", [
				"Ignore", "ignore", self, 0,
		]))
		
	return result

# If we have important dialogue chains, we shouldn't do anything new
func haveImportantChains() -> bool:
	for theChain in chains:
		if(theChain.importantChain):
			return true
	return false

func haveChainID(_chainID:String) -> bool:
	for theChain in chains:
		if(theChain.id == _chainID):
			return true
	return false

func getAmountStarted(_chainID:String) -> int:
	if(!amountStarted.has(_chainID)):
		return 0
	return amountStarted[_chainID]

## AI will skip asking the subs. Allows the Dom AI to stop sex
func markCanStopSex():
	wantStop = true

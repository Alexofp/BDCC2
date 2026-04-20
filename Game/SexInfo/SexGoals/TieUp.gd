extends SexGoalBase

var howMuch:int = 2

func _init() -> void:
	id = SexGoal.TieUp
	
	fetishesPerformer = [Fetish.Bondage]
	fetishesReceiver = []

func isPossibleAtAll(_info:SexParticipantInfo, _sexEngine:SexEngine, _stillPossible:bool) -> bool:
	return true

func isPossible(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine, _stillPossible:bool) -> bool:
	var howManyCanEquip:int = calcHowManyCanEquip(_info, _target)
	
	if(!_stillPossible && howManyCanEquip >= 2):
		return true
	if(_stillPossible && howManyCanEquip >= howMuch):
		return true
	return false

func setupSexGoal(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine, _args:Array) -> bool:
	info = _info
	target = _target
	howMuch = calcHowManyCanEquip(_info, _target)
	if(howMuch > 2):
		howMuch = 2
	if(howMuch <= 0):
		return false
	return true

func calcHowManyCanEquip(_info:SexParticipantInfo, _target:SexParticipantInfo) -> int:
	var howManyCanEquip:int = 0
	var theChar := _info.getChar()
	var theInv := theChar.getInventory()
	var theTargetChar := _target.getChar()
	var theTargetInv := theTargetChar.getInventory()
	for theItem in theInv.getItems():
		if(!theItem.isEquipable() || !theItem.isBondageGear()):
			continue
		if(!theItem.canBeEquippedOnto(theTargetInv)):
			continue
		howManyCanEquip += 1
	return howManyCanEquip

func getSexTasks() -> Array[SexTask]:
	return [
		sexTask(SexTask.TieUp),
	]

func onOneOfSexTasksCompleted(_sexTask:SexTask):
	howMuch -= 1
	if(howMuch <= 0):
		completeSelf()

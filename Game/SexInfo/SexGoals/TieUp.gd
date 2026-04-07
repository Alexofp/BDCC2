extends SexGoalBase

var howMuch:int = 2

func _init() -> void:
	id = SexGoal.TieUp
	
	fetishesPerformer = [Fetish.Bondage]
	fetishesReceiver = []

func isPossibleAtAll(_info:SexParticipantInfo, _sexEngine:SexEngine) -> bool:
	return true

func isPossible(_info:SexParticipantInfo, _target:SexParticipantInfo, _sex:SexEngine) -> bool:
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
	
	if(howManyCanEquip >= 2):
		return true
	return false

func getSexTasks() -> Array[SexTask]:
	return [
		sexTask(SexTask.TieUp),
	]

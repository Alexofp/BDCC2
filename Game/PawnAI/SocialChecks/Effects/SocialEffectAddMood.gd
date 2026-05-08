extends SocialCheckBase
class_name SocialEffectAddMood

var mood:Array[int]
var moodAmount:Array[float]
var moodStatus:Array[int]
var moodToTarget:Array[bool]

func _init() -> void:
	pass

func addSuccess(_mood:int, _amount:float = 1.0) -> SocialEffectAddMood:
	return add(SocialInteractionHandler.STATUS_AGREE, _mood, _amount, true)
	
func addDeny(_mood:int, _amount:float = 1.0) -> SocialEffectAddMood:
	return add(SocialInteractionHandler.STATUS_DENY, _mood, _amount, true)
	
func addSuccessStarter(_mood:int, _amount:float = 1.0, _toTarget:bool = true) -> SocialEffectAddMood:
	return add(SocialInteractionHandler.STATUS_AGREE, _mood, _amount, false)
	
func addDenyStarter(_mood:int, _amount:float = 1.0) -> SocialEffectAddMood:
	return add(SocialInteractionHandler.STATUS_DENY, _mood, _amount, false)
	
func add(_status:int, _mood:int, _amount:float = 1.0, _toTarget:bool = true) -> SocialEffectAddMood:
	mood.append(_mood)
	moodAmount.append(_amount)
	moodStatus.append(_status)
	moodToTarget.append(_toTarget)
	return self

func onEnd(_status:int):
	var theTarget := socialHandler.getTargetPawn()
	var theStarter := socialHandler.getStarterPawn()
	
	var moodAm:int = mood.size()
	for _i in moodAm:
		if(_status != moodStatus[_i]):
			continue
		var thePawn:CharacterPawn = theTarget if moodToTarget[_i] else theStarter
		thePawn.mood.addStat(mood[_i], moodAmount[_i]*socialHandler.success)

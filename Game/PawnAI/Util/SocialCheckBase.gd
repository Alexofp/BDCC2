extends RefCounted
class_name SocialCheckBase

var socialHandler:SocialInteractionHandler

func getAgreeScore(_score:float) -> float:
	return _score

func getAgreeStatus() -> int:
	return SocialInteractionHandler.STATUS_UNCHANGED

func onStart():
	pass

func onEnd(_status:int):
	pass

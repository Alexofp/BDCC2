extends RefCounted
class_name SocialCheckBase

var socialHandler:SocialInteractionHandler

func shouldAgree() -> bool:
	return true

func onStart():
	pass

func onEnd(_isDeny:bool):
	pass

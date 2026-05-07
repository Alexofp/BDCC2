extends SocialEffectBase
class_name SocialEffectAddAffection

var amount:float = 0.0

func _init(_amount:float) -> void:
	amount = _amount

func doEffect(_isDeny:bool):
	socialHandler.addAffection(amount)

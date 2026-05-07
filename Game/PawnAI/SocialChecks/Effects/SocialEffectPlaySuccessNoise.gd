extends SocialEffectBase
class_name SocialEffectPlaySuccessNoise

func doEffect(_isDeny:bool):
	if(!_isDeny):
		socialHandler.playSuccessNoise(socialHandler.success)
	else:
		socialHandler.playSuccessNoise(-1.0)

extends InteractionSocialCoupleBase

func _init() -> void:
	id = "Hug"
	socialActionName = "Hug"
	socialActionCategory = CATEGORY_FRIENDLY
	
	askText = "WannaHug"
	coupleAnim = "Hug"
	
	lineSure = "HugSure"
	lineNo = "HugNo"
	
	registerForInteractionType = [InteractionType.Talking]

func prepareSocialInteraction():
	var theSocial := makeSocialInteraction("GenericFriendly")
	if(!theSocial):
		return
	theSocial.addAgreeCheck(SocialCheckAffection.new(0.1).addMod(MoodEffects.FriendlyAgreeMod))
	theSocial.addAgreeCheck(SocialCheckExhaustion.new(0.8))
	theSocial.setKind(SocialInteractionKind.Hug)
		
	theSocial.affectionGain = 0.01
	theSocial.affectionLossDeny = 0.005
	theSocial.setKind(SocialInteractionKind.Hug)
	theSocial.memorySuccess = "Hug"
	theSocial.memorySuccessAbove = 0.3

#func start(_roles:Dictionary, _args:Array):

func canDoSocialAction(_main:CharacterPawn, _target:CharacterPawn) -> bool:
	return super.canDoSocialAction(_main, _target)

#func getSocialActions(_main:CharacterPawn, _target:CharacterPawn) -> Array[InteractionAction]:
	#if(!canDoSocialAction(_main, _target)):
		#return []
	#return [
		#action(id, socialActionName),
	#]

#func canCompleteAIGoalAtAll(_interaction:InteractionBase, _goalID:String, _args:Array) -> bool:
#	return false

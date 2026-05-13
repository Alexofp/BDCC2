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

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockAffectionCondition.new(0.3))

func prepareSocialInteraction():
	setSocialRequiredScore(0.5)
	addSocial(SocialScoreAffection.new())
	addSocial(SocialScoreLust.new(0.1))
	
	addSocial(SocialCheckExhaustion.new())
	addSocial(SocialCheckCooldown.new(SocialCooldown.Hug))
	
	addSocial(SocialEffectAddExhaustion.new())
	addSocial(SocialEffectAddAffection.new(0.3, -0.1))
	addSocial(SocialEffectAddMemory.new(FriendlyMemories.Hug))
	

#func start(_roles:Dictionary, _args:Array):

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return super.canDoSocialAction(_c)

#func getSocialActions(_c:SocialInteractionContext) -> Array[InteractionAction]:
	#if(!canDoSocialAction(_main, _target)):
		#return []
	#return [
		#action(id, socialActionName),
	#]

#func canCompleteAIGoalAtAll(_interaction:InteractionBase, _goalID:String, _args:Array) -> bool:
#	return false

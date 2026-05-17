extends InteractionSocialCoupleBase

func _init() -> void:
	id = "Embrace"
	socialActionName = "Embrace"
	socialActionCategory = CATEGORY_FRIENDLY
	
	askText = "WannaEmbrace"
	coupleAnim = "Embrace"
	coupleAnimTime = 6.0
	
	lineSure = "HugSure"
	lineNo = "HugNo"
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 4.1

func prepareUnlockConditions():
	addUnlockCondition(SocialUnlockAffectionCondition.new(1.7))

func prepareSocialInteraction():
	setSocialRequiredScore(2.0)
	addSocial(SocialScoreAffection.new())
	addSocial(SocialScoreLust.new(0.1))
	
	addSocial(SocialCheckExhaustion.new())
	addSocial(SocialCheckCooldown.new(SocialCooldown.Embrace))
	
	addSocial(SocialEffectAddExhaustion.new())
	addSocial(SocialEffectAddAffection.new(0.5, -0.2))
	addSocial(SocialEffectAddMemory.new(FriendlyMemories.Embraced))
	

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

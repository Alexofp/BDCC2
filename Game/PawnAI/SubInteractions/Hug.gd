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
	socialInteraction.addCheck(SocialCheckAffection.new(0.1).addMod(MoodEffects.FriendlyAgreeMod))
	socialInteraction.addCheck(SocialCheckExhaustion.new(0.8))
	socialInteraction.addCheck(SocialCheckCooldown.new(SocialInteractionKind.Hug))
	
	socialInteraction.addSuccessEffect(SocialEffectAddAffection.new(0.01))
	socialInteraction.addSuccessEffect(SocialEffectAddMemoryTarget.new("Hug"))
	
	socialInteraction.addDenyEffect(SocialEffectAddAffection.new(-0.005))

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

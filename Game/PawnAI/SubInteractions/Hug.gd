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
	addSocial(SocialCheckAffection.new(0.1).addMod(MoodEffects.FriendlyAgreeMod))
	addSocial(SocialCheckExhaustion.new(0.8))
	addSocial(SocialCheckCooldown.new(SocialInteractionKind.Hug))
	
	addSocial(SocialEffectAddExhaustion.new())
	addSocial(SocialEffectAddAffection.new(0.01, -0.005))
	addSocial(SocialEffectAddMemory.new("Hug"))
	

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

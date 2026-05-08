extends InteractionBase
class_name InteractionSocialBase

var socialActionName:String = "Fill me!"
var socialActionCategory:Array[String]
var socialInteraction:SocialInteractionHandler
var socialMustBeIntroduced:bool = false
var socialDefaultScore:float = 0.0
var socialShouldEndTalking:bool = false

func _init() -> void:
	id = ""

func canDoSocialActionFinal(_main:CharacterPawn, _target:CharacterPawn) -> bool:
	if(socialMustBeIntroduced):
		if(!GM.main.relationshipSystem.knows(_main.getID(), _target.getID())):
			return false
	
	return canDoSocialAction(_main, _target)

func canDoSocialAction(_main:CharacterPawn, _target:CharacterPawn) -> bool:
	return true

func getSocialActionScore(_main:CharacterPawn, _target:CharacterPawn) -> float:
	return socialDefaultScore

func getSocialActions(_main:CharacterPawn, _target:CharacterPawn) -> Array[InteractionAction]:
	if(!canDoSocialActionFinal(_main, _target)):
		return []
	return [
		action(id, socialActionName).setCategory(socialActionCategory).setScore(getSocialActionScore(_main, _target)),
	]

func getRequiredRoles(_args:Array) -> Dictionary[int, String]:
	return {
		ROLE_MAIN: "main",
		ROLE_TARGET: "target",
	}

func start(_roles:Dictionary, _args:Array):
	pass

func _actions(_role:int):
	pass

func _do(_role:int, _action:InteractionAction):
	pass

func plan(_role:int, _action:AIActionBase) -> AIPlan:
	return planFaceEachOther(ROLE_MAIN, ROLE_TARGET, _role, _action)

func prepareSocialInteraction():
	pass

func addSocial(_check:SocialCheckBase):
	socialInteraction.add(_check)

func startSocialInteraction() -> bool:
	if(!socialInteraction):
		socialInteraction = SocialInteractionHandler.new()
		prepareSocialInteraction()
		socialInteraction.setPawns(getPawn(ROLE_MAIN), getPawn(ROLE_TARGET))
	socialInteraction.trySocialInteraction()
	return true
	
func scoreSocialAgree() -> float:
	if(!socialInteraction):
		return 1.0
	return socialInteraction.scoreAgree()
	
func scoreSocialStatus(_status:int) -> float:
	if(!socialInteraction):
		return 0.0
	return socialInteraction.scoreStatus(_status)

func socialInteractionStart():
	if(!socialInteraction):
		return
	socialInteraction.onStart()

func socialInteractionEnd(_actualStatus:int = SocialInteractionHandler.STATUS_AGREE):
	if(!socialInteraction):
		onSocialInteractionEnd(_actualStatus)
		return
	socialInteraction.onEnd(_actualStatus)
	onSocialInteractionEnd(_actualStatus)

## Use this function to handle your custom agree status.
func onSocialInteractionEnd(_actualStatus:int):
	pass

func socialInteractionDeny():
	socialInteractionEnd(SocialInteractionHandler.STATUS_DENY)

func showInteractionSuccess():
	if(!socialInteraction):
		return
	socialInteraction.showInteractionSuccess()
	

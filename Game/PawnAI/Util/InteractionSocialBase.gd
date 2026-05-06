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

func makeSocialInteraction(_id:String) -> SocialInteractionHandler:
	socialInteraction = GlobalRegistry.createSocialInteraction(_id)
	if(socialInteraction):
		socialInteraction.setInteraction(self)
	return socialInteraction

func prepareSocialInteraction():
	var theSocial := makeSocialInteraction("Generic")
	if(!theSocial):
		return

func startSocialInteraction() -> bool:
	prepareSocialInteraction()
	if(!socialInteraction):
		makeSocialInteraction("Generic")
	if(!socialInteraction):
		assert(false, "Couldn't create a social interaction")
		return false
	socialInteraction.setPawns(getPawn(ROLE_MAIN), getPawn(ROLE_TARGET))
	socialInteraction.trySocialInteraction()
	return true
	
func scoreSocialAgree() -> float:
	if(!socialInteraction):
		return 1.0
	return socialInteraction.scoreAgree()

func socialInteractionStart():
	if(!socialInteraction):
		return
	socialInteraction.onStart()

func socialInteractionEnd():
	if(!socialInteraction):
		return
	socialInteraction.onEnd()

func socialInteractionDeny():
	if(!socialInteraction):
		return
	socialInteraction.onDenied()

func showInteractionSuccess():
	if(!socialInteraction):
		return
	socialInteraction.showInteractionSuccess()
	

extends InteractionBase
class_name InteractionSocialBase

var socialActionName:String = "Fill me!"
var socialActionCategory:Array[String]
var socialInteraction:SocialInteractionHandler
var socialDefaultScore:float = 0.0
var socialUnlockConditions:Array[SocialUnlockConditionBase] = []
var socialRequiredAgreeScore:float = 0.0

var socialFlags:int = 0
const SOCIALFLAG_SHOULD_END_TALKING := 1
const SOCIALFLAG_MUST_BE_INTRODUCED := 2
const SOCIALFLAG_ONLY_IF_TARGET_DOMINATED := 4
const SOCIALFLAG_ALLOWED_IF_TARGET_DOMINATED := 8
const SOCIALFLAG_SUPPORTS_COMBAT := 16

const PRIO_FRIENDLY := 2000.0
const PRIO_ROMANTIC := 1500.0
const PRIO_MEAN := 1000.0
const PRIO_ORDER := 500.0

func _init() -> void:
	id = ""

func postRegistration():
	prepareUnlockConditions()

func postCreation():
	socialInteraction = SocialInteractionHandler.new()
	prepareSocialInteraction()

func setSocialRequiredScore(_score:float):
	socialRequiredAgreeScore = _score

func addSocialUnlockCondition():
	pass

func canDoSocialActionFinal(_c:SocialInteractionContext) -> bool:
	if(socialFlags & SOCIALFLAG_MUST_BE_INTRODUCED):
		if(!GM.main.relationshipSystem.knows(_c.main.getID(), _c.target.getID())):
			return false
	if(socialFlags & SOCIALFLAG_ONLY_IF_TARGET_DOMINATED):
		if(!_c.target.submission.isObeyingPawn(_c.main)):
			return false
	elif(!(socialFlags & SOCIALFLAG_ALLOWED_IF_TARGET_DOMINATED)):
		if(_c.target.submission.isObeyingPawn(_c.main)):
			return false
	
	return canDoSocialAction(_c)

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	return true

func getSocialActionScore(_c:SocialInteractionContext) -> float:
	return socialDefaultScore

func getSocialActions(_c:SocialInteractionContext) -> Array[InteractionAction]:
	if(!canDoSocialActionFinal(_c)):
		return []
	if(!checkUnlockConditionsUnlocked(_c)):
		if(checkUnlockConditionsCloseToBeingUnlocked(_c)):
			var theMessage:String = checkUnlockConditionsGetMessage(_c)
			return [
				action(id, theMessage).setCategory(socialActionCategory).setDisabled(true),
			]
		return []
	return [
		action(id, socialActionName).setCategory(socialActionCategory).setScore(getSocialActionScore(_c)),
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

func prepareUnlockConditions():
	pass

func prepareSocialInteraction():
	pass

func addSocial(_check:SocialCheckBase):
	socialInteraction.add(_check)

func startSocialInteraction() -> bool:
	socialInteraction.setPawns(getPawn(ROLE_MAIN), getPawn(ROLE_TARGET))
	socialInteraction.trySocialInteraction(socialRequiredAgreeScore)
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
	
func addUnlockCondition(_condition:SocialUnlockConditionBase):
	socialUnlockConditions.append(_condition)

func checkUnlockConditionsUnlocked(_c:SocialInteractionContext) -> bool:
	for theCondition in socialUnlockConditions:
		if(!theCondition.isSatisfied(_c)):
			return false
	return true

func checkUnlockConditionsCloseToBeingUnlocked(_c:SocialInteractionContext) -> bool:
	for theCondition in socialUnlockConditions:
		if(!theCondition.isCloseToBeingSatisfied(_c)):
			return false
	return true

func checkUnlockConditionsGetMessage(_c:SocialInteractionContext) -> String:
	var result:Array[String] = []
	for theCondition in socialUnlockConditions:
		var theMessage:String = theCondition.getUnlockMessage(_c)
		if(!theMessage.is_empty()):
			result.append(theMessage)
	if(result.is_empty()):
		return "Requires something"
	return "Requires "+Util.humanReadableList(result)

func doesSupportCombat() -> bool:
	return socialFlags & SOCIALFLAG_SUPPORTS_COMBAT

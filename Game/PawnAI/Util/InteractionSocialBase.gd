extends InteractionBase
class_name InteractionSocialBase

var socialActionName:String = "Fill me!"
var socialActionCategory:Array[String]
var socialInteraction:SocialInteractionHandler
var socialDefaultScore:float = 0.0
var socialUnlockConditions:Array[SocialUnlockConditionBase] = []
var socialRequiredAgreeScore:float = 0.0
var chanceCalculator:SocialInteractionChanceCalculatorBase

const F_NAME := MemorySimpleBank.F_NAME
const F_DESC := MemorySimpleBank.F_DESC
const F_STACKMULT := MemorySimpleBank.F_STACKMULT
const F_STACKMAX := MemorySimpleBank.F_STACKMAX
const F_PRIORITY := MemorySimpleBank.F_PRIORITY
const F_DURATION := MemorySimpleBank.F_DURATION
const F_DURATION_EFFECTS := MemorySimpleBank.F_DURATION_EFFECTS
const F_MOOD := MemorySimpleBank.F_MOOD

func getMemoriesToRegister() -> Dictionary[String, Dictionary]:
	return {
	#"Hug": {
		#F_NAME: "Hug",
		#F_DESC: "Getting hugged feels good.",
		#F_STACKMULT: 0.5,
		#F_STACKMAX: 3,
		#F_DURATION: 600,
		# #F_DURATION_EFFECTS: 30,
		#
		#F_MOOD: MoodValues.new().setMood(0.5),
	#},
	}

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

func getSocialActionName(_context:SocialInteractionContext, _isOnCooldown:bool = false) -> String:
	if(_isOnCooldown):
		return socialActionName + " (On cooldown)"
	if(!chanceCalculator):
		return socialActionName
	var thePostFix:String = chanceCalculator.getActionPostfix(_context)
	if(thePostFix.is_empty()):
		return socialActionName
	return socialActionName+" ("+thePostFix+")"

func postRegistration():
	prepareChanceCalculator()
	prepareUnlockConditions()
	if(!chanceCalculator):
		Log.warning(id+" social interaction doesn't have a chance calculator")
		setChanceCalculator(SICCSimple.new())

func postCreation(_ref:InteractionBase):
	chanceCalculator = _ref.chanceCalculator # Faster rather than re-creating it
	socialInteraction = SocialInteractionHandler.new()
	#socialInteraction.chanceCalculator = chanceCalculator

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
	if(GM.main.relationshipSystem.getActionCooldownPawns(_c.target, _c.main, id) > 0.0):
		return [
			action(id, getSocialActionName(_c, true)).setCategory(socialActionCategory).setDisabled(true),
		]
	
	return [
		action(id, getSocialActionName(_c)).setCategory(socialActionCategory).setScore(getSocialActionScore(_c)),
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

func prepareChanceCalculator():
	pass

func prepareUnlockConditions():
	pass

func setChanceCalculator(_chanceCalculator:SocialInteractionChanceCalculatorBase):
	chanceCalculator = _chanceCalculator
	chanceCalculator.setInteraction(self)

func startSocialInteraction() -> bool:
	# Somehow avoid re-creating the context? It's fine since it's done once..
	socialInteraction.setChanceCalculatorResult(chanceCalculator.calculateChances(SocialInteractionContext.new().setup(getPawn(ROLE_MAIN), getPawn(ROLE_TARGET))))
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

func socialInteractionSendAnswer(_answer:int):
	if(socialInteraction):
		var _allowCrits:bool = true
		if(getPawn(ROLE_TARGET).isControlledByAnyPlayer()):
			_allowCrits = false
		socialInteraction.onAnswer(_answer, _allowCrits)
		if(isCriticalSuccess()):
			addSmallText(ROLE_TARGET, "<CRITICAL!>", Color.GREEN)
		elif(isCriticalFail()):
			addSmallText(ROLE_TARGET, "<CRITICAL!>", Color.RED)

func socialInteractionAgree():
	socialInteractionSendAnswer(SocialInteractionHandler.STATUS_AGREE)

func socialInteractionDeny():
	socialInteractionSendAnswer(SocialInteractionHandler.STATUS_DENY)

func socialInteractionEnd():
	if(!socialInteraction):
		onSocialInteractionEnd()
		return
	socialInteraction.onEnd()
	onSocialInteractionEnd()

## Use this function to handle your custom agree status.
func onSocialInteractionEnd():
	pass

func socialInteractionEndDeny():
	socialInteractionEnd()

func markAsSuccess(_critical:bool = false, _am:float = 1.0):
	socialInteraction.answer = SocialInteractionHandler.STATUS_AGREE
	socialInteraction.critical = _critical
	socialInteraction.success = _am
	Log.Print("Success: "+("CRITICAL " if _critical else "")+str(int(socialInteraction.success*100.0))+"%")

func markAsFail(_critical:bool = false, _am:float = 1.0):
	socialInteraction.answer = SocialInteractionHandler.STATUS_DENY
	socialInteraction.critical = _critical
	socialInteraction.success = _am
	Log.Print("Fail: "+("CRITICAL " if _critical else "")+str(int(socialInteraction.success*100.0))+"%")

func isSuccess() -> bool:
	return socialInteraction.isSuccess()

func isFail() -> bool:
	return socialInteraction.isFail()

func isCriticalSuccess() -> bool:
	return socialInteraction.isCriticalSuccess()

func isCriticalFail() -> bool:
	return socialInteraction.isCriticalFail()

func isCritical() -> bool:
	return isCriticalSuccess() || isCriticalFail()

func addSocialCooldown(_seconds:float = 600.0):
	GM.main.relationshipSystem.addActionCooldownPawns(getPawn(ROLE_TARGET), getPawn(ROLE_MAIN), id, _seconds)

func addSocialCooldownSpecific(_cooldownID:String, _seconds:float = 600.0):
	GM.main.relationshipSystem.addActionCooldownPawns(getPawn(ROLE_TARGET), getPawn(ROLE_MAIN), _cooldownID, _seconds)

func addRewardAffection(_amount:float):
	addAffection(ROLE_MAIN, ROLE_TARGET, _amount)
func addRewardLust(_amount:float):
	addLust(ROLE_MAIN, ROLE_TARGET, _amount)
func addRewardPowerBalance(_amount:float):
	addPowerBalance(ROLE_MAIN, ROLE_TARGET, _amount)
func addRewardMoodTarget(_moodStat:int, _am:float = 1.0):
	addMood(ROLE_TARGET, _moodStat, _am)
func addRewardMoodMain(_moodStat:int, _am:float = 1.0):
	addMood(ROLE_MAIN, _moodStat, _am)

func addMood(_role:int, _moodStat:int, _am:float):
	var thePawn := getPawn(_role)
	if(!thePawn):
		return
	thePawn.mood.addStat(_moodStat, _am)

func addSocialExhaustion(_amount:float = 0.3, _starterMult:float = 0.5):
	if(!socialInteraction):
		return
	socialInteraction.affectTargetSocialExhaustion(_amount, _starterMult)

func addMemoryTarget(_memory:String):
	if(!socialInteraction):
		return
	socialInteraction.addMemoryTarget(_memory)
	
func addMemoryStarter(_memory:String):
	if(!socialInteraction):
		return
	socialInteraction.addMemoryStarter(_memory)

func hasSocialCooldown(_cooldownID:String) -> bool:
	return GM.main.relationshipSystem.getActionCooldownPawns(getPawn(ROLE_TARGET), getPawn(ROLE_MAIN), _cooldownID) > 0.0

func getSocialCooldown(_cooldownID:String) -> float:
	return GM.main.relationshipSystem.getActionCooldownPawns(getPawn(ROLE_TARGET), getPawn(ROLE_MAIN), _cooldownID)

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

func markInteractionShouldEndTalking():
	socialFlags |= SOCIALFLAG_SHOULD_END_TALKING

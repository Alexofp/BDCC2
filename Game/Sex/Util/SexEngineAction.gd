extends RefCounted
class_name SexEngineAction

var type:int = SexEngine.ACTION_CANCEL
var name:String = "Some action"
var disabled:bool = false
var priority:float = 0.0 # Higher = first

var activity:SexEngineActivityBase

var consentStrategy:int = SexEngineActivityBase.CONSENT_RESISTANCE
var consentArgs:Array = []

var sexAction:SexAction
#var category:Array[String]  # Use sexAction.category
#var score:float  # Use sexAction.score
var target:String
var extraButton:bool = false

static func createGeneric(_type:int, _name:String, _activity:SexEngineActivityBase = null) -> SexEngineAction:
	var theAction := SexEngineAction.new()
	theAction.type = _type
	theAction.name = _name
	theAction.activity = _activity
	return theAction

func setConsent(_strategy:int, _args:Array) -> SexEngineAction:
	consentStrategy = _strategy
	consentArgs = _args
	return self

static func createFromQueueEntry(_sexEngine:SexEngine, queueEntry:SexEngineQueueEntry, charID:String) -> Array[SexEngineAction]:
	#var isSexEngineBusy:bool = _sexEngine.isBusy()
	var _charCanDoDomActions:bool = _sexEngine.canDoDomActions(charID)

	var theActivity := queueEntry.obj
	
	var result:Array[SexEngineAction] = []
	
	if(queueEntry is SexEngineQueueEntry.DelayCanCancel):
		var _role:String = theActivity.getRoleFromID(charID)
		if(_role == queueEntry.role):
			result.append(createGeneric(SexEngine.ACTION_CANCEL, "Cancel", theActivity))

	if(queueEntry is SexEngineQueueEntry.ConsentCheck):
		var theConsentStrategy:int = queueEntry.consentStrategy
		var theConsentArgs:Array = queueEntry.consentArgs
		
		if(!_sexEngine.isForced() && _charCanDoDomActions):
			result.append(createGeneric(
				SexEngine.ACTION_FORCE,
				"Force", theActivity
			).setConsent(theConsentStrategy, theConsentArgs))
			
		if(_sexEngine.shouldConsent(charID)):
			result.append(createGeneric(
				SexEngine.ACTION_CONSENT,
				"Allow", theActivity
			).setConsent(theConsentStrategy, theConsentArgs))
			
			if(_charCanDoDomActions || !_sexEngine.isForced()):
				result.append(createGeneric(
					SexEngine.ACTION_DENY_CONSENT,
					"Deny", theActivity
				).setConsent(theConsentStrategy, theConsentArgs))
			else:
				result.append(createGeneric(
					SexEngine.ACTION_RESIST,
					"Resist!", theActivity
				).setConsent(theConsentStrategy, theConsentArgs))
				
			result.append(createGeneric(
				SexEngine.ACTION_CONSENT_ALWAYS,
				"Always allow", theActivity
			).setConsent(theConsentStrategy, theConsentArgs))
	
	return result

static func createFromSexAction(actionEntry:SexAction, _activity:SexEngineActivityBase) -> SexEngineAction:
	var _sexEngine := _activity.getSexEngine()
	var theAction := SexEngineAction.new()
	theAction.type = SexEngine.ACTION_SEX_ACTION
	theAction.name = actionEntry.actionName if !_sexEngine.hasCooldown(actionEntry.cooldownID) else ("("+str(int(ceil(_sexEngine.getCooldown(actionEntry.cooldownID))))+") "+actionEntry.actionName)
	theAction.activity = _activity
	theAction.sexAction = actionEntry
	theAction.disabled = actionEntry.disabled || _sexEngine.hasCooldown(actionEntry.cooldownID)
	theAction.extraButton = actionEntry.extra
	theAction.priority = actionEntry.priority
	#category = actionEntry.category,
	#score = actionEntry.score,
	return theAction

func getScore() -> float:
	if(sexAction):
		return sexAction.score
	return 0.0

func getCategory() -> Array[String]:
	if(sexAction):
		return sexAction.category
	return []

func canBePickedWhileImportantDialogues() -> bool:
	return false

func setPriority(_prio:float) -> SexEngineAction:
	priority = _prio
	return self

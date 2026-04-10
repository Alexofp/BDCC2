extends RefCounted
class_name SexAction

#var id:String = ""
var actionName:String = ""
#var args:Array = []
var score:float = 0.0
var category:Array[String] = []
var payload:Array[SexEngineQueueEntry] = []
var cooldownID:String = ""
var cooldownTime:float = 0.0
var disabled:bool = false
var overridePriority:int = 0

static func make(_name:String) -> SexAction:
	var theAction:SexAction = SexAction.new()
	theAction.actionName = _name
	return theAction

func do(_id:String, _args:Array = []) -> SexAction:
	payload.append(SexEngineQueueEntry.AutoAction.create("", "", _id, _args))
	return self

func delay(_delay:float) -> SexAction:
	payload.append(SexEngineQueueEntry.Delay.create(_delay))
	return self

func delayCancel(_delay:float) -> SexAction:
	payload.append(SexEngineQueueEntry.DelayCanCancel.create(_delay, ""))
	return self

func consent(_consenters:Array = [], _conTexts:Array=[], _scoringStrategy:int = SexEngineActivityBase.CONSENT_RESISTANCE, _strategyArgs:Array = []) -> SexAction:
	var conDict:Dictionary[String, bool] = {}
	for _consenter in _consenters:
		if(_consenter is SexParticipantInfo):
			conDict[_consenter.getID()] = false
		else:
			conDict[_consenter] = false
	payload.append(SexEngineQueueEntry.ConsentCheck.create(5.0, 3.0, conDict, _scoringStrategy, _strategyArgs, _conTexts))
	return self

func start(_roles:Dictionary, _args:Dictionary = {}) -> SexAction:
	var theRolesFinal:Dictionary[String, String] = {}
	for theRole in _roles:
		if(_roles[theRole] is SexParticipantInfo):
			theRolesFinal[theRole] = _roles[theRole].getID()
		else:
			theRolesFinal[theRole] = _roles[theRole]
	payload.append(SexEngineQueueEntry.StartActivity.create("", theRolesFinal, _args, true))
	return self

func setScore(_score:float) -> SexAction:
	score = _score
	return self

func setCat(_category:Array[String]) -> SexAction:
	category = _category
	return self

func setCooldown(_cooldownID:String, _cooldownTime:float = 0.0) -> SexAction:
	cooldownID = _cooldownID
	cooldownTime = _cooldownTime
	return self

func setDisabled(_dis:bool) -> SexAction:
	disabled = _dis
	return self

func setEnabled(_dis:bool) -> SexAction:
	disabled = !_dis
	return self

func expose(_giver:Variant, _receiver:Variant, _fetishID:String, _intensity:float = 1.0) -> SexAction:
	payload.append(SexEngineQueueEntry.Expose.create(_giver.getID() if _giver is SexParticipantInfo else _giver, _receiver.getID() if _receiver is SexParticipantInfo else _receiver, _fetishID, _intensity))
	return self

func setOverridePriority(_overridePriority:int) -> SexAction:
	overridePriority = _overridePriority
	return self

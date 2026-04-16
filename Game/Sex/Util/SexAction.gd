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
var roles:Dictionary[String, String] # role -> char id
var extra:bool = false # Displayed above normal actions if true
var priority:float = 0.0 # Higher priority actions go first in the list

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

func consent(_consentID:String, _consenters:Array = [], _conTexts:Array=[], _scoringStrategy:int = SexEngineActivityBase.CONSENT_RESISTANCE, _strategyArgs:Array = []) -> SexAction:
	var conDict:Dictionary[String, bool] = {}
	for _consenter in _consenters:
		if(_consenter is SexParticipantInfo):
			conDict[_consenter.getID()] = false
		else:
			conDict[getRoleID(_consenter)] = false
	payload.append(SexEngineQueueEntry.ConsentCheck.create(_consentID, 5.0, 3.0, conDict, _scoringStrategy, _strategyArgs, _conTexts))
	return self

func start(_activityID:String, _roles:Dictionary, _args:Dictionary = {}) -> SexAction:
	var theRolesFinal:Dictionary[String, String] = {}
	for theRole in _roles:
		if(_roles[theRole] is SexParticipantInfo):
			theRolesFinal[theRole] = _roles[theRole].getID()
		else:
			theRolesFinal[theRole] = getRoleID(_roles[theRole])
	payload.append(SexEngineQueueEntry.StartActivity.create(_activityID, theRolesFinal, _args, true))
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

func expose(_giver:String, _receiver:String, _fetishID:String, _intensity:float = 1.0) -> SexAction:
	payload.append(SexEngineQueueEntry.Expose.create(getRoleID(_giver), getRoleID(_receiver), _fetishID, _intensity))
	return self

func setOverridePriority(_overridePriority:int) -> SexAction:
	overridePriority = _overridePriority
	return self

func setRoles(_roles:Dictionary) -> SexAction:
	roles = {}
	for theRole in _roles:
		roles[theRole] = _roles[theRole] if !(_roles[theRole] is SexParticipantInfo) else _roles[theRole].getID()
	#roles = _roles
	return self

func getRoleID(_role:String) -> String:
	if(roles.has(_role)):
		return roles[_role]
	assert(false, "Role not found "+str(_role))
	return _role

func setExtra(_e:bool) -> SexAction:
	extra = _e
	return self

func setPriority(_prio:float) -> SexAction:
	priority = _prio
	return self

extends RefCounted
class_name SexEngineQueueEntry

var type:int = SexEngine.QUEUE_DELAY
var obj:SexEngineActivityBase
var justSkip:bool = false

func saveData() -> Dictionary:
	return {}

func loadData(_data:Dictionary):
	pass

func setObj(_obj) -> SexEngineQueueEntry:
	obj = _obj
	return self

func supplyActionContext(_activity:SexEngineActivityBase, _role:String, _action:SexAction):
	obj = _activity

class Delay extends SexEngineQueueEntry:
	var time:float = 1.0
	var elapsedTime:float = 0.0
	static func create(_time:float) -> Delay:
		var theEntry := Delay.new()
		theEntry.type = SexEngine.QUEUE_DELAY
		theEntry.time = _time
		theEntry.elapsedTime = 0.0
		return theEntry
	func saveData() -> Dictionary:
		return {
			t = time,
			et = elapsedTime,
		}
	func loadData(_data:Dictionary):
		time = SAVE.loadFloat(_data, "t")
		elapsedTime = SAVE.loadFloat(_data, "et")

class CancelStopper extends SexEngineQueueEntry:
	static func create() -> CancelStopper:
		var theEntry := CancelStopper.new()
		theEntry.type = SexEngine.QUEUE_CANCEL_STOPPER
		theEntry.justSkip = true
		return theEntry

class CancelCatcher extends SexEngineQueueEntry:
	var state:String
	var event:SexEvent
	static func create(_state:String, _event:SexEvent) -> CancelCatcher:
		var theEntry := CancelCatcher.new()
		theEntry.type = SexEngine.QUEUE_CANCEL_CATCHER
		theEntry.state = _state
		theEntry.event = _event
		theEntry.justSkip = true
		return theEntry
	func saveData() -> Dictionary:
		return {
			s = state,
			event = event.saveData(),
		}
	func loadData(_data:Dictionary):
		state = SAVE.loadStr(_data, "s")
		event = SexEvent.new()
		event.loadData(SAVE.loadDict(_data, "event"))

class DelayCanCancel extends SexEngineQueueEntry:
	var time:float = 1.0
	var elapsedTime:float = 0.0
	var role:String
	static func create(_time:float, _role:String) -> DelayCanCancel:
		var theEntry := DelayCanCancel.new()
		theEntry.type = SexEngine.QUEUE_DELAY_CANCANCEL
		theEntry.time = _time
		theEntry.elapsedTime = 0.0
		theEntry.role = _role
		return theEntry
	func supplyActionContext(_activity:SexEngineActivityBase, _role:String, _action:SexAction):
		obj = _activity
		role = _role
	func saveData() -> Dictionary:
		return {
			t = time,
			et = elapsedTime,
			role = role,
		}
	func loadData(_data:Dictionary):
		time = SAVE.loadFloat(_data, "t")
		elapsedTime = SAVE.loadFloat(_data, "et")
		role = SAVE.loadStr(_data, "role")

class SetState extends SexEngineQueueEntry:
	var state:String
	static func create(_state:String) -> SetState:
		var theEntry := SetState.new()
		theEntry.type = SexEngine.QUEUE_SET_STATE
		theEntry.state = _state
		return theEntry
	func saveData() -> Dictionary:
		return {
			s = state,
		}
	func loadData(_data:Dictionary):
		state = SAVE.loadStr(_data, "s")

class Event extends SexEngineQueueEntry:
	var state:String
	var event:SexEvent
	static func create(_state:String, _event:SexEvent) -> Event:
		var theEntry := Event.new()
		theEntry.type = SexEngine.QUEUE_EVENT
		theEntry.state = _state
		theEntry.event = _event
		return theEntry
	func saveData() -> Dictionary:
		return {
			s = state,
			event = event.saveData(),
		}
	func loadData(_data:Dictionary):
		state = SAVE.loadStr(_data, "s")
		event = SexEvent.new()
		event.loadData(SAVE.loadDict(_data, "event"))

class AutoAction extends SexEngineQueueEntry:
	var state:String
	var role:String
	var actionID:String
	var args:Array
	static func create(_state:String, _role:String, _actionID:String, _args:Array=[]) -> AutoAction:
		var theEntry := AutoAction.new()
		theEntry.type = SexEngine.QUEUE_AUTOACTION
		theEntry.state = _state
		theEntry.role = _role
		theEntry.actionID = _actionID
		theEntry.args = _args
		return theEntry
	func supplyActionContext(_activity:SexEngineActivityBase, _role:String, _action:SexAction):
		obj = _activity
		state = _activity.getState()
		role = _role
	func saveData() -> Dictionary:
		return {
			s = state,
			role = role,
			aid = actionID,
			args = args,
		}
	func loadData(_data:Dictionary):
		state = SAVE.loadStr(_data, "s")
		role = SAVE.loadStr(_data, "role")
		actionID = SAVE.loadStr(_data, "aid")
		args = SAVE.loadArray(_data, "args")

class ActionText extends SexEngineQueueEntry:
	var text:String
	static func create(_text:String) -> ActionText:
		var theEntry := ActionText.new()
		theEntry.type = SexEngine.QUEUE_ACTIONTEXT
		theEntry.text = _text
		return theEntry
	func saveData() -> Dictionary:
		return {
			t = text,
		}
	func loadData(_data:Dictionary):
		text = SAVE.loadStr(_data, "t")

class CommentOnAction extends SexEngineQueueEntry:
	var line:String
	var starterID:String
	var targetID:String
	static func create(_line:String, _starterID:String, _targetID:String) -> CommentOnAction:
		var theEntry := CommentOnAction.new()
		theEntry.type = SexEngine.QUEUE_COMMENT_ON_ACTION
		theEntry.line = _line
		theEntry.starterID = _starterID
		theEntry.targetID = _targetID
		return theEntry
	func saveData() -> Dictionary:
		return {
			l = line,
			sid = starterID,
			tid = targetID,
		}
	func loadData(_data:Dictionary):
		line = SAVE.loadStr(_data, "l")
		starterID = SAVE.loadStr(_data, "sid")
		targetID = SAVE.loadStr(_data, "tid")

class ConsentCheck extends SexEngineQueueEntry:
	var delay:float
	var delayElapsed:float = 0.0
	var delayForced:float
	var needToConsent:Dictionary[String, bool] # Character id = false
	var consentStrategy:int
	var consentArgs:Array
	var hoverTexts:Array
	var resisted:bool = false
	var consentID:String = ""
	var starterID:String = ""
	var roles:Dictionary[String, String]
	func saveData() -> Dictionary:
		return {
			d = delay,
			de = delayElapsed,
			df = delayForced,
			ntc = needToConsent,
			cs = consentStrategy,
			ca = consentArgs,
			ht = hoverTexts,
			r = resisted,
			cid = consentID,
			sid = starterID,
			roles = roles,
		}
	func loadData(_data:Dictionary):
		delay = SAVE.loadFloat(_data, "d")
		delayElapsed = SAVE.loadFloat(_data, "de")
		delayForced = SAVE.loadFloat(_data, "df")
		needToConsent.clear()
		needToConsent.merge(SAVE.loadDict(_data, "ntc"))
		consentStrategy = SAVE.loadInt(_data, "cs")
		consentArgs = SAVE.loadArray(_data, "ca")
		hoverTexts = SAVE.loadArray(_data, "ht")
		resisted = SAVE.loadBool(_data, "r")
		consentID = SAVE.loadStr(_data, "cid")
		starterID = SAVE.loadStr(_data, "sid")
		roles.clear()
		roles.merge(SAVE.loadDict(_data, "roles"))
	
	static func create(_consentID:String, _delay:float, _delayForced:float, _needToConsent:Dictionary[String, bool], _consentStrategy:int, _consentArgs:Array, _hoverTexts:Array) -> ConsentCheck:
		var theEntry := ConsentCheck.new()
		theEntry.type = SexEngine.QUEUE_CONSENT_CHECK
		theEntry.consentID = _consentID
		theEntry.delay = _delay
		theEntry.delayForced = _delayForced
		theEntry.needToConsent = _needToConsent
		theEntry.consentStrategy = _consentStrategy
		theEntry.consentArgs = _consentArgs
		theEntry.hoverTexts = _hoverTexts
		return theEntry
	func supplyActionContext(_activity:SexEngineActivityBase, _role:String, _action:SexAction):
		obj = _activity
		if(needToConsent.is_empty()):
			for theID in _activity.idToRole:
				needToConsent[theID] = false
		starterID = _activity.getRoleID(_role)
		needToConsent.erase(starterID)
		for _therole in _action.roles:
			roles[_therole] = _action.getRoleID(_therole)# _action.roles[_therole].getID()
		if(hoverTexts.size() > 2):
			var extraReplacers:Dictionary[String, Variant] = hoverTexts[2]
			for _therole in extraReplacers:
				if(extraReplacers[_therole] is SexParticipantInfo):
					roles[_therole] = extraReplacers[_therole].getID()
				else:
					roles[_therole] = _action.getRoleID(extraReplacers[_therole])
		#var newConsentID:Dictionary[String, bool] = {}
		#for theRole in needToConsent:
		#	var theID:String = _activity.getRoleID(theRole)
		#	if(!theID.is_empty()):
		#		newConsentID[theID] = false
		#needToConsent = newConsentID
	func getIDsNoConsent() -> Array[String]:
		var result:Array[String] = []
		for theID in needToConsent:
			if(!needToConsent[theID]):
				result.append(theID)
		return result
	
class ResistMinigameStart extends SexEngineQueueEntry:
	var started:bool = false
	var state:String
	static func create(_state:String) -> ResistMinigameStart:
		var theEntry := ResistMinigameStart.new()
		theEntry.type = SexEngine.QUEUE_RESIST_MINIGAME
		theEntry.state = _state
		return theEntry
	func saveData() -> Dictionary:
		return {
			st = started,
			s = state,
		}
	func loadData(_data:Dictionary):
		started = SAVE.loadBool(_data, "st")
		state = SAVE.loadStr(_data, "s")

class Expose extends SexEngineQueueEntry:
	var giverID:String
	var receiverID:String
	var fetishID:String
	var intensity:float
	func saveData() -> Dictionary:
		return {
			gid = giverID,
			rid = receiverID,
			fid = fetishID,
			i = intensity,
		}
	func loadData(_data:Dictionary):
		giverID = SAVE.loadStr(_data, "gid")
		receiverID = SAVE.loadStr(_data, "rid")
		fetishID = SAVE.loadStr(_data, "fid")
		intensity = SAVE.loadFloat(_data, "i")
	static func create(_giverID:String, _receiverID:String, _fetishID:String, _intensity:float) -> Expose:
		var theEntry := Expose.new()
		theEntry.type = SexEngine.QUEUE_EXPOSE
		theEntry.giverID = _giverID
		theEntry.receiverID = _receiverID
		theEntry.fetishID = _fetishID
		theEntry.intensity = _intensity
		return theEntry
	func supplyActionContext(_activity:SexEngineActivityBase, _role:String, _action:SexAction):
		obj = _activity
		#giverID = _action.getRoleID(giverID)
		#receiverID = _action.getRoleID(receiverID)
		#giverID = _activity.getRoleID(giverID)
		#receiverID = _activity.getRoleID(receiverID)

class StartActivity extends SexEngineQueueEntry:
	var activityID:String
	var roles:Dictionary[String, String]
	var args:Dictionary
	var isMain:bool
	func saveData() -> Dictionary:
		return {
			aid = activityID,
			roles = roles,
			args = args,
			im = isMain,
		}
	func loadData(_data:Dictionary):
		activityID = SAVE.loadStr(_data, "aid")
		roles.clear()
		roles.merge(SAVE.loadDict(_data, "roles"))
		args = SAVE.loadDict(_data, "args")
		isMain = SAVE.loadBool(_data, "im")
	static func create(_activityID:String, _roles:Dictionary[String, String], _args:Dictionary, _isMain:bool = true) -> StartActivity:
		var theEntry := StartActivity.new()
		theEntry.type = SexEngine.QUEUE_START_MAIN_ACTIVITY
		theEntry.activityID = _activityID
		theEntry.roles = _roles
		theEntry.args = _args
		theEntry.isMain = _isMain
		return theEntry
	func supplyActionContext(_activity:SexEngineActivityBase, _role:String, _action:SexAction):
		obj = _activity
		var theRef := GlobalRegistry.getSexActivityRef(activityID)
		if(theRef):
			isMain = (theRef is SexMainActivity)
		#assert(false, "bad")

static func createEntry(_type:int) -> SexEngineQueueEntry:
	var result:SexEngineQueueEntry
	if(_type == SexEngine.QUEUE_DELAY):
		result = Delay.new()
	elif(_type == SexEngine.QUEUE_CANCEL_STOPPER):
		result = CancelStopper.new()
		result.justSkip = true
	elif(_type == SexEngine.QUEUE_CANCEL_CATCHER):
		result = CancelCatcher.new()
		result.justSkip = true
	elif(_type == SexEngine.QUEUE_DELAY_CANCANCEL):
		result = DelayCanCancel.new()
	elif(_type == SexEngine.QUEUE_SET_STATE):
		result = SetState.new()
	elif(_type == SexEngine.QUEUE_EVENT):
		result = Event.new()
	elif(_type == SexEngine.QUEUE_AUTOACTION):
		result = AutoAction.new()
	elif(_type == SexEngine.QUEUE_ACTIONTEXT):
		result = ActionText.new()
	elif(_type == SexEngine.QUEUE_COMMENT_ON_ACTION):
		result = CommentOnAction.new()
	elif(_type == SexEngine.QUEUE_CONSENT_CHECK):
		result = ConsentCheck.new()
	elif(_type == SexEngine.QUEUE_RESIST_MINIGAME):
		result = ResistMinigameStart.new()
	elif(_type == SexEngine.QUEUE_EXPOSE):
		result = Expose.new()
	elif(_type == SexEngine.QUEUE_START_MAIN_ACTIVITY):
		result = StartActivity.new()
		result.isMain = true
	elif(_type == SexEngine.QUEUE_START_SIDE_ACTIVITY):
		result = StartActivity.new()
		result.isMain = false
		
	if(result):
		result.type = _type
	return result

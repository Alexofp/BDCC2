extends RefCounted
class_name SexEngineQueueEntry

var type:int = SexEngine.QUEUE_DELAY
var obj
var justSkip:bool = false

func setObj(_obj) -> SexEngineQueueEntry:
	obj = _obj
	return self

class Delay extends SexEngineQueueEntry:
	var time:float = 1.0
	var elapsedTime:float = 0.0
	static func create(_time:float) -> Delay:
		var theEntry := Delay.new()
		theEntry.type = SexEngine.QUEUE_DELAY
		theEntry.time = _time
		theEntry.elapsedTime = 0.0
		return theEntry

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

class SetState extends SexEngineQueueEntry:
	var state:String
	static func create(_state:String) -> SetState:
		var theEntry := SetState.new()
		theEntry.type = SexEngine.QUEUE_SET_STATE
		theEntry.state = _state
		return theEntry

class Event extends SexEngineQueueEntry:
	var state:String
	var event:SexEvent
	static func create(_state:String, _event:SexEvent) -> Event:
		var theEntry := Event.new()
		theEntry.type = SexEngine.QUEUE_EVENT
		theEntry.state = _state
		theEntry.event = _event
		return theEntry

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

class ActionText extends SexEngineQueueEntry:
	var text:String
	static func create(_text:String) -> ActionText:
		var theEntry := ActionText.new()
		theEntry.type = SexEngine.QUEUE_ACTIONTEXT
		theEntry.text = _text
		return theEntry

class ConsentCheck extends SexEngineQueueEntry:
	var delay:float
	var delayElapsed:float = 0.0
	var delayForced:float
	var needToConsent:Dictionary[String, bool]
	var consentStrategy:int
	var consentArgs:Array
	var hoverTexts:Array
	var resisted:bool = false
	
	static func create(_delay:float, _delayForced:float, _needToConsent:Dictionary[String, bool], _consentStrategy:int, _consentArgs:Array, _hoverTexts:Array) -> ConsentCheck:
		var theEntry := ConsentCheck.new()
		theEntry.type = SexEngine.QUEUE_CONSENT_CHECK
		theEntry.delay = _delay
		theEntry.delayForced = _delayForced
		theEntry.needToConsent = _needToConsent
		theEntry.consentStrategy = _consentStrategy
		theEntry.consentArgs = _consentArgs
		theEntry.hoverTexts = _hoverTexts
		return theEntry

class ResistMinigameStart extends SexEngineQueueEntry:
	var started:bool = false
	var state:String
	static func create(_state:String) -> ResistMinigameStart:
		var theEntry := ResistMinigameStart.new()
		theEntry.type = SexEngine.QUEUE_RESIST_MINIGAME
		theEntry.state = _state
		return theEntry

class Expose extends SexEngineQueueEntry:
	var giverID:String
	var receiverID:String
	var fetishID:String
	var intensity:float
	static func create(_giverID:String, _receiverID:String, _fetishID:String, _intensity:float) -> Expose:
		var theEntry := Expose.new()
		theEntry.type = SexEngine.QUEUE_EXPOSE
		theEntry.giverID = _giverID
		theEntry.receiverID = _receiverID
		theEntry.fetishID = _fetishID
		theEntry.intensity = _intensity
		return theEntry

class StartMainActivity extends SexEngineQueueEntry:
	var activityID:String
	var roles:Dictionary
	var args:Dictionary
	static func create(_activityID:String, _roles:Dictionary, _args:Dictionary) -> StartMainActivity:
		var theEntry := StartMainActivity.new()
		theEntry.type = SexEngine.QUEUE_START_MAIN_ACTIVITY
		theEntry.activityID = _activityID
		theEntry.roles = _roles
		theEntry.args = _args
		return theEntry

class StartSideActivity extends SexEngineQueueEntry:
	var activityID:String
	var roles:Dictionary
	var args:Dictionary
	static func create(_activityID:String, _roles:Dictionary, _args:Dictionary) -> StartSideActivity:
		var theEntry := StartSideActivity.new()
		theEntry.type = SexEngine.QUEUE_START_SIDE_ACTIVITY
		theEntry.activityID = _activityID
		theEntry.roles = _roles
		theEntry.args = _args
		return theEntry

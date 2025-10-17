extends RefCounted
class_name SexEngineChange

const ANIM_SCENE_CHANGE = 0
const PARTICIPANT_UPDATE = 1
const MODE_CHANGE = 2

var type:int = -1
var mode:int = -1
var charID:String = ""

static func makeSceneChange() -> SexEngineChange:
	var newChange:SexEngineChange = SexEngineChange.new()
	newChange.type = ANIM_SCENE_CHANGE
	return newChange

static func makeParticipantUpdate(_charID:String) -> SexEngineChange:
	var newChange:SexEngineChange = SexEngineChange.new()
	newChange.type = PARTICIPANT_UPDATE
	newChange.charID = _charID
	return newChange
	
static func makeModeChange(_newMode:int) -> SexEngineChange:
	var newChange:SexEngineChange = SexEngineChange.new()
	newChange.type = MODE_CHANGE
	newChange.mode = _newMode
	return newChange

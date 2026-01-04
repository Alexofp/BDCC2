extends RefCounted
class_name SexPoseBase

var id:String = ""

var anim:String
var sexActivityID:String = ""
var sexTypeID:String = SexType.OnTheFloor

var canPickRandomly:bool = true

func getVisibleName() -> String:
	return id

func canBeUsedFinal(_sexEngine:SexEngine, _sexActivity:SexEngineActivityBase) -> bool:
	if(sexTypeID != _sexEngine.getSexTypeID()):
		return false
	
	return canBeUsed(_sexEngine, _sexActivity)

func canBeUsed(_sexEngine:SexEngine, _sexActivity:SexEngineActivityBase) -> bool:
	#if(_sexEngine.getSexTypeID() != sexTypeID):
	#	return false
	#if(_sexActivity.id != sexActivityID):
	#	return false
	return true

#playAnim(
#AnimScene.TestSex,
#"tease",
#{dom={id=ROLE_TOP}, sub=ROLE_BOTTOM},
#{hole=(AnimSceneHole.Vagina if isVaginal else AnimSceneHole.Anus)}
#)

#playPose(poseID, "tease"

func getAnim() -> String:
	return anim

func getState(_stateRaw:String) -> String:
	return _stateRaw

func getRoles(_rolesRaw:Dictionary) -> Dictionary:
	return _rolesRaw

#func getPlayAnimInfo(_state:String, _roles:Dictionary, _args:Dictionary) -> Dictionary:
	#return {
		#id = getAnim(),
		#state = getState(_state),
		#roles = getRoles(_roles),
		#args = _args,
	#}

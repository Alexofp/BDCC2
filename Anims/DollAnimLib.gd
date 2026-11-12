extends RefCounted
class_name DollAnimLib

var id:String = ""
var libPath:String = ""

var alwaysAdd:bool = false

var animToInfo:Dictionary[String, Array] #dict[animName, Array[length, isLoop]]

var cachedLib:AnimationLibrary
var cachedStatus:int = 0

func fillAnimInfo() -> bool:
	var theLib:AnimationLibrary = cachedLib
	if(!theLib):
		theLib = await GlobalRegistry.loadThreaded(libPath)
	if(!theLib):
		return false
	
	for theAnimName:String in theLib.get_animation_list():
		var theAnim:Animation = theLib.get_animation(theAnimName)
		animToInfo[theAnimName] = [theAnim.length, theAnim.loop_mode != Animation.LOOP_NONE, theAnim.step, theAnim.loop_mode]
	return true

func getAnimInfo(_name:String) -> Array:
	if(!animToInfo.has(_name)):
		return [-1.0, true, 0.1, Animation.LOOP_LINEAR]
	return animToInfo[_name]

func loadCached():
	cachedLib = await GlobalRegistry.loadThreaded(libPath)
	fillAnimInfo()
	if(cachedLib):
		cachedStatus = 1 # all good
	else:
		cachedStatus = -1 # error

func loadUncached():
	var theSucc:bool = await fillAnimInfo()
	if(theSucc):
		cachedStatus = 1 # all good
	else:
		cachedStatus = -1 # error
	

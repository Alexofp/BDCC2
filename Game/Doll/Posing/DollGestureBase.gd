extends RefCounted
class_name DollGestureBase

var id:String = ""
var animName:String = ""
var visibleName:String = "Fill me!"
var playFullBody:bool = false
var playPartial:bool = true

func getName() -> String:
	return visibleName

func getAnimName() -> String:
	return animName

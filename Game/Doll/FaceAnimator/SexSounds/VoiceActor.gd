extends RefCounted
class_name VoiceActor

var id:String = ""
var actorName:String = ""
var links:Dictionary = {}

func getName() -> String:
	return actorName
	
func getLinks() -> Dictionary:
	return links

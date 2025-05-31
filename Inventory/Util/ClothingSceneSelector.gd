extends RefCounted
class_name ClothingSceneSelector

var priority:float = 0.0
var itemID:String = ""
var sceneByBodypartID:Dictionary = {
}
#
#func getScenePath(_itemID:String, _bodypartID:String) -> String:
	#if(_bodypartID == bodypartID):
		#if(sceneByItemID.has(_itemID)):
			#return sceneByItemID[_itemID]
	#return ""

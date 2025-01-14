@tool
extends Node3D
class_name PCSceneLoader

@export_category("Map loading")
@export var mapToLoad:PCEditorScene
@export var loadMap: bool = false:
	set(value):
		if(value):
			doLoadMap(mapToLoad)
@export var clearMap: bool = false:
	set(value):
		if(value):
			doClearMap()

static func delete_children(node: Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func doClearMap():
	delete_children(self)

func doLoadMap(theMap:PCEditorScene):
	delete_children(self)
	
	if(theMap == null):
		return
	
	var mapData:Dictionary = theMap.data
	if(mapData.has("props")):
		var theProps:Array = mapData["props"]
		
		for propInfo in theProps:
			var propPath:String = propInfo["path"]
			var theTransform:Transform3D = propInfo["transform"]
			var theSettings:Dictionary = propInfo["settings"]
			
			var newNode:Node3D = load(propPath).instantiate()
			if(newNode == null):
				printerr("PROP NOT FOUND: "+propPath)
			add_child(newNode)
			newNode.owner = get_tree().edited_scene_root
			newNode.transform = theTransform
			if(newNode.has_method("applyEditorOption")):
				if(!theSettings.is_empty()):
					get_tree().edited_scene_root.set_editable_instance(newNode, true)
				for settingID in theSettings:
					newNode.applyEditorOption(settingID, theSettings[settingID])

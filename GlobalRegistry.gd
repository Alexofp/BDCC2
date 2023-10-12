extends Node

# And so we meet again, GlobalRegistry..

var bodyparts: Dictionary = {}
var bodypartRefs: Dictionary = {}

func _init():
	registerBodypartsFolder("res://Player/Bodyparts/Body/")
	registerBodypartsFolder("res://Player/Bodyparts/Head/")
	registerBodypartsFolder("res://Player/Bodyparts/Ear/")
	registerBodypartsFolder("res://Player/Bodyparts/Legs/")
	print("GlobalRegistry: Registered everything")

func registerBodypart(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	bodyparts[object.id] = loadedClass
	bodypartRefs[object.id] = object

func registerBodypartsFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerBodypart(scriptPath)

func createBodypart(id: String) -> BaseBodypart:
	if(bodyparts.has(id)):
		return bodyparts[id].new()
	else:
		Log.printerr("ERROR: bodypart with the id "+str(id)+" wasn't found")
		return null

func getBodyparts():
	return bodypartRefs

func getBodypartRef(id: String) -> BaseBodypart:
	if(bodypartRefs.has(id)):
		return bodypartRefs[id]
	else:
		Log.printerr("ERROR: bodypart with the id "+str(id)+" wasn't found")
		return null

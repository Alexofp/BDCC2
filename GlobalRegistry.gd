extends Object
class_name GlobalRegistry # and so we meet again

static var wasInit = false

static var bodyparts: Dictionary = {}
static var bodypartRefs: Dictionary = {}
static var textureVariants:Dictionary = {}
static var textureVariantsByType:Dictionary = {}

static func doInit():
	if(wasInit):
		return
	wasInit = true
	registerBodypartsFolder("res://Game/Character/Bodyparts/Body/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Head/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Hair/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Ear/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Tail/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Penis/")
	registerBodypartsFolder("res://Game/Character/Bodyparts/Horn/")
	
	registerTextureVariantsFolder("res://Mesh/Parts/SharedTextures/")
	
	Log.Print("GlobalRegistry: Registered everything")


static func registerBodypart(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is BodypartBase):
		bodyparts[object.id] = loadedClass
		bodypartRefs[object.id] = object
		
		var textureVariantsPaths:Array = object.getTextureVariantsPaths()
		for thePath in textureVariantsPaths:
			registerTextureVariant(thePath)

static func registerBodypartsFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerBodypart(scriptPath)

static func createBodypart(id: String) -> BodypartBase:
	if(bodyparts.has(id)):
		return bodyparts[id].new()
	else:
		Log.Printerr("ERROR: bodypart with the id "+str(id)+" wasn't found")
		return null

static func getBodyparts():
	return bodypartRefs

static func getBodypartRef(id: String) -> BodypartBase:
	if(bodypartRefs.has(id)):
		return bodypartRefs[id]
	else:
		Log.Printerr("ERROR: bodypart with the id "+str(id)+" wasn't found")
		return null

static func getBodypartIDsForSlot(bodypartSlot:String):
	var result:Array = []
	
	for bodypartID in bodypartRefs:
		if(bodypartRefs[bodypartID].supportsSlot(bodypartSlot)):
			result.append(bodypartID)
	
	return result

static func getBodypartIDsOfType(bodypartType:String):
	var result:Array = []
	
	for bodypartID in bodypartRefs:
		if(bodypartRefs[bodypartID].getBodypartType() == bodypartType):
			result.append(bodypartID)
	
	return result


static func registerTextureVariant(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	if(object is TextureVariantMany):
		var theType:String = object.type
		var theSubType:String = object.subType
		if(theType != ""):
			if(!textureVariantsByType.has(theType)):
				textureVariantsByType[theType] = {}
			if(!textureVariantsByType[theType].has(theSubType)):
				textureVariantsByType[theType][theSubType] = []
		
		for texVar in object.getVariants():
			textureVariants[texVar.id] = texVar
			if(theType != ""):
				textureVariantsByType[theType][theSubType].append(texVar.id)
		
	elif(object is TextureVariant):
		var theType:String = object.type
		var theSubType:String = object.subType
		textureVariants[object.id] = object
		if(theType != ""):
			if(!textureVariantsByType.has(theType)):
				textureVariantsByType[theType] = {}
			if(!textureVariantsByType[theType].has(theSubType)):
				textureVariantsByType[theType][theSubType] = []
			textureVariantsByType[theType][theSubType].append(object.id)

static func registerTextureVariantsFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder)
	for scriptPath in scripts:
		registerTextureVariant(scriptPath)

static func getTextureVariant(id: String) -> TextureVariant:
	if(textureVariants.has(id)):
		return textureVariants[id]
	else:
		Log.Printerr("ERROR: texture variant with the id "+str(id)+" wasn't found")
		return null

static func getTextureVariantsIDsOfTypeAndSubType(theType:String, theSubType:String) -> Array:
	if(!textureVariantsByType.has(theType)):
		return []
	if(!textureVariantsByType[theType].has(theSubType)):
		return []
	return textureVariantsByType[theType][theSubType]

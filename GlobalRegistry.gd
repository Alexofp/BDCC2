extends Object
class_name GlobalRegistry

# And so we meet again, GlobalRegistry..

static var wasInit = false

static var sceneCache: Dictionary = {}

static var bodyparts: Dictionary = {}
static var bodypartRefs: Dictionary = {}
static var textureVariants: Dictionary = {}

static func doInit():
	if(wasInit):
		return
	wasInit = true
	registerTextureVariantFolderOnlySubFolders("res://Mesh/Textures/")
	
	registerBodypartsFolder("res://Player/Bodyparts/Body/")
	registerBodypartsFolder("res://Player/Bodyparts/Head/")
	registerBodypartsFolder("res://Player/Bodyparts/Ear/")
	registerBodypartsFolder("res://Player/Bodyparts/Legs/")
	registerBodypartsFolder("res://Player/Bodyparts/Tail/")
	
	print("GlobalRegistry: Registered everything")

static func loadSceneCached(path: String) -> PackedScene:
	if(!sceneCache.has(path)):
		var theScene = load(path)
		if(!(theScene is PackedScene)):
			Log.Printerr("Tried to load a non-scene scene from path "+str(path))
			return null
		sceneCache[path] = theScene
		return theScene
	return sceneCache[path]

static func registerBodypart(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	
	bodyparts[object.id] = loadedClass
	bodypartRefs[object.id] = object

static func registerBodypartsFolder(folder: String):
	var scripts = Util.getScriptsInFolder(folder)
	for scriptPath in scripts:
		registerBodypart(scriptPath)

static func createBodypart(id: String) -> BaseBodypart:
	if(bodyparts.has(id)):
		return bodyparts[id].new()
	else:
		Log.Printerr("ERROR: bodypart with the id "+str(id)+" wasn't found")
		return null

static func getBodyparts():
	return bodypartRefs

static func getBodypartRef(id: String) -> BaseBodypart:
	if(bodypartRefs.has(id)):
		return bodypartRefs[id]
	else:
		Log.Printerr("ERROR: bodypart with the id "+str(id)+" wasn't found")
		return null



static func registerTextureVariant(path: String):
	var loadedClass = load(path)
	var object = loadedClass.new()
	if(object is TextureVariant):
		if(!textureVariants.has(object.textureType)):
			textureVariants[object.textureType] = {}
		if(!textureVariants[object.textureType].has(object.textureSubType)):
			textureVariants[object.textureType][object.textureSubType] = {}
		textureVariants[object.textureType][object.textureSubType][object.id] = object
	elif(object is TextureVariantMany):
		if(!textureVariants.has(object.textureType)):
			textureVariants[object.textureType] = {}
		if(!textureVariants[object.textureType].has(object.textureSubType)):
			textureVariants[object.textureType][object.textureSubType] = {}
		for into in object.textures:
			var textureID = into["id"]
			var textureName = into["name"]
			var texturePath = into["path"]
			var newTextureVariant = TextureVariant.new()
			newTextureVariant.id = textureID
			newTextureVariant.textureName = textureName
			newTextureVariant.texturePath = texturePath
			if(into.has("preview")):
				newTextureVariant.previewTexturePath = into["preview"]
			newTextureVariant.textureType = object.textureType
			newTextureVariant.textureSubType = object.textureSubType
			textureVariants[object.textureType][object.textureSubType][textureID] = newTextureVariant

static func registerTextureVariantFolder(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder, true, true, true)
	for scriptPath in scripts:
		registerTextureVariant(scriptPath)

static func registerTextureVariantFolderOnlySubFolders(folder: String):
	var scripts = Util.getScriptsInFolderSmart(folder, false, true, true)
	for scriptPath in scripts:
		registerTextureVariant(scriptPath)

static func getTextureVariant(textureType, textureSubType, id) -> TextureVariant:
	if(!textureVariants.has(textureType) || !textureVariants[textureType].has(textureSubType) || !textureVariants[textureType][textureSubType].has(id)):
		Log.Printerr("ERROR: texture variant with the id "+str(id)+" wasn't found for type '"+str(textureType)+"' and subtype '"+str(textureSubType)+"'")
		return null
	
	return textureVariants[textureType][textureSubType][id]
	
static func getTextureVariants(textureType, textureSubType) -> Dictionary:
	if(!textureVariants.has(textureType) || !textureVariants[textureType].has(textureSubType)):
		Log.Printerr("ERROR: texture variants with the weren't found for type '"+str(textureType)+"' and subtype '"+str(textureSubType)+"'")
		return {}
		
	return textureVariants[textureType][textureSubType]

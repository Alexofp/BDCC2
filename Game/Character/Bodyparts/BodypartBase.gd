extends GenericPart
class_name BodypartBase

var skinType:String = ""
var skinDataOverride:SkinTypeData

var currentSlot:String = ""

func getBodypartSlots() -> Array:
	return BodypartSlot.getFromType(getBodypartType())

func supportsSlot(slot:String) -> bool:
	return slot in getBodypartSlots()

func getBodypartType() -> String:
	return ""

func getSupportedSkinTypes() -> Dictionary:
	return {}

func getSkinType() -> String:
	if(skinType == ""):
		var theSupported:Dictionary = getSupportedSkinTypes()
		if(!theSupported.is_empty()):
			skinType = theSupported.keys()[0]
	return skinType
#
#func skinTypeSelector() -> Dictionary:
	#var theValues:Array = []
	#var supportedSkinTypes:Dictionary = getSupportedSkinTypes()
	#for skinType in supportedSkinTypes:
		#theValues.append([skinType, SkinType.getName(skinType)])
	#return {
		#name = "Skin type",
		#type = "selector",
		#editors = ["part"],
		#values = theValues,
	#}

func getSkinTypeData() -> SkinTypeData:
	if(skinDataOverride != null):
		return skinDataOverride
	var theSkinType:String = getSkinType()
	if(theSkinType == ""):
		return null
	var theCharacter:BaseCharacter = getCharacter()
	if(theCharacter == null):
		return null
	return theCharacter.getBaseSkinTypeData(theSkinType)

func getCurrentSlot() -> String:
	return currentSlot

func getTextureVariantsPaths() -> Array:
	return []

func getTextureVariantsValues(texType:String, texSubType:String) -> Array:
	var result:Array = []
	
	var texVarIDs:Array = GlobalRegistry.getTextureVariantsIDsOfTypeAndSubType(texType, texSubType)
	
	for texVarID in texVarIDs:
		var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(texVarID)
		if(textureVariant == null):
			continue
		result.append([texVarID, textureVariant.getName()])
		
	return result

func saveNetworkData() -> Dictionary:
	var _data:Dictionary = {}
	
	if(supportsSkinTypes()):
		_data["skinType"] = skinType
		
		if(skinDataOverride):
			_data["skinDataOverride"] = skinDataOverride.saveNetworkData()
		else:
			_data["skinDataOverride"] = null
	
	_data["options"] = saveOptionsData()
	
	return _data

func loadNetworkData(_data:Dictionary):
	if(supportsSkinTypes()):
		skinType = SAVE.loadVar(_data, "skinType", "")
		
		var newSkinDataOverride = SAVE.loadVar(_data, "skinDataOverride", null)
		if(newSkinDataOverride == null || !(newSkinDataOverride is Dictionary)):
			skinDataOverride = null
		else:
			skinDataOverride = SkinTypeData.new()
			skinDataOverride.loadNetworkData(newSkinDataOverride)
	
	loadOptionsData(SAVE.loadVar(_data, "options", {}))

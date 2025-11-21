extends GenericPart
class_name BodypartBase

var skinType:int = SkinType.None
var skinDataOverride:SkinTypeData

var currentSlot:int = -1

func _init():
	super._init()
	if(supportsSkinTypes()):
		skinType = getDefaultSkinType()

func getBodypartSlots() -> Array:
	return BodypartSlot.getFromType(getBodypartType())

func supportsSlot(slot:int) -> bool:
	return slot in getBodypartSlots()

func getBodypartType() -> int:
	return -1

func getDefaultSkinType() -> int:
	var theSupportedSkinTypes := getSupportedSkinTypes()
	if(theSupportedSkinTypes.is_empty()):
		return skinType
	return theSupportedSkinTypes.keys()[0]

func getSupportedSkinTypes() -> Dictionary:
	return {}

func supportsSkinType(_skinType:int) -> bool:
	var theSupportedSkinTypes := getSupportedSkinTypes()
	if(theSupportedSkinTypes.has(_skinType) && theSupportedSkinTypes[_skinType]):
		return true
	return false

func getSkinTypeRaw() -> int:
	return skinType

func getSkinType() -> int:
	if(!supportsSkinTypes()):
		return SkinType.None
	var finalSkinType := skinType
	
	if(finalSkinType == SkinType.None || !supportsSkinType(finalSkinType)):
		finalSkinType = getFirstActualSupportedSkinType()
	elif(finalSkinType == SkinType.Auto && getCurrentSlot() != BodypartSlot.Head):
		var theChar := getCharacter()
		if(theChar):
			var theHeadSkinType := theChar.getSkinTypeOf(BodypartSlot.Head)
			if(SkinType.isActualSkinType(theHeadSkinType) && supportsSkinType(theHeadSkinType)):
				finalSkinType = theHeadSkinType
	if(!SkinType.isActualSkinType(finalSkinType)):
		finalSkinType = SkinType.Fur
	return finalSkinType

func getFirstActualSupportedSkinType(fallbackSkinType:int = SkinType.Fur) -> int:
	var theSupported:Dictionary = getSupportedSkinTypes()
	if(theSupported.is_empty()):
		return fallbackSkinType
	for theSkinType in theSupported.keys():
		if(SkinType.isActualSkinType(theSkinType)):
			return theSkinType
	return fallbackSkinType

#func skinTypeSelector() -> Dictionary:
	#var theValues:Array = []
	#var supportedSkinTypes:Dictionary = getSupportedSkinTypes()
	#for skinType in supportedSkinTypes:
		#theValues.append([skinType, SkinType.getName(skinType)])
	#return {
		#name = "Skin type",
		#type = "selector",
		#editors = [EDITOR_PART],
		#values = theValues,
	#}

func getSkinTypeData() -> SkinTypeData:
	if(skinDataOverride != null):
		return skinDataOverride
	var theSkinType := getSkinType()
	if(theSkinType == SkinType.None):
		return null
	var theCharacter:BaseCharacter = getCharacter()
	if(theCharacter == null):
		return null
	return theCharacter.getBaseSkinTypeData(theSkinType)

func getOptionsFinal() -> Dictionary:
	var theOptions := super.getOptionsFinal()
	if(supportsSkinTypes()):
		var theBetterOptions:Dictionary = {}
		
		var theSupportedSkinTypes := getSupportedSkinTypes()
		var theSupportedSkinValues:Array = []
		for theSkinType in theSupportedSkinTypes:
			var theSkinTypeName := SkinType.getName(theSkinType)
			theSupportedSkinValues.append([theSkinType, theSkinTypeName])
		if(theSupportedSkinTypes.size() > 1):
			theBetterOptions["skinType"] = {
				name = "Skin type",
				type = "selector",
				values = theSupportedSkinValues,
				editors = [EDITOR_PART],
			}
		
		theBetterOptions["skinDataOverride"] = {
			#name = "Pattern",
			type = "skinDataOverride",
			editors = [EDITOR_PART],
		}
		for theOptionID in theOptions:
			theBetterOptions[theOptionID] = theOptions[theOptionID]
		return theBetterOptions
	return theOptions

func setOptionValue(_optionID:String, _value:Variant):
	if(_optionID == "skinDataOverride"):
		if(_value is Dictionary):
			if(_value.is_empty()):
				_value = null
			else:
				var theValue := SkinTypeData.new()
				theValue.loadData(_value)
				_value = theValue
		elif(_value != null):
			assert(false, "BAD SKIN DATA OVERRIDE")
			return
	super.setOptionValue(_optionID, _value)

func getOptionValue(_optionID:String) -> Variant:
	if(_optionID == "skinDataOverride"): # hack?
		if(!skinDataOverride):
			return null
		return skinDataOverride.saveData()
	return get(_optionID)

func getCurrentSlot() -> int:
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

func getDefaultEditorZone() -> int:
	return CharCreatorZone.NOTHING

func supportsPropertyCopyOnBodypartSwitch() -> bool:
	return false

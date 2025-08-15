extends RefCounted
class_name SkinTypeProfile

var skinTypes:Dictionary[int, SkinTypeData] = {}

signal skinTypeChanged(skinType, skinTypeData)

func create(theSkinType:int):
	if(skinTypes.has(theSkinType)):
		return
	var newSkinTypeData := SkinTypeData.new()
	skinTypes[theSkinType] = newSkinTypeData
	skinTypeChanged.emit(theSkinType, newSkinTypeData)

func hasSkinType(_skinType:int) -> bool:
	return skinTypes.has(_skinType)

func remove(theSkinType:int):
	if(!skinTypes.has(theSkinType)):
		return
	skinTypes.erase(theSkinType)
	skinTypeChanged.emit(theSkinType, null)

func setSkinType(_skinType:int, _skinData:SkinTypeData):
	skinTypes[_skinType] = _skinData
	skinTypeChanged.emit(_skinType, _skinData)

func clear():
	for _skinType in skinTypes.keys():
		remove(_skinType)

func getSkinType(_skinType:int) -> SkinTypeData:
	if(!skinTypes.has(_skinType)):
		return null
	return skinTypes[_skinType]

func setColor(_skinType:int, _color:Color):
	if(!skinTypes.has(_skinType)):
		return
	var theSkinTypeData:SkinTypeData = skinTypes[_skinType]
	theSkinTypeData.color = _color
	skinTypeChanged.emit(_skinType, theSkinTypeData)

func saveNetworkData() -> Dictionary:
	var skinTypesData:Dictionary = {}
	for skinType in skinTypes:
		skinTypesData[skinType] = skinTypes[skinType].saveNetworkData()
	return {
		skinTypes = skinTypesData,
	}

func loadNetworkData(_data:Dictionary):
	if(_data.has("skinTypes")):
		clear()
		var skinTypesData:Dictionary = SAVE.loadVar(_data, "skinTypes", {})
		for skinType in skinTypesData:
			var newSkinType:SkinTypeData = SkinTypeData.new()
			if(skinTypesData[skinType] is Dictionary):
				newSkinType.loadNetworkData(skinTypesData[skinType])
			#setBaseSkinTypeData(skinType, newSkinType)
			skinTypes[skinType] = newSkinType
			skinTypeChanged.emit(skinType, newSkinType)
		#triggerUpdateAllSkinTypes()

func saveData() -> Dictionary:
	return saveNetworkData()

func loadData(_data:Dictionary):
	loadNetworkData(_data)

#func makeCopy() -> SkinTypeData:
	#var newSkinData:SkinTypeProfile = SkinTypeProfile.new()
	#newSkinData.color = color
	#return newSkinData

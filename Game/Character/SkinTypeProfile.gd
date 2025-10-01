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

func saveNetworkData() -> Bins:
	var ar:Array = [
		Bins.I8, skinTypes.size(),
	]
	for skinType in skinTypes:
		ar.append_array([Bins.I8, skinType])
		ar.append_array([Bins.BINS, skinTypes[skinType].saveNetworkData()])
	
	return Bins.saveStartEnd(ar)

func loadNetworkData(_data:Bins):
	_data.loadStart()
	clear()
	var theSkinTypesAmount:int = _data.readI8()
	for _i in range(theSkinTypesAmount):
		var skinType:int = _data.readI8()
		var newSkinType:SkinTypeData = SkinTypeData.new()
		newSkinType.loadNetworkData(_data.readBins())
		skinTypes[skinType] = newSkinType
		skinTypeChanged.emit(skinType, newSkinType)
	_data.endLoad()

func saveData() -> Dictionary:
	var skinTypesData:Dictionary = {}
	for skinType in skinTypes:
		skinTypesData[skinType] = skinTypes[skinType].saveData()
	return {
		skinTypes = skinTypesData,
	}

func loadData(_data:Dictionary):
	if(_data.has("skinTypes")):
		clear()
		var skinTypesData:Dictionary = SAVE.loadVar(_data, "skinTypes", {})
		for skinType in skinTypesData:
			var newSkinType:SkinTypeData = SkinTypeData.new()
			if(skinTypesData[skinType] is Dictionary):
				newSkinType.loadData(skinTypesData[skinType])
			#setBaseSkinTypeData(skinType, newSkinType)
			skinTypes[skinType] = newSkinType
			skinTypeChanged.emit(skinType, newSkinType)
		#triggerUpdateAllSkinTypes()

#func makeCopy() -> SkinTypeData:
	#var newSkinData:SkinTypeProfile = SkinTypeProfile.new()
	#newSkinData.color = color
	#return newSkinData

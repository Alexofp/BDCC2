extends DollBasePart
class_name DollPart

#@export var symmetryAttachTo:Array[DollAttachTo] = []

var dollRef:WeakRef
var partRef:WeakRef
var cachedSkinType:int = SkinType.None
var cachedSkinTypeData:SkinTypeData

var cachedExtraPaths:Dictionary[int, String] = {}
var extras:Dictionary[int, DollExtraPart] = {}

func _ready():
	super._ready()

func grabMaterials():
	pass

func onSpawn(_genericType:int, _bodypartSlot:int, _id:String):
	pass

func setDoll(theDoll:Doll):
	if(theDoll == null):
		dollRef = null
		return
	dollRef = weakref(theDoll)

func getDoll() -> Doll:
	if(dollRef == null):
		return null
	return dollRef.get_ref()

func setPart(thePart:GenericPart):
	partRef = weakref(thePart)
	
	#if(thePart is BodypartBase):
		#var bodypartSlot:String = thePart.getCurrentSlot()
		#if(bodypartSlot in [BodypartSlot.LeftEar, BodypartSlot.LeftHorn]):
			#for symAttachTo in symmetryAttachTo:
				#symAttachTo.attachPoint += ".L"
		#if(bodypartSlot in [BodypartSlot.RightEar, BodypartSlot.RightHorn]):
			#for symAttachTo in symmetryAttachTo:
				#symAttachTo.attachPoint += ".R"

func getPart() -> GenericPart:
	if(partRef == null):
		return null
	return partRef.get_ref()

func shouldSubscribeToDollHoleData() -> bool:
	var thePart := getPart()
	if(thePart is BodypartBodyBase):
		return true
	if(thePart is ItemBase):
		var curSlot:int = thePart.currentSlot
		if(curSlot == InventorySlot.UnderwearBottom):
			return true
		if(curSlot == InventorySlot.Bottom):
			return true
		
	return false

func updateDefaultDollHoleData(_data:DollHoleData):
	setBlendshape("BellyBulge", _data.bellyBump)
	setBlendshape("PussyOpenedWide", _data.vagOpen)
	setBlendshape("PussyPull", _data.vagPull)
	setBlendshape("AnusOpenedWide", _data.anusOpen)
	setBlendshape("AnusPull", _data.anusPull)

func applyDollHoleData(_data:DollHoleData):
	updateDefaultDollHoleData(_data)

func applyOption(_optionID:String, _value:Variant):
	pass

func applyOptionFinal(_optionID:String, _value:Variant):
	if(_optionID == "skinType"):
		triggerSkinDataUpdate()
		return
	if(_optionID == "skinDataOverride"):
		triggerSkinDataUpdate()
		return
	
	applyOption(_optionID, _value)
	for slot in extras:
		extras[slot].applyOptionFinal(_optionID, _value)

var isUpdatingSkinData:bool = false
func triggerSkinDataUpdate():
	if(isUpdatingSkinData):
		return
	isUpdatingSkinData = true
	#await get_tree().process_frame
	triggerSkinDataUpdate_DoWork()
	isUpdatingSkinData = false
	
	#triggerSkinDataUpdateActual.call_deferred()

func triggerSkinDataUpdate_DoWork():
	isUpdatingSkinData = false
	var thePart := getPart()
	if(!thePart):
		return
	if(thePart.supportsSkinTypes()):
		var theData:SkinTypeData = thePart.getSkinTypeData()
		if(theData != null):
			applySkinTypeDataFinal(thePart.getSkinType(), theData)

func applyCharOptionFinal(_optionID:String, _value:Variant):
	if(_optionID == CharOption.skinTypes):
		triggerSkinDataUpdate()
	
	applyCharOption(_optionID, _value)
	for slot in extras:
		extras[slot].applyCharOptionFinal(_optionID, _value)

func applyCharOption(_optionID:String, _value:Variant):
	pass

func applySkinTypeDataFinal(_theSkinType:int, _skinTypeData:SkinTypeData):
	cachedSkinType = _theSkinType
	cachedSkinTypeData = _skinTypeData
	applySkinTypeData(_theSkinType, _skinTypeData)

func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	pass

func getSkinData() -> SkinTypeData:
	return cachedSkinTypeData

func getSkinType() -> int:
	return cachedSkinType

func gatherPartFlags(_theFlags:Dictionary):
	pass

func applyPartFlagsFinal(_theFlags:Dictionary):
	applyPartFlags(_theFlags)
	for slot in extras:
		extras[slot].applyPartFlagsFinal(_theFlags)

func applyPartFlags(_theFlags:Dictionary):
	pass

func setPenisTargets(_holeNode:Node3D, _insideNode:Node3D):
	pass

func setExpressionState(_newExpr:int):
	return

func getFaceAnimator() -> FaceAnimator:
	return null

func getPenisHandler() -> PenisHandler:
	return null

func updateBodyMess():
	pass

func getBodyMess() -> FluidsOnBodyProfile:
	return getDoll().getBodyMess()

func getSyncedBodypartSlots() -> Array:
	return []

func applySyncedBodypartOption(_slot:int, _optionID:String, _value:Variant):
	pass

func shouldUpdateAlphaMask() -> bool:
	if(getBodyAlphaMask()):
		return true
	return false

func getBodyAlphaMask() -> Texture2D:
	return null

func updateBodyAlphaMask(_finalAlpha:Texture2D):
	pass

var previewDollMat := preload("res://Mesh/SharedMaterials/Preview/previewDollPartMat.tres")

func prepareForPreview(_previewMaker):
	pass

func previewTextureVariant(_previewMaker, _textureVariant:TextureVariant):
	pass

func getExtraLayerData() -> Dictionary:
	return getDoll().extraLayer

func applyExtraLayerData(_data:Dictionary):
	pass

func getNodeToAttachExtras(_slot:int) -> Node3D:
	return self

func setExtra(_slot:int, _path:String):
	if(_path.is_empty() && !cachedExtraPaths.has(_slot)):
		return
	if(!_path.is_empty() && cachedExtraPaths.has(_slot) && cachedExtraPaths[_slot] == _path):
		return
	clearMeshesCache()
	
	if(extras.has(_slot)):
		extras[_slot].queue_free()
		extras.erase(_slot)
		cachedExtraPaths.erase(_slot)
	if(_path.is_empty()):
		return
	cachedExtraPaths[_slot] = _path
	#var theFuture := ThreadedResourceLoader.loadRequest(_path)
	#var theFuture := ThreadedResourceLoader.loadFuture(_path)
	#await theFuture.requestFinished
	#await theFuture.task_completed
	var thePackedScene:PackedScene = await ThreadedResourceLoader.asyncLoadRequest(_path)# theFuture.getResult()
	if(!thePackedScene):
		Log.Printerr("Failed to spawn part: "+str(_path))
		return
	if(!cachedExtraPaths.has(_slot) || extras.has(_slot) || (cachedExtraPaths.has(_slot) && cachedExtraPaths[_slot] != _path)):
		return
	var theExtraDollScene:DollExtraPart = thePackedScene.instantiate()
	var theNodeToAttachTo := getNodeToAttachExtras(_slot)
	theNodeToAttachTo.add_child(theExtraDollScene)
	theExtraDollScene.setDollPart(self)
	extras[_slot] = theExtraDollScene
	
	var theChar := getDoll().getCharacter()
	if(!theChar):
		return
	
	var thePart := getPart()
	for optionID in thePart.getOptionsFinal():
		theExtraDollScene.applyOptionFinal(optionID, thePart.getOptionValue(optionID))
	
	for syncOptionID in theChar.getSyncOptions():
		theExtraDollScene.applyCharOptionFinal(syncOptionID, theChar.getSyncOptionValue(syncOptionID))
	
	theExtraDollScene.applyPartFlagsFinal(getDoll().cachedPartFlags)

func getShouldersWidth() -> float:
	return 0.0

func getBreastsWigglePhysics() -> float:
	return 0.0

func supportsPenisGirth() -> bool:
	return false

func getPenisGirth() -> float:
	return 1.0

extends Node3D
class_name DollPart

#@export var symmetryAttachTo:Array[DollAttachTo] = []

var dollRef:WeakRef
var partRef:WeakRef
var cachedSkinTypeData:SkinTypeData

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

func getOptionValue(_optionID:String, _default:Variant) -> Variant:
	var thePart := getPart()
	if(thePart == null):
		return _default
	return thePart.getOptionValue(_optionID)

func getBodypartOptionValue(_slot:int, _optionID:String, _default:Variant) -> Variant:
	var thePart := getPart()
	if(thePart == null):
		return _default
	var theChar := thePart.getCharacter()
	if(theChar == null):
		return _default
	var theOtherPart := theChar.getBodypart(_slot)
	if(theOtherPart == null):
		return _default
	var theValue = theOtherPart.getOptionValue(_optionID)
	if(theValue == null):
		return _default
	return theValue

func applyOption(_optionID:String, _value:Variant):
	pass

func getCharValue(_optionID:String, _default:Variant) -> Variant:
	var thePart := getPart()
	if(!thePart):
		return _default
	var theChar := thePart.getCharacter()
	if(!theChar):
		return _default
	return theChar.getSyncOptionValue(_optionID)

func applyCharOption(_optionID:String, _value:Variant):
	pass

func applySkinTypeDataFinal(_skinTypeData:SkinTypeData):
	cachedSkinTypeData = _skinTypeData
	applySkinTypeData(_skinTypeData)

func applySkinTypeData(_skinTypeData:SkinTypeData):
	pass

#TODO: Cache this?
func getMeshes() -> Array:
	var result:Array = []
	for child in get_children():
		if(child is MeshInstance3D):
			result.append(child)
		elif(child is MarkerBlendshaped):
			result.append(child)
		result.append_array(getMeshesSub(child))
	return result

func getMeshesSub(theNode:Node) -> Array:
	var result:Array = []
	for child in theNode.get_children():
		if(child is MeshInstance3D):
			result.append(child)
		elif(child is MarkerBlendshaped):
			result.append(child)
		result.append_array(getMeshesSub(child))
	return result

func setBlendshape(_id:String, _value:float):
	for meshA in getMeshes():
		if(meshA is MeshInstance3D):
			var mesh:MeshInstance3D = meshA
			var indx:int = mesh.find_blend_shape_by_name(_id)
			if(indx >= 0):
				mesh.set_blend_shape_value(indx, _value)
		if(meshA is MarkerBlendshaped):
			meshA.setBlendshape(_id, _value)

func getSkinData() -> SkinTypeData:
	return cachedSkinTypeData

func gatherPartFlags(_theFlags:Dictionary):
	pass

func applyPartFlags(_theFlags:Dictionary):
	pass

func addLayersToTexture(layeredTexture:MyLayeredTexture, layers:Array):
	for layerEntry in layers:
		var texVarID:String = layerEntry["id"] if layerEntry.has("id") else ""
		
		var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(texVarID)
		if(textureVariant == null):
			continue
		
		if(textureVariant.pathColormask != ""):
			layeredTexture.addColorMaskLayer(textureVariant.pathColormask, layerEntry["colorR"] if layerEntry.has("colorR") else Color.BLACK, layerEntry["colorG"] if layerEntry.has("colorG") else Color.BLACK, layerEntry["colorB"] if layerEntry.has("colorB") else Color.BLACK)
		elif(textureVariant.pathTexture != ""):
			layeredTexture.addSimpleLayer(textureVariant.pathTexture, layerEntry["colorR"] if layerEntry.has("colorR") else Color.BLACK)

func applyColormaskPatternToMyMat(theMat:MyMasterBodyMat, theValue:Dictionary):
	if(!theMat):
		return
	var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(theValue["pattern"] if theValue.has("pattern") else "")
	if(textureVariant == null):
		theMat.set_shader_parameter("texture_color_mask", null)
	else:
		theMat.set_shader_parameter("texture_color_mask", textureVariant.loadColormask())
	
	theMat.set_shader_parameter("color_mask_r", theValue["colorR"] if theValue.has("colorR") else Color.WHITE)
	theMat.set_shader_parameter("color_mask_g", theValue["colorG"] if theValue.has("colorG") else Color.WHITE)
	theMat.set_shader_parameter("color_mask_b", theValue["colorB"] if theValue.has("colorB") else Color.WHITE)
	
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

func updateThicknessBody(_optionID:String = ""):
	if(!(_optionID in ["", CharOption.thickness, CharOption.weightDistribution, CharOption.muscles])):
		return
	var theThickness:float = getCharValue(CharOption.thickness, 1.0)
	var theWeightDistribution:float = getCharValue(CharOption.weightDistribution, 0.0)

	var thinValue:float = max(1.0-theThickness, 0.0)
	var thickValue:float = max(0.0, theThickness-1.0)

	setBlendshape("ThinVery", thinValue * max(1.0 - theWeightDistribution, 0.0))
	setBlendshape("BodySize", -thinValue * max(theWeightDistribution, 0.0))
	setBlendshape("ThickFurry", thickValue * max(1.0 - theWeightDistribution, 0.0))
	setBlendshape("Fat", thickValue * max(theWeightDistribution, 0.0))
	setBlendshape("Muscles", getCharValue(CharOption.muscles, 1.0))
	
func triggerDollPartFlagsUpdate():
	var theDoll := getDoll()
	if(theDoll):
		theDoll.triggerDollPartFlagsUpdate()
	
func triggerAlphaMaskUpdate():
	var theDoll := getDoll()
	if(theDoll):
		theDoll.triggerAlphaMaskUpdate()

func getSyncedBodypartSlots() -> Array:
	return []

func applySyncedBodypartOption(_slot:int, _optionID:String, _value:Variant):
	pass

func updateBreasts(_optionID:String, _value:Variant):
	if(_optionID == "breasts"):
		setBlendshape("BreastsHuge", max(0.0, (_value-1.0)/3.0))
		setBlendshape("BreastsFlat", clamp(1.0-_value, 0.0, 1.0))
	if(_optionID == "breastsCleavage"):
		setBlendshape("BreastsCleavage", _value if !getCachedPartFlag("ForceBreastCleavage", false) else 1.0)
	if(_optionID == "nippleShape"):
		setBlendshape("NipplesNormal", max(1.0-_value, 0.0))
		setBlendshape("NipplesAnime", max(_value, 0.0))

func updateBreastsCleavage(_value:Variant):
	var newVal:float = _value
	if(getCachedPartFlag("ForceBreastCleavage", false)):
		newVal = 1.0
	if(getCachedPartFlag("ForceZeroBreastCleavage", false)):
		newVal = 0.0
	setBlendshape("BreastsCleavage", newVal)

func getCachedPartFlag(_id:String, _default:Variant) -> Variant:
	var theDoll := getDoll()
	if(!theDoll):
		return _default
	return theDoll.getCachedPartFlag(_id, _default)

func getBodyAlphaMask() -> Texture2D:
	return null

func updateBodyAlphaMask(_finalAlpha:Texture2D):
	pass

func onSpawn(_genericType:int, _bodypartSlot:int, _id:String):
	pass

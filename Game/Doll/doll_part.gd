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

func applyOption(_optionID:String, _value:Variant):
	pass

func applySkinTypeDataFinal(_skinTypeData:SkinTypeData):
	cachedSkinTypeData = _skinTypeData
	applySkinTypeData(_skinTypeData)

func applySkinTypeData(_skinTypeData:SkinTypeData):
	pass

func getMeshes() -> Array:
	var result:Array = []
	for child in get_children():
		if(child is MeshInstance3D):
			result.append(child)
		result.append_array(getMeshesSub(child))
	return result

func getMeshesSub(theNode:Node) -> Array:
	var result:Array = []
	for child in theNode.get_children():
		if(child is MeshInstance3D):
			result.append(child)
		result.append_array(getMeshesSub(child))
	return result

func setBlendshape(_id:String, _value:float):
	for meshA in getMeshes():
		var mesh:MeshInstance3D = meshA
		var indx:int = mesh.find_blend_shape_by_name(_id)
		if(indx >= 0):
			mesh.set_blend_shape_value(indx, _value)

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

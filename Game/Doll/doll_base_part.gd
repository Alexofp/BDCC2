extends Node3D
class_name DollBasePart

func _ready():
	grabMaterials()

func grabMaterials():
	pass

func getDoll() -> Doll:
	return null

func getPart() -> GenericPart:
	return null

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

func applyOptionFinal(_optionID:String, _value:Variant):
	applyOption(_optionID, _value)

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

func applyCharOptionFinal(_optionID:String, _value:Variant):
	applyCharOption(_optionID, _value)

func applyCharOption(_optionID:String, _value:Variant):
	pass

func getMeshes() -> Array:
	var result:Array = []
	for child in get_children():
		if((child is DollPart) || (child is DollExtraPart)):
			continue
		if(child is MeshInstance3D):
			result.append(child)
		elif(child is MarkerBlendshaped):
			result.append(child)
		result.append_array(getMeshesSub(child))
	return result

func getMeshesSub(theNode:Node) -> Array:
	var result:Array = []
	for child in theNode.get_children():
		if((child is DollPart) || (child is DollExtraPart)):
			continue
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

func applyPartFlagsFinal(_theFlags:Dictionary):
	applyPartFlags(_theFlags)

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

func applyColormaskPatternToMyMat(theMat:ShaderMaterial, theValue:Dictionary):
	if(!theMat):
		return
	var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(theValue["pattern"] if theValue.has("pattern") else "") if (theValue["pattern"] != "") else null
	if(textureVariant == null):
		theMat.set_shader_parameter("texture_color_mask", null)
	else:
		theMat.set_shader_parameter("texture_color_mask", textureVariant.loadColormask())
	
	theMat.set_shader_parameter("color_mask_r", theValue["colorR"] if theValue.has("colorR") else Color.WHITE)
	theMat.set_shader_parameter("color_mask_g", theValue["colorG"] if theValue.has("colorG") else Color.WHITE)
	theMat.set_shader_parameter("color_mask_b", theValue["colorB"] if theValue.has("colorB") else Color.WHITE)
	

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


func updateBreasts(_optionID:String, _value:Variant):
	if(_optionID == "breasts"):
		setBlendshape("BreastsHuge", max(0.0, (_value-1.0)/3.0))
		setBlendshape("BreastsFlat", clamp(1.0-_value, 0.0, 1.0))
	elif(_optionID == "breastsCleavage"):
		setBlendshape("BreastsCleavage", _value if !getCachedPartFlag("ForceBreastCleavage", false) else 1.0)
	elif(_optionID == "nippleShape"):
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

func applyHairMatOption(_hairMat:ShaderMaterial, _optionID:String, _value:Variant):
	if(_hairMat != null):
		if(_optionID == "colorRoot"):
			_hairMat.set_shader_parameter("root_color", _value)
		elif(_optionID == "shading"):
			_hairMat.set_shader_parameter("ambient_occlusion", _value)
		elif(_optionID == "colorTip"):
			_hairMat.set_shader_parameter("tip_color", _value)
			
			var newCol:Color = _value
			newCol.s = clamp(newCol.s*0.2, 0.0, 1.0)
			newCol.v = max(min(0.7, newCol.v), 0.5)
			_hairMat.set_shader_parameter("primary_color", newCol)
			_hairMat.set_shader_parameter("secondary_color", Color.BLACK)
		elif(_optionID == "pattern"):
			applyColormaskPatternToMyMat(_hairMat, _value)

func applyEyeOptions(theMat:ShaderMaterial, _optionID:String, theValue:Variant):
	if(theMat != null):
		if(_optionID == "eyes"):
			var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(theValue["pattern"] if theValue.has("pattern") else "") if (theValue["pattern"] != "") else null
			if(textureVariant == null):
				theMat.set_shader_parameter("texture_color_mask", null)
			else:
				theMat.set_shader_parameter("texture_color_mask", textureVariant.loadColormask())
			
			theMat.set_shader_parameter("colorR", theValue["colorR"] if theValue.has("colorR") else Color.WHITE)
			theMat.set_shader_parameter("colorG", theValue["colorG"] if theValue.has("colorG") else Color.WHITE)
			theMat.set_shader_parameter("colorB", theValue["colorB"] if theValue.has("colorB") else Color.WHITE)

func applyMouthOptions(_mouthMat:ShaderMaterial, _optionID:String, _value:Variant):
	if(_mouthMat != null):
		if(_optionID == "mouthColor"):
			_mouthMat.set_shader_parameter("color_mask_r", _value)
		elif(_optionID == "tongueColor"):
			_mouthMat.set_shader_parameter("color_mask_g", _value)
		elif(_optionID == "teethColor"):
			_mouthMat.set_shader_parameter("color_mask_b", _value)

extends Node3D
class_name DollBasePart

var cachedMeshes:Array[Node]

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
	if(!cachedMeshes.is_empty()):
		return cachedMeshes
	
	var result:Array[Node] = []
	for child in get_children():
		if((child is DollPart) || (child is DollExtraPart)):
			continue
		if(child is MeshInstance3D):
			result.append(child)
		elif(child is MarkerBlendshaped):
			result.append(child)
		result.append_array(getMeshesSub(child))
	
	cachedMeshes = result
	return result

func clearMeshesCache():
	cachedMeshes.clear()

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
			layeredTexture.addColorMaskLayer(textureVariant.pathColormask, layerEntry["r"] if layerEntry.has("r") else Color.BLACK, layerEntry["g"] if layerEntry.has("g") else Color.BLACK, layerEntry["b"] if layerEntry.has("b") else Color.BLACK)
		elif(textureVariant.pathTexture != ""):
			if(textureVariant.flags.has("rect")):
				var theRect:Array = textureVariant.flags["rect"]
				layeredTexture.addSimpleLayerAt(textureVariant.pathTexture, layerEntry["r"] if layerEntry.has("r") else Color.BLACK, Vector2(theRect[0], theRect[1]), Vector2(theRect[2], theRect[3]))
			else:
				layeredTexture.addSimpleLayer(textureVariant.pathTexture, layerEntry["r"] if layerEntry.has("r") else Color.BLACK)

func addLayersToTextureNew(layeredTexture:MyLayeredTextureNew, layers:Array):
	for layerEntry in layers:
		var texVarID:String = layerEntry["id"] if layerEntry.has("id") else ""
		
		var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(texVarID)
		if(textureVariant == null):
			continue
		
		if(textureVariant.pathColormask != ""):
			layeredTexture.addColorMaskLayer(textureVariant.pathColormask, layerEntry["r"] if layerEntry.has("r") else Color.BLACK, layerEntry["g"] if layerEntry.has("g") else Color.BLACK, layerEntry["b"] if layerEntry.has("b") else Color.BLACK)
		elif(textureVariant.pathTexture != ""):
			if(textureVariant.flags.has("rect")):
				var theRect:Array = textureVariant.flags["rect"]
				layeredTexture.addSimpleLayerAt(textureVariant.pathTexture, layerEntry["r"] if layerEntry.has("r") else Color.BLACK, Vector2(theRect[0], theRect[1]), Vector2(theRect[2], theRect[3]))
			else:
				layeredTexture.addSimpleLayer(textureVariant.pathTexture, layerEntry["r"] if layerEntry.has("r") else Color.BLACK)

func applyColormaskPatternToMyMat(theMat:ShaderMaterial, theValue:Dictionary):
	if(!theMat):
		return
	var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(theValue["id"] if theValue.has("id") else "") if (theValue.has("id") && theValue["id"] != "") else null
	if(textureVariant == null):
		theMat.set_shader_parameter("texture_color_mask", null)
	else:
		theMat.set_shader_parameter("texture_color_mask", textureVariant.loadColormask())
	
	theMat.set_shader_parameter("color_mask_r", theValue["r"] if theValue.has("r") else Color.WHITE)
	theMat.set_shader_parameter("color_mask_g", theValue["g"] if theValue.has("g") else Color.WHITE)
	theMat.set_shader_parameter("color_mask_b", theValue["b"] if theValue.has("b") else Color.WHITE)
	

func updateThicknessBody(_optionID:String = ""):
	if(!(_optionID in ["", CharOption.bodySize, CharOption.pregnantTest, CharOption.thickness, CharOption.chubbyness, CharOption.buttSize, CharOption.smoothBody, CharOption.muscles])):
		return
	var theThickness:float = getCharValue(CharOption.thickness, 1.0)
	var chubbyness:float = getCharValue(CharOption.chubbyness, 0.0)

	setBlendshape("Thin", maxf(1.0-theThickness, 0.0))
	setBlendshape("Thick", maxf(theThickness-1.0, 0.0))
	setBlendshape("Chubby", chubbyness)
	setBlendshape("ButtSize", getCharValue(CharOption.buttSize, 0.0))
	setBlendshape("BodySmooth", getCharValue(CharOption.smoothBody, 0.0))
	setBlendshape("BodyBigger", getCharValue(CharOption.bodySize, 0.0))
	setBlendshape("Muscles", getCharValue(CharOption.muscles, 1.0))
	setBlendshape("Pregnant", getCharValue(CharOption.pregnantTest, 1.0))
	
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
		setBlendshape("BreastsHuge", maxf(0.0, (_value-1.0)/3.0))
		setBlendshape("BreastsFlat", clamp(1.0-_value, 0.0, 1.0))
	elif(_optionID == "breastsCleavage"):
		setBlendshape("BreastsCleavage", _value if !getCachedPartFlag("ForceBreastCleavage", false) else 1.0)
	elif(_optionID == "nippleShape"):
		setBlendshape("NipplesNormal", maxf(1.0-_value, 0.0))
		setBlendshape("NipplesAnime", maxf(_value, 0.0))

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
		elif(_optionID == "shine"):
			_hairMat.set_shader_parameter("specular_scale", _value)
		elif(_optionID == "colorTip"):
			_hairMat.set_shader_parameter("tip_color", _value)
			
			var newCol:Color = _value
			newCol.s = clamp(newCol.s*0.2, 0.0, 1.0)
			newCol.v = maxf(minf(0.7, newCol.v), 0.5)
			_hairMat.set_shader_parameter("primary_color", newCol)
			_hairMat.set_shader_parameter("secondary_color", Color.BLACK)
		elif(_optionID == "pattern"):
			applyColormaskPatternToMyMat(_hairMat, _value)

func applyEyeOptions(eyesNode:MeshInstance3D, _optionID:String, theValue:Variant):
	if(_optionID == "eyes"):
		var theMat:ShaderMaterial = eyesNode.get_surface_override_material(0)
		
		if(theMat != null):
			var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(theValue["id"] if theValue.has("id") else "") if (theValue.has("id") && theValue["id"] != "") else null
			if(textureVariant == null):
				theMat.set_shader_parameter("texture_color_mask", null)
			else:
				theMat.set_shader_parameter("texture_color_mask", textureVariant.loadColormask())
			
			theMat.set_shader_parameter("colorR", theValue["r"] if theValue.has("r") else Color.WHITE)
			theMat.set_shader_parameter("colorG", theValue["g"] if theValue.has("g") else Color.WHITE)
			theMat.set_shader_parameter("colorB", theValue["b"] if theValue.has("b") else Color.WHITE)
	
		if(!theValue.has("id2")):
			eyesNode.set_surface_override_material(1, theMat)
		else:
			var theMat2:ShaderMaterial = theMat.duplicate()
			eyesNode.set_surface_override_material(1, theMat2)
			
			if(theMat2 != null):
				var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(theValue["id2"] if theValue.has("id2") else "") if (theValue.has("id2") && theValue["id2"] != "") else null
				if(textureVariant == null):
					theMat2.set_shader_parameter("texture_color_mask", null)
				else:
					theMat2.set_shader_parameter("texture_color_mask", textureVariant.loadColormask())
				
				theMat2.set_shader_parameter("colorR", theValue["r2"] if theValue.has("r2") else Color.WHITE)
				theMat2.set_shader_parameter("colorG", theValue["g2"] if theValue.has("g2") else Color.WHITE)
				theMat2.set_shader_parameter("colorB", theValue["b2"] if theValue.has("b2") else Color.WHITE)
	
func applyMouthOptions(_mouthMat:ShaderMaterial, _optionID:String, _value:Variant):
	if(_mouthMat != null):
		if(_optionID == "mouthColor"):
			_mouthMat.set_shader_parameter("color_mask_r", _value)
		elif(_optionID == "tongueColor"):
			_mouthMat.set_shader_parameter("color_mask_g", _value)
		elif(_optionID == "teethColor"):
			_mouthMat.set_shader_parameter("color_mask_b", _value)

func applyBrowOptions(_browMat:ShaderMaterial, _optionID:String, _value:Variant):
	if(_browMat != null):
		if(_optionID == "brows"):
			applyColormaskPatternToMyMat(_browMat, _value)

func applyEyelashesOptions(_lashesMat:ShaderMaterial, _optionID:String, _value:Variant):
	if(_lashesMat != null):
		if(_optionID == "eyelashes"):
			applyColormaskPatternToMyMat(_lashesMat, _value)

extends DollPart

var breastWigglePhysics:float = 1.0

@onready var body: MeshInstance3D = %Body
@onready var digi_legs: MeshInstance3D = %DigiLegs
@onready var planti_legs: MeshInstance3D = %PlantiLegs
@onready var neck_connector: MeshInstance3D = %NeckConnector
@onready var neck_connector_furry: MeshInstance3D = %NeckConnectorFurry
@onready var hand_pads: MeshInstance3D = %HandPads
var bodyMat:ShaderMaterial
var handPadsMat:ShaderMaterial
var nippleMat:ShaderMaterial
var clawMat:ShaderMaterial
var toeClawMat:ShaderMaterial
var toeNailsMat:ShaderMaterial
var hindPawPadsMat:ShaderMaterial
var genitalsMat:ShaderMaterial
var spadeMat:ShaderMaterial
var pubicHairMat:ShaderMaterial

@onready var body_layered_texture: MyLayeredTexture = %BodyLayeredTexture
#@onready var body_layered_texture: MyLayeredTextureNew = %BodyLayeredTexture

@onready var randomCumScroll:float = RNG.randfRange(0.0, 100.0)
@onready var cum_layer: MyLayeredTexture = %CumLayer
@onready var nipples: MeshInstance3D = %Nipples
@onready var male_crotch: MeshInstance3D = %MaleCrotch
@onready var female_crotch: MeshInstance3D = %FemaleCrotch
@onready var female_crotch_spade: MeshInstance3D = %FemaleCrotchSpade
@onready var nipple_l: Node3D = %NippleL
@onready var nipple_r: Node3D = %NippleR
@onready var pubic_hair: MeshInstance3D = %PubicHair
@onready var flat_crotch: MeshInstance3D = %FlatCrotch
@onready var clit_point: DollAttachPoint = %ClitPoint
@onready var clit_marker: MarkerBlendshaped = %ClitMarker
@onready var body_nails: MeshInstance3D = %BodyNails
@onready var digi_legs_claws: MeshInstance3D = %DigiLegsClaws
@onready var digi_legs_pads: MeshInstance3D = %DigiLegsPads
@onready var planti_legs_nails: MeshInstance3D = %PlantiLegsNails

@onready var skeleton_3d: Skeleton3D = %Skeleton3D

const FUR_BODY_SMART_EXTRA_LAYER_MAT = preload("res://Mesh/Parts/Body/FeminineBody/FurBodySmartExtraLayerMat.tres")
const FUR_BODY_SMART_MAT = preload("res://Mesh/Parts/Body/FeminineBody/FurBodySmartMat.tres")
const SKIN_BODY_SMART_EXTRA_LAYER_MAT = preload("res://Mesh/Parts/Body/FeminineBody/SkinBodySmartExtraLayerMat.tres")
const SKIN_BODY_SMART_MAT = preload("res://Mesh/Parts/Body/FeminineBody/SkinBodySmartMat.tres")

var bodyAlphaMask:Texture2D

func grabMaterials():
	bodyMat = body.get_surface_override_material(0)
	clawMat = body_nails.get_surface_override_material(0)
	handPadsMat = hand_pads.get_surface_override_material(0)
	nippleMat = nipples.get_surface_override_material(0)
	toeClawMat = digi_legs_claws.get_surface_override_material(0)
	toeNailsMat = planti_legs_nails.get_surface_override_material(0)
	hindPawPadsMat = digi_legs_pads.get_surface_override_material(0)
	genitalsMat = female_crotch.get_surface_override_material(1)
	spadeMat = female_crotch_spade.get_surface_override_material(3)
	pubicHairMat = pubic_hair.get_surface_override_material(0)

func setBodyMat(_mat:ShaderMaterial):
	_mat = _mat.duplicate()
	bodyMat = _mat
	body.set_surface_override_material(0, _mat)
	digi_legs.set_surface_override_material(0, _mat)
	female_crotch.set_surface_override_material(0, _mat)
	female_crotch_spade.set_surface_override_material(0, _mat)
	male_crotch.set_surface_override_material(0, _mat)
	neck_connector.set_surface_override_material(0, _mat)
	neck_connector_furry.set_surface_override_material(0, _mat)
	planti_legs.set_surface_override_material(0, _mat)
	flat_crotch.set_surface_override_material(0, _mat)
	if(bodyMat):
		bodyMat.set_shader_parameter("texture_alpha", bodyAlphaMask)

func updateThickness():
	updateThicknessBody()

func applyCharOption(_optionID:String, _value:Variant):
	updateThicknessBody(_optionID)

func applyOption(_optionID:String, _value:Variant):
	updateBreasts(_optionID, _value, self)
	
	if(_optionID == "claws"):
		setBlendshape("Claws", _value)
	if(_optionID == "clawsColor"):
		if(clawMat):
			clawMat.set_shader_parameter("albedo", _value)
	if(_optionID == "handPads"):
		hand_pads.visible = _value
	if(_optionID == "handPadsColor"):
		if(handPadsMat):
			handPadsMat.set_shader_parameter("albedo", _value)
	if(_optionID == "toeClawColor"):
		if(toeClawMat):
			toeClawMat.set_shader_parameter("albedo", _value)
		if(toeNailsMat):
			toeNailsMat.set_shader_parameter("albedo", _value)
	if(_optionID == "hindPawPadColor"):
		if(hindPawPadsMat):
			hindPawPadsMat.set_shader_parameter("albedo", _value)
	if(_optionID == "nipples"):
		applyColormaskPatternToMyMat(nippleMat, _value)
	if(_optionID == "pubicHair"):
		applyColormaskPatternToMyMat(pubicHairMat, _value)
	if(_optionID == "legType"):
		var _isDigi:bool = (_value == "digi")
		var _isPlanti:bool = (_value == "planti")
		digi_legs.visible = _isDigi
		digi_legs_claws.visible = _isDigi
		digi_legs_pads.visible = _isDigi
		planti_legs.visible = _isPlanti
		planti_legs_nails.visible = _isPlanti
	if(_optionID == "bodyLayers"):
		triggerUpdateBodyTexture()
	if(_optionID == "anusColor"):
		triggerUpdateBodyTexture()
		genitalsMat.set_shader_parameter("color_mask_g", _value)
	if(_optionID == "anusInColor"):
		genitalsMat.set_shader_parameter("color_mask_b", _value)
	if(_optionID == "vaginaColor"):
		genitalsMat.set_shader_parameter("albedo", _value)
		spadeMat.set_shader_parameter("albedo", _value)
	if(_optionID == "vaginaInColor"):
		genitalsMat.set_shader_parameter("color_mask_r", _value)
		spadeMat.set_shader_parameter("color_mask_r", _value)
	if(_optionID == "breasts"):
		calcBreastPhysics(_value)
		getDoll().setBreastWiggleMod(breastWigglePhysics)
	if(_optionID == "vagina"):
		updateCrotch()
		triggerDollPartFlagsUpdate()
	if(_optionID == "vaginaType"):
		updateCrotch()
	if(_optionID == "vaginaSize"):
		updateCrotch()
	if(_optionID == "nipplePiercing"):
		var theVal:String = _value[0] if _value.size() > 0 else ""
		if(theVal == "p1"):
			setExtra(0, "res://Mesh/Parts/Util/Piercings/NippleDumbbell/nipple_dumbbell.tscn")
			setExtra(1, "res://Mesh/Parts/Util/Piercings/NippleDumbbell/nipple_dumbbell.tscn")
		elif(theVal == "p2"):
			setExtra(0, "res://Mesh/Parts/Util/Piercings/NippleSpikes/nipple_spikes.tscn")
			setExtra(1, "res://Mesh/Parts/Util/Piercings/NippleSpikes/nipple_spikes.tscn")
		elif(theVal == "p3"):
			setExtra(0, "res://Mesh/Parts/Util/Piercings/NippleCross/nipple_cross.tscn")
			setExtra(1, "res://Mesh/Parts/Util/Piercings/NippleCross/nipple_cross.tscn")
		elif(theVal == "p4"):
			setExtra(0, "res://Mesh/Parts/Util/Piercings/NippleRingBall/nipple_ring_ball.tscn")
			setExtra(1, "res://Mesh/Parts/Util/Piercings/NippleRingBall/nipple_ring_ball.tscn")
		else:
			setExtra(0, "")
			setExtra(1, "")
	if(_optionID == "clitPiercing"):
		var theVal:String = _value[0] if _value.size() > 0 else ""
		if(theVal == "ring"):
			setExtra(2, "res://Mesh/Parts/Util/Piercings/ClitRing/clit_ring.tscn")
		elif(theVal == "bell"):
			setExtra(2, "res://Mesh/Parts/Util/Piercings/ClitBell/clit_bell.tscn")
		else:
			setExtra(2, "")

func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	updateSkinEverything()

const HUMAN_SKIN_COLOR := "res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySculpt_low_Body_BaseColor.png"
const HUMAN_SKIN_NORMAL = preload("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySculpt_low_Body_Normal.png")
const HUMAN_SKIN_ORM = preload("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySculpt_low_Body_ORM.png")

const FUR_SKIN_COLOR := "res://Mesh/Parts/Body/FeminineBody/Textures/Fur/MyBodySculpt_low_Body_BaseColor.png"
const FUR_SKIN_NORMAL = preload("res://Mesh/Parts/Body/FeminineBody/Textures/Fur/MyBodySculpt_low_Body_Normal.png")
const FUR_SKIN_ORM = preload("res://Mesh/Parts/Body/FeminineBody/Textures/Fur/MyBodySculpt_low_Body_ORM.png")

func applyNormalORMTextures():
	var _skinType := getSkinType()
	if(_skinType == SkinType.HumanSkin):
		bodyMat.set_shader_parameter("texture_normal", HUMAN_SKIN_NORMAL)
		bodyMat.set_shader_parameter("texture_orm", HUMAN_SKIN_ORM)
	elif(_skinType == SkinType.Fur):
		bodyMat.set_shader_parameter("texture_normal", FUR_SKIN_NORMAL)
		bodyMat.set_shader_parameter("texture_orm", FUR_SKIN_ORM)

func updateSkinEverything():
	if(bodyMat == null):
		return
		
	#const ignoreUniforms = ["albedo", "texture_mess_mask", "texture_alpha"]
	
	updateSelectedBodyMat()
	applyNormalORMTextures()
	
	#bodyMat.set_shader_parameter("albedo", _skinTypeData.color)
	bodyMat.set_shader_parameter("albedo", Color.WHITE)
	bodyMat.set_shader_parameter("messScroll", randomCumScroll)
	triggerUpdateBodyTexture()
	updateBodyMess()
	
	var _extraLayerData := getExtraLayerData()
	if(!_extraLayerData.is_empty()):
		#bodyMat.extraLayer = false
		bodyMat.set_shader_parameter("extra_albedo", _extraLayerData["color"])
		bodyMat.set_shader_parameter("texture_extra_albedo", _extraLayerData["albedo"])
		bodyMat.set_shader_parameter("texture_extra_normal", _extraLayerData["normal"])
		bodyMat.set_shader_parameter("texture_extra_orm", _extraLayerData["orm"])
		bodyMat.set_shader_parameter("extra_rim", _extraLayerData["rim"])
		bodyMat.set_shader_parameter("extra_rim_tint", _extraLayerData["rim_tint"])
	#if(!bodyMat.rimlight):
	#	bodyMat.rimlight = true
	#	bodyMat.set_shader_parameter("rim", 0.0)
	#bodyMat.extraLayer = true

	#applyExtraLayerData(getDoll().getFinalExtraLayerData())

var isUpdatingBodyTexture:bool = false
func triggerUpdateBodyTexture():
	if(isUpdatingBodyTexture):
		return
	isUpdatingBodyTexture = true
	await get_tree().process_frame
	isUpdatingBodyTexture = false
	updateBodyTexture()

func addBodyTextureLayers():
	var theSkinData:SkinTypeData = getSkinData()
	if(theSkinData == null):
		return
	var theSkinType := getSkinType()
	
	body_layered_texture.clearLayers()
	
	if(theSkinType == SkinType.Fur):
		body_layered_texture.addSimpleLayer(FUR_SKIN_COLOR, theSkinData.color)
	if(theSkinType == SkinType.HumanSkin):
		#body_layered_texture.addSimpleLayer(HUMAN_SKIN_COLOR, theSkinData.color)
		#body_layered_texture.addSimpleLayer(HUMAN_SKIN_COLOR, Color.WHITE)
		body_layered_texture.addSimpleLayer("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/skinwhite.png", theSkinData.color)
		var colorDark:Color = theSkinData.color
		colorDark.v *= 0.5678
		colorDark.s = minf(1.0, colorDark.s*4.0)
		colorDark.h += 0.01
		var colorLight:Color = theSkinData.color
		colorLight.v = minf(1.0, colorLight.v*1.3)
		colorLight.s *= 0.5985
		colorLight.h += 0.03
		var colorHighlight:Color = theSkinData.color
		colorHighlight.v = minf(1.0, colorHighlight.v*3.0)
		colorHighlight.s *= 0.1
		colorHighlight.h += 0.0
		body_layered_texture.addColorMaskLayer("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySculpt_low_Body_BaseColor.png", colorHighlight, colorLight, colorDark)

func updateBodyTexture():
	var theSkinData:SkinTypeData = getSkinData()
	if(theSkinData == null):
		return
	addBodyTextureLayers()
	addLayersToTexture(body_layered_texture, getOptionValue("bodyLayers", []))

	var anusColor:Color = getOptionValue("anusColor", Color.RED)
	body_layered_texture.addSimpleLayerAt(preload("res://Mesh/Parts/Body/FeminineBody/Textures/Genitals/AnusL.png"), anusColor, Vector2(322.0/2048.0, 747.0/2048.0), Vector2(0.03125, 0.03125))
	body_layered_texture.addSimpleLayerAt(preload("res://Mesh/Parts/Body/FeminineBody/Textures/Genitals/AnusR.png"), anusColor, Vector2(1662.0/2048.0, 747.0/2048.0), Vector2(0.03125, 0.03125))

	bodyMat.set_shader_parameter("texture_albedo", body_layered_texture.getTexture())
	#bodyMat.set_shader_parameter("freshnel_mod", 0.15)
	#bodyMat.set_shader_parameter("emission_energy", 0.01)
	
func gatherPartFlags(_theFlags:Dictionary):
	if(getOptionValue("vagina", false)):
		_theFlags["SmallerPenisBulge"] = true

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HideNipples") && _theFlags["HideNipples"]):
		nipples.visible = false
	else:
		nipples.visible = true
		
	if(_theFlags.has("HumanNeck") && _theFlags["HumanNeck"]):
		neck_connector.visible = true
		neck_connector_furry.visible = false
	else:
		neck_connector.visible = false
		neck_connector_furry.visible = true
	if(_theFlags.has("HumanNeckMale") && _theFlags["HumanNeckMale"]):
		setBlendshape("MaleNeck", 1.0)
	else:
		setBlendshape("MaleNeck", 0.0)
	updateBreastsCleavage(getOptionValue("breastsCleavage", 0.0))
	updateCrotch()
	
func _on_body_layered_texture_on_texture_updated(_newTexture: Texture2D) -> void:
	if(bodyMat):
		bodyMat.set_shader_parameter("texture_albedo", _newTexture)

func updateBodyMess():
	var _mess:= getBodyMess()
	if(!_mess):
		return
	_mess.updateLayeredTexture(cum_layer)

func _on_cum_layer_on_texture_updated(newTexture: Variant) -> void:
	if(bodyMat):
		bodyMat.set_shader_parameter("texture_mess_mask", newTexture)

func updateBodyAlphaMask(_finalAlpha:Texture2D):
	if(bodyMat):
		bodyMat.set_shader_parameter("texture_alpha", _finalAlpha)
	bodyAlphaMask = _finalAlpha

func prepareForPreview(_previewMaker):
	#bodyMat.copyFrom(previewDollMat)
	setBodyMat(previewDollMat)
	nipples.visible = false
	digi_legs.visible = false
	planti_legs.visible = true
	hand_pads.visible = false

func previewTextureVariant(_previewMaker, _textureVariant:TextureVariant):
	if(_textureVariant.pathColormask != ""):
		bodyMat.set_shader_parameter("texture_color_mask", load(_textureVariant.pathColormask))
	elif(_textureVariant.pathTexture != ""):
		if(_textureVariant.flags.has("rect")):
			#TODO: Fix this
			var _theRect:Array = _textureVariant.flags["rect"]
			bodyMat.set_shader_parameter("texture_color_mask", null)
			pass
		else:
			bodyMat.set_shader_parameter("texture_color_mask", load(_textureVariant.pathTexture))
	else:
		bodyMat.set_shader_parameter("texture_color_mask", null)

func updateSelectedBodyMat():
	var theSkinType := getSkinType()
	var theExtraLayerData := getDoll().getFinalExtraLayerData()
	var hasExtraLayer:bool = !theExtraLayerData.is_empty()
	
	if(theSkinType == SkinType.HumanSkin):
		if(hasExtraLayer):
			setBodyMat(SKIN_BODY_SMART_EXTRA_LAYER_MAT)
		else:
			setBodyMat(SKIN_BODY_SMART_MAT)
	else:
		if(hasExtraLayer):
			setBodyMat(FUR_BODY_SMART_EXTRA_LAYER_MAT)
		else:
			setBodyMat(FUR_BODY_SMART_MAT)

func applyExtraLayerData(_data:Dictionary):
	updateSkinEverything()
		
func updateCrotch():
	var forceNormalVagina:bool = getCachedPartFlag("NormalVagina", false)
	var hideVagina:bool = getCachedPartFlag("HideVagina", false)
	var hasVag:bool = getOptionValue("vagina", true) if !hideVagina else false
	var vagType:int = getOptionValue("vaginaType", VaginaType.Normal) if !forceNormalVagina else VaginaType.Normal
	var vagSize:float = getOptionValue("vaginaSize", 0.0) if !forceNormalVagina else 0.0
	
	flat_crotch.visible = false #TODO: Flat crotch support
	pubic_hair.visible = !hideVagina
	
	clit_marker.setBlendshape("PussyClosedTight", 0.0)
	clit_marker.setBlendshape("ClitCanineVag", 0.0)
	clit_marker.setBlendshape("CaninePussySize", 0.0)
	
	if(hasVag):
		if(vagType == VaginaType.Spade):
			female_crotch_spade.visible = true
			female_crotch.visible = false
			male_crotch.visible = false
			setBlendshape("CaninePussySize", vagSize)
			clit_marker.setBlendshape("ClitCanineVag", 1.0)
		else:
			female_crotch.visible = true
			male_crotch.visible = false
			female_crotch_spade.visible = false
			
			if(vagType == VaginaType.Closed):
				#setBlendshape("PussyPuffy", 1.0)
				setBlendshape("PussyClosedTight", 1.0)
			else:
				#setBlendshape("PussyPuffy", 0.0)
				setBlendshape("PussyClosedTight", 0.0)
			setBlendshape("PussyPuffy", vagSize)
	else:
		female_crotch.visible = false
		male_crotch.visible = true
		female_crotch_spade.visible = false

func getNodeToAttachExtras(_slot:int) -> Node3D:
	if(_slot == 0):
		return nipple_l
	if(_slot == 1):
		return nipple_r
	if(_slot == 2):
		return clit_point
	return skeleton_3d

func calcBreastPhysics(_breasts:float):
	breastWigglePhysics = clamp(_breasts, 0.0, 1.0)

func getBreastsWigglePhysics() -> float:
	return breastWigglePhysics

func shouldSubscribeToDollHoleData() -> bool:
	return true

func applyDollHoleData(_data:DollHoleData):
	#var vagType:int = getOptionValue("vaginaType", VaginaType.Normal)
	
	setBlendshape("BellyBulge", _data.bellyBump)
	setBlendshape("PussyOpenedWide", _data.vagOpen)
	setBlendshape("PussyPull", _data.vagPull)
	setBlendshape("AnusOpenedWide", _data.anusOpen)
	setBlendshape("AnusPull", _data.anusPull)
	
	var spadeRemap:float = remap(_data.vagOpen, 0.0, 1.0, 1.0, -1.0)
	setBlendshape("CaninePussyClose", spadeRemap)

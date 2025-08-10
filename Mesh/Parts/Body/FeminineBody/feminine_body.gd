extends DollPart

@onready var body: MeshInstance3D = %Body
@onready var digi_legs: MeshInstance3D = %DigiLegs
@onready var planti_legs: MeshInstance3D = %PlantiLegs
@onready var neck_connector: MeshInstance3D = %NeckConnector
@onready var neck_connector_furry: MeshInstance3D = %NeckConnectorFurry
@onready var hand_pads: MeshInstance3D = %HandPads
var bodyMat:MyMasterMaterial
var handPadsMat:MyMasterMaterial
var nippleMat:MyMasterMaterial
var clawMat:MyMasterMaterial
var toeClawMat:MyMasterMaterial
var hindPawPadsMat:MyMasterMaterial
var genitalsMat:MyMasterMaterial
var spadeMat:MyMasterMaterial

@onready var body_layered_texture: MyLayeredTexture = %BodyLayeredTexture

@onready var randomCumScroll:float = RNG.randfRange(0.0, 100.0)
@onready var cum_layer: MyLayeredTexture = %CumLayer
@onready var nipples: MeshInstance3D = %Nipples
@onready var male_crotch: MeshInstance3D = %MaleCrotch
@onready var female_crotch: MeshInstance3D = %FemaleCrotch
@onready var female_crotch_spade: MeshInstance3D = %FemaleCrotchSpade


func grabMaterials():
	bodyMat = body.get_surface_override_material(0)
	clawMat = body.get_surface_override_material(1)
	handPadsMat = hand_pads.get_surface_override_material(0)
	nippleMat = nipples.get_surface_override_material(0)
	toeClawMat = digi_legs.get_surface_override_material(1)
	hindPawPadsMat = digi_legs.get_surface_override_material(2)
	genitalsMat = female_crotch.get_surface_override_material(1)
	spadeMat = female_crotch_spade.get_surface_override_material(2)

func updateThickness():
	updateThicknessBody()

func applyCharOption(_optionID:String, _value:Variant):
	updateThicknessBody(_optionID)

func applyOption(_optionID:String, _value:Variant):
	updateBreasts(_optionID, _value)
	
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
	if(_optionID == "hindPawPadColor"):
		if(hindPawPadsMat):
			hindPawPadsMat.set_shader_parameter("albedo", _value)
	if(_optionID == "nippleColor"):
		if(nippleMat):
			nippleMat.set_shader_parameter("albedo", _value)
	if(_optionID == "legType"):
		digi_legs.visible = (_value == "digi")
		planti_legs.visible = (_value == "planti")
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
		getDoll().setBreastWiggleMod(clamp(_value, 0.0, 1.0))
	if(_optionID == "vagina"):
		updateCrotch()
		triggerDollPartFlagsUpdate()
	if(_optionID == "vaginaType"):
		updateCrotch()
	if(_optionID == "vaginaSize"):
		updateCrotch()
	
func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	if(bodyMat == null):
		return
		
	const ignoreUniforms = ["albedo", "texture_mess_mask", "texture_alpha"]
		
	if(_skinType == SkinType.HumanSkin):
		bodyMat.copyFrom(preload("res://Mesh/Parts/Body/FeminineBody/SkinBodySmartMat.tres"), ignoreUniforms)
		bodyMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySubstancePainter_Body_Normal.png"))
		bodyMat.set_shader_parameter("texture_orm", preload("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySubstancePainter_Body_ORM.png"))
	elif(_skinType == SkinType.Fur):
		bodyMat.copyFrom(preload("res://Mesh/Parts/Body/FeminineBody/FurBodySmartMat.tres"), ignoreUniforms)
		bodyMat.set_shader_parameter("texture_normal", preload("res://Mesh/Parts/Body/FeminineBody/Textures/Fur/MyBodySubstancePainter_Body_Normal.png"))
		bodyMat.set_shader_parameter("texture_orm", preload("res://Mesh/Parts/Body/FeminineBody/Textures/Fur/MyBodySubstancePainter_Body_ORM.png"))
	
	#bodyMat.set_shader_parameter("albedo", _skinTypeData.color)
	bodyMat.set_shader_parameter("albedo", Color.WHITE)
	bodyMat.set_shader_parameter("messScroll", randomCumScroll)
	triggerUpdateBodyTexture()
	updateBodyMess()
	applyExtraLayerData(getDoll().getFinalExtraLayerData())

var isUpdatingBodyTexture:bool = false
func triggerUpdateBodyTexture():
	if(isUpdatingBodyTexture):
		return
	isUpdatingBodyTexture = true
	await get_tree().process_frame
	isUpdatingBodyTexture = false
	updateBodyTexture()

func updateBodyTexture():
	var theSkinData:SkinTypeData = getSkinData()
	if(theSkinData == null):
		return
	var theSkinType := getSkinType()
	
	body_layered_texture.clearLayers()
	
	if(theSkinType == SkinType.Fur):
		body_layered_texture.addSimpleLayer("res://Mesh/Parts/Body/FeminineBody/Textures/Fur/MyBodySubstancePainter_Body_BaseColor.png", theSkinData.color)
	if(theSkinType == SkinType.HumanSkin):
		body_layered_texture.addSimpleLayer("res://Mesh/Parts/Body/FeminineBody/Textures/Skin/MyBodySubstancePainter_Body_BaseColor.png", theSkinData.color)
	
	addLayersToTexture(body_layered_texture, getOptionValue("bodyLayers", []))

	var anusColor:Color = getOptionValue("anusColor", Color.RED)
	body_layered_texture.addSimpleLayerAt(preload("res://Mesh/Parts/Body/FeminineBody/Textures/Genitals/AnusL.png"), anusColor, Vector2(322.0/2048.0, 747.0/2048.0), Vector2(0.03125, 0.03125))
	body_layered_texture.addSimpleLayerAt(preload("res://Mesh/Parts/Body/FeminineBody/Textures/Genitals/AnusR.png"), anusColor, Vector2(1662.0/2048.0, 747.0/2048.0), Vector2(0.03125, 0.03125))

	bodyMat.set_shader_parameter("texture_albedo", body_layered_texture.getTexture())
	bodyMat.set_shader_parameter("freshnel_mod", 0.15)
	
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

func prepareForPreview(_previewMaker):
	bodyMat.copyFrom(previewDollMat)
	nipples.visible = false
	digi_legs.visible = false
	planti_legs.visible = true
	hand_pads.visible = false

func previewTextureVariant(_previewMaker, _textureVariant:TextureVariant):
	if(_textureVariant.pathColormask != ""):
		bodyMat.set_shader_parameter("texture_color_mask", load(_textureVariant.pathColormask))
	elif(_textureVariant.pathTexture != ""):
		bodyMat.set_shader_parameter("texture_color_mask", load(_textureVariant.pathTexture))
	else:
		bodyMat.set_shader_parameter("texture_color_mask", null)

func applyExtraLayerData(_data:Dictionary):
	if(!bodyMat):
		return
	if(_data.is_empty()):
		bodyMat.extraLayer = false
		return
	if(!bodyMat.rimlight):
		bodyMat.rimlight = true
		bodyMat.set_shader_parameter("rim", 0.0)
	bodyMat.extraLayer = true
	bodyMat.set_shader_parameter("extra_albedo", _data["color"])
	bodyMat.set_shader_parameter("texture_extra_albedo", _data["albedo"])
	bodyMat.set_shader_parameter("texture_extra_normal", _data["normal"])
	bodyMat.set_shader_parameter("texture_extra_orm", _data["orm"])
	bodyMat.set_shader_parameter("extra_rim", _data["rim"])
	bodyMat.set_shader_parameter("extra_rim_tint", _data["rim_tint"])
		
func updateCrotch():
	var forceNormalVagina:bool = getCachedPartFlag("NormalVagina", false)
	var hasVag:bool = getOptionValue("vagina", true)
	var vagType:int = getOptionValue("vaginaType", VaginaType.Normal) if !forceNormalVagina else VaginaType.Normal
	var vagSize:float = getOptionValue("vaginaSize", 0.0) if !forceNormalVagina else 0.0
	
	if(hasVag):
		if(vagType == VaginaType.Spade):
			female_crotch_spade.visible = true
			female_crotch.visible = false
			male_crotch.visible = false
			setBlendshape("CaninePussySize", vagSize)
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
	

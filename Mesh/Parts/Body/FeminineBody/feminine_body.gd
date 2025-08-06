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

@onready var body_layered_texture: MyLayeredTexture = %BodyLayeredTexture

@onready var randomCumScroll:float = RNG.randfRange(0.0, 100.0)
@onready var cum_layer: MyLayeredTexture = %CumLayer
@onready var nipples: MeshInstance3D = %Nipples

func grabMaterials():
	bodyMat = body.get_surface_override_material(0)
	clawMat = body.get_surface_override_material(1)
	handPadsMat = hand_pads.get_surface_override_material(0)
	nippleMat = nipples.get_surface_override_material(0)
	toeClawMat = digi_legs.get_surface_override_material(1)
	hindPawPadsMat = digi_legs.get_surface_override_material(2)

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
		updateBodyTexture()
	if(_optionID == "breasts"):
		getDoll().setBreastWiggleMod(clamp(_value, 0.0, 1.0))

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
	updateBodyTexture()
	updateBodyMess()
	applyExtraLayerData(getDoll().getFinalExtraLayerData())

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

	bodyMat.set_shader_parameter("texture_albedo", body_layered_texture.getTexture())
	bodyMat.set_shader_parameter("freshnel_mod", 0.15)
	
func gatherPartFlags(_theFlags:Dictionary):
	pass

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
		
	
	

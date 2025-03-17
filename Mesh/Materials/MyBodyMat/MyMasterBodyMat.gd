@tool
extends ShaderMaterial
class_name MyMasterBodyMat

@export var backlight:bool = false:
	set(value):
		backlight = value
		updateShader()
@export var freshnel:bool = false:
	set(value):
		freshnel = value
		updateShader()
@export var rimlight:bool = false:
	set(value):
		rimlight = value
		updateShader()
@export var subsurfaceScattering:bool = false:
	set(value):
		subsurfaceScattering = value
		updateShader()
@export var alphaMask:bool = false:
	set(value):
		alphaMask = value
		updateShader()
@export var uvBasedDiscard:bool = false:
	set(value):
		uvBasedDiscard = value
		updateShader()
@export var alphaSupport:bool = false:
	set(value):
		alphaSupport = value
		updateShader()
@export var globalDetailMask:bool = false:
	set(value):
		globalDetailMask = value
		updateShader()
@export var globalDetailRoughMask:bool = false:
	set(value):
		globalDetailRoughMask = value
		updateShader()
@export var colorMask:bool = false:
	set(value):
		colorMask = value
		updateShader()
@export var eyeMode:bool = false:
	set(value):
		eyeMode = value
		updateShader()
@export var doubleSided:bool = false:
	set(value):
		doubleSided = value
		updateShader()
@export var toonShading:bool = false:
	set(value):
		toonShading = value
		updateShader()
		
@export var clearCache:bool = false:
	set(value):
		if(value):
			cachedShaders.clear()
			updateShader()

static var cachedShaders:Dictionary = {}
static var cachedUniformNames:Dictionary = {}
var uniformNames:Array = []

func copyFrom(otherShader:MyMasterBodyMat, ignoreUniforms:Array = []):
	backlight = otherShader.backlight
	freshnel = otherShader.freshnel
	rimlight = otherShader.rimlight
	subsurfaceScattering = otherShader.subsurfaceScattering
	alphaMask = otherShader.alphaMask
	uvBasedDiscard = otherShader.uvBasedDiscard
	alphaSupport = otherShader.alphaSupport
	globalDetailMask = otherShader.globalDetailMask
	globalDetailRoughMask = otherShader.globalDetailRoughMask
	colorMask = otherShader.colorMask
	eyeMode = otherShader.eyeMode
	doubleSided = otherShader.doubleSided
	toonShading = otherShader.toonShading
	updateShader()
	#var allUniforms:Array = shader.get_shader_uniform_list()
	for theUniformName in uniformNames:
		#var theUniformName:String = theUniform["name"]
		if(ignoreUniforms.has(theUniformName)):
			continue
		set_shader_parameter(theUniformName, otherShader.get_shader_parameter(theUniformName))

func _init():
	updateShader()

func calculateShaderVariantString() -> String:
	var theFlags:Array = []
	if(backlight):
		theFlags.append("b")
	if(freshnel):
		theFlags.append("f")
	if(rimlight):
		theFlags.append("r")
	if(toonShading):
		theFlags.append("t")
	if(subsurfaceScattering):
		theFlags.append("s")
	if(alphaMask):
		theFlags.append("a")
	if(uvBasedDiscard):
		theFlags.append("u")
	if(alphaSupport):
		theFlags.append("aa")
	if(globalDetailMask):
		theFlags.append("dt")
	if(globalDetailRoughMask):
		theFlags.append("dr")
	if(colorMask):
		theFlags.append("cm")
	if(doubleSided):
		theFlags.append("ds")
	if(eyeMode):
		theFlags.append("em")
	return Util.join(theFlags, "|")

func calculateShaderResource() -> Array:
	var masterResource := preload("res://Mesh/Materials/MyBodyMat/MyMasterBodyShader.gdshader")
	
	var copyResource := masterResource.duplicate(true)
	
	var defines:Array = []
	if(backlight):
		defines.append("MY_BACKLIGHT")
	if(freshnel):
		defines.append("MY_FRESHNEL")
	if(rimlight):
		defines.append("MY_RIMLIGHT")
	if(subsurfaceScattering):
		defines.append("MY_SUBSURFACESCATTER")
	if(toonShading):
		defines.append("MY_TOONSHADING")
	if(alphaMask):
		defines.append("MY_ALPHAMASK")
	if(uvBasedDiscard):
		defines.append("MY_UV_BASED_DISCARD")
	if(alphaSupport):
		defines.append("MY_ALPHASUPPORT")
	if(globalDetailMask):
		defines.append("MY_GLOBALDETAILMAP")
	if(globalDetailRoughMask):
		defines.append("MY_GLOBALDETAILROUGHMAP")
	if(colorMask):
		defines.append("MY_COLORMASK")
	if(doubleSided):
		defines.append("MY_DOUBLESIDED")
	if(eyeMode):
		defines.append("MY_EYEMODE")
	var definesText:String = ""
	for define in defines:
		definesText += "#define "+define+"\n"
	
	var shaderCode:String = copyResource.code
	shaderCode = shaderCode.replace("//{{DEFINES_PLACEHOLDER}}", definesText)
	copyResource.code = shaderCode
	
	var theuniformNames:Array = []
	var allUniforms:Array = copyResource.get_shader_uniform_list()
	for theUniform in allUniforms:
		theuniformNames.append(theUniform["name"])
	
	return [copyResource, theuniformNames]

func updateShader():
	var currentVariant:String = calculateShaderVariantString()
	
	if(currentVariant == ""):
		shader = preload("res://Mesh/Materials/MyBodyMat/MyMasterBodyShader.gdshader")
		return
	
	if(cachedShaders.has(currentVariant) && cachedUniformNames.has(currentVariant)):
		shader = cachedShaders[currentVariant]
		uniformNames = cachedUniformNames[currentVariant]
	else:
		var theStuff := calculateShaderResource()
		shader =  theStuff[0]
		uniformNames = theStuff[1]
		cachedShaders[currentVariant] = shader
		cachedUniformNames[currentVariant] = uniformNames

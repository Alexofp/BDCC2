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
	return Util.join(theFlags, "|")

func calculateShaderResource() -> Shader:
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
	var definesText:String = ""
	for define in defines:
		definesText += "#define "+define+"\n"
	
	var shaderCode:String = copyResource.code
	shaderCode = shaderCode.replace("//{{DEFINES_PLACEHOLDER}}", definesText)
	copyResource.code = shaderCode
	
	return copyResource

func updateShader():
	var currentVariant:String = calculateShaderVariantString()
	
	if(currentVariant == ""):
		shader = preload("res://Mesh/Materials/MyBodyMat/MyMasterBodyShader.gdshader")
		return
	
	if(cachedShaders.has(currentVariant)):
		shader = cachedShaders[currentVariant]
	else:
		shader =  calculateShaderResource()
		cachedShaders[currentVariant] = shader

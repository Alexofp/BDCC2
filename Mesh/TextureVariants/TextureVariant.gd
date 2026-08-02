extends RefCounted
class_name TextureVariant

var id:String = ""

var name:String = ""

var type:String = ""
var subType:String = ""

var pathTexture:String = ""
var pathColormask:String = ""
var pathNormal:String = ""
var pathORM:String = ""

var previewDollPartPath:String = ""
var previewPath:String = ""

var flags:Dictionary = {}

var genCovers:int = 0
var genNeck:String = ""
var genMapR:int = GenColorMapTo.FUR_COLOR2
var genMapG:int = GenColorMapTo.FUR_COLOR3
var genMapB:int = GenColorMapTo.FUR_COLOR4
var genWeight:float = 1.0

const COVERS_MAIN := 1
const COVERS_ARMS := 2
const COVERS_LEGS := 4
const COVERS_EXTRA := 8
const COVERS_ARMS_NEKO := 16
const COVERS_LEGS_NEKO := 32
const COVERS_TATTOO := 64

func getName() -> String:
	return name

func parse(entry:Dictionary, _subType:String):
	if(entry.has("name")):
		name = entry["name"]
	else:
		name = id
	if(entry.has("texture")):
		pathTexture = entry["texture"]
	if(entry.has("normal")):
		pathNormal = entry["normal"]
	if(entry.has("colormask")):
		pathColormask = entry["colormask"]
	if(entry.has("orm")):
		pathORM = entry["orm"]
	if(entry.has("flags")):
		flags = entry["flags"]
	if(entry.has("subType")):
		subType = entry["subType"]
	else:
		subType = _subType
	
	if(entry.has("gen")):
		var theGen:Dictionary = entry["gen"]
		
		genCovers = theGen.get("covers", genCovers)
		genNeck = theGen.get("neck", genNeck)
		genMapR = theGen.get("r", genMapR)
		genMapG = theGen.get("g", genMapG)
		genMapB = theGen.get("b", genMapB)
		genWeight = theGen.get("weight", genWeight)

func getFlag(flagID:String, defaultValue:Variant = null):
	if(!flags.has(flagID)):
		return defaultValue
	return flags[flagID]

func loadColormask() -> Texture2D:
	if(pathColormask == ""):
		return null
	return load(pathColormask)

func isCovering(_genCoverZone:int) -> bool:
	return genCovers & _genCoverZone

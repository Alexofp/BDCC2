extends Node
class_name HoleTrackerForDoll

enum Hole {Vagina, Anus, Mouth}
@export var holeType:Hole = Hole.Vagina

@export var dollPart:DollPart
@export var crotchMeshes:Array[MeshInstance3D]
@export var openShapekey:String = "PussyOpenedWide"
@export var openShapekeyMult:float = 1.0
@export var pullShapekey:String = "PussyPull"
@export var pullShapekeyMult:float = 1.0
@export var pullMaxValue:float = 5.0


var cachedValue:float = -1.0
var cachedPullValue:float = -1.0

func _process(_delta: float) -> void:
	if(!dollPart):
		return
	var theDoll:Doll = dollPart.getDoll()
	if(!theDoll):
		return
	
	var dollHole:DollOpenableHole
	if(holeType == Hole.Vagina):
		dollHole = theDoll.getVaginaHoleNode()
	elif(holeType == Hole.Anus):
		dollHole = theDoll.getAnusHoleNode()
	if(!dollHole):
		return
	
	var newOpenValue:float = clamp(dollHole.getOpenValue()*openShapekeyMult, -0.1, 1.0)
	var newPullValue:float = clamp(dollHole.getPullValue()*pullShapekeyMult, -pullMaxValue, pullMaxValue)
	if(abs(newOpenValue - cachedValue)<0.001 && abs(newPullValue - cachedPullValue)<0.001):
		return
	cachedValue = newOpenValue
	cachedPullValue = newPullValue
	#print("PULL: "+str(newPullValue))
	
	for meshA in crotchMeshes:
		var mesh:MeshInstance3D = meshA
		
		setBlendShape(mesh, openShapekey, cachedValue)
		setBlendShape(mesh, pullShapekey, cachedPullValue)

func setBlendShape(mesh:MeshInstance3D, theBlendShape:String, theVal:float):
	var blendShapeIndx:int = mesh.find_blend_shape_by_name(theBlendShape)
	if(blendShapeIndx < 0):
		return
	mesh.set_blend_shape_value(blendShapeIndx, theVal)

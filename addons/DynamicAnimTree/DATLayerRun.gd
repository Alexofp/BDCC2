extends RefCounted
class_name DATLayerRun

var tree:DynamicAnimTree
var layer:DATLayer
var layerIndx:int = -1

var enabled:bool = false
#var node:AnimationNode
var fileteredBonePaths:Array[String]

const EMPTY_ANIM_NAME:String = DynamicAnimTree.EMPTY_ANIM_NAME
const SMOOTH:Curve = preload("res://addons/DynamicAnimTree/XFadeCurves/Smooth.tres")
const SMOOTH_VERY:Curve = preload("res://addons/DynamicAnimTree/XFadeCurves/SmoothVery.tres")

func onCreated(_layer:DATLayer):
	pass

func setEnabled(_e:bool):
	if(enabled == _e):
		return
	enabled = _e
	
	if(enabled):
		onEnable()
	else:
		onDisable()
		clearAnimNodes()
		setMyNode(null)

func onEnable():
	#setMyNode(AnimationNodeOneShot.new())
	setMyNode(AnimationNodeTimeScale.new())

func onDisable():
	pass

func setMyNode(_animNode:AnimationNode):
	tree.setNodeOf(self, _animNode)

func getMyNode() -> AnimationNode:
	return tree.getNodeOf(self)

func hasNode() -> bool:
	return tree.getNodeOf(self) != null

func addAnimNode(_node:AnimationNode, _name:String) -> String:
	return tree.addLayerAnimNode(_node, self, _name)

func deleteAnimNode(_name:String):
	tree.deleteLayerAnimNode(self, _name)

func getFinalNameOfNode(_name:String) -> String:
	if(_name.is_empty()):
		return str(layerIndx)
	return str(layerIndx)+"_"+_name

func connectNodes(_inputName:String, _input_index:int, _outputName:String):
	tree.baseBlendTree.connect_node(getFinalNameOfNode(_inputName), _input_index, getFinalNameOfNode(_outputName))

func clearAnimNodes():
	tree.clearAnimNodesOf(self)

# Return false if processing should stop
func processLayer(_dt:float) -> bool:
	return false

func startProcessingMe():
	tree.startProcessingLayer(self)

func filterBonesForAnimNode(_node:AnimationNode, _bones:Array[String]):
	if(_bones.is_empty()):
		return
	_node.filter_enabled = true
	for theBone:String in _bones:
		_node.set_filter_path(theBone, true)

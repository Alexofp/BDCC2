@tool
extends AnimationTree
class_name DynamicAnimTree

var treeDef:DynamicAnimTreeDef
var baseBlendTree:AnimationNodeBlendTree = AnimationNodeBlendTree.new()
var emptyStartNode:AnimationNodeAnimation = AnimationNodeAnimation.new()
var emptyStartTrans:AnimationNodeTransition = AnimationNodeTransition.new()

var runLayers:Dictionary[int, DATLayerRun]
var nextLayer:Dictionary[DATLayerRun, DATLayerRun]
var prevLayer:Dictionary[DATLayerRun, DATLayerRun]
var layerNode:Dictionary[DATLayerRun, AnimationNode]
var layerToUsedNodes:Dictionary[DATLayerRun, Array] # dict[layer, Array[strings]]
var processLayers:Array[DATLayerRun]

var customStartNode:AnimationNode
var customStartNodeName:String = "Custom"

# Required for bone filtering
@export var skeleton:Skeleton3D

@export_tool_button("GENERATE TREE", "Callable") var doFullSetup_action = doFullSetup
func doFullSetup():
	ensureAnimPlayerHasEmptyAnim()
	setTreeDef(load("res://addons/DynamicAnimTree/DynAnimTreeExample.gd").new())
	#getLayer(1).setEnabled(true)
#	getNode(1).play("Jog")
@export_tool_button("ANIM 1", "Callable") var doTest1_action = doTest1
func doTest1():
	getLayer(2).play("Run", 0.1)
@export_tool_button("ANIM 2", "Callable") var doTest2_action = doTest2
func doTest2():
	getLayer(2).play("Jog", 0.25)
@export_tool_button("ANIM 3", "Callable") var doTest3_action = doTest3
func doTest3():
	getLayer(2).play("Idle", 2.0)
@export_tool_button("ANIM 4", "Callable") var doTest4_action = doTest4
func doTest4():
	getLayer(2).play("", 0.1)
@export_tool_button("ANIM 5", "Callable") var doTest5_action = doTest5
func doTest5():
	getLayer(2).play("Fall", 0.5)
@export_tool_button("ANIM 6", "Callable") var doTest6_action = doTest6
func doTest6():
	#getLayer(2).play("", 1.0)
	var theLayer:DATBlend2DRun = getLayer(1)
	theLayer.stop(0.25)
@export_tool_button("ANIM 7", "Callable") var doTest7_action = doTest7
func doTest7():
	#getLayer(6).playAnim(0, "Jog")
	var theLayer:DATBlend2DRun = getLayer(1)
	theLayer.play()
	theLayer.setPos(Vector2(randf_range(0.0, 1.0), randf_range(0.0, 1.0)))
	#theLayer.stop(0.25)
	#theLayer.playAnim(1, "Run", 0.2, 0.25, true, true)
	#theLayer.setPos(Vector2(0.0, 1.0))

func _ready() -> void:
	tree_root = baseBlendTree
	ensureAnimPlayerHasEmptyAnim()
	
	emptyStartTrans = AnimationNodeTransition.new()
	emptyStartTrans.add_input("0")
	emptyStartTrans.add_input("1")
	emptyStartTrans.xfade_time = 0.0
	#setTreeDef(load("res://addons/DynamicAnimTree/DynAnimTreeExample.gd").new())

func setTreeDef(_tree:DynamicAnimTreeDef):
	baseBlendTree = AnimationNodeBlendTree.new()
	tree_root = baseBlendTree
	
	baseBlendTree.add_node("START", emptyStartTrans)
	set("parameters/START/transition_request", "0")
	
	emptyStartNode.animation = EMPTY_ANIM_NAME
	baseBlendTree.add_node("START_ANIM", emptyStartNode)
	
	baseBlendTree.connect_node("START", 0, "START_ANIM")
	baseBlendTree.connect_node("output", 0, "START")
	
	treeDef = _tree
	
	# Clear refs of each runtime layer?
	runLayers.clear()
	nextLayer.clear()
	prevLayer.clear()
	layerNode.clear()
	layerToUsedNodes.clear()
	processLayers.clear()
	var thePrevLayer:DATLayerRun
	for _layerIndx:int in treeDef.layers:
		var theLayer:DATLayer = treeDef.layers[_layerIndx]
		
		var theRunTimeLayer:DATLayerRun = theLayer.createRunLayer()
		theRunTimeLayer.tree = self
		theRunTimeLayer.layer = theLayer
		theRunTimeLayer.layerIndx = _layerIndx
		theRunTimeLayer.onCreated(theLayer)
		
		if(thePrevLayer):
			nextLayer[thePrevLayer] = theRunTimeLayer
			prevLayer[theRunTimeLayer] = thePrevLayer
		
		runLayers[_layerIndx] = theRunTimeLayer
		var theAr:Array[String]
		layerToUsedNodes[theRunTimeLayer] = theAr
		thePrevLayer = theRunTimeLayer
		
		# Cache this somehow?
		if(skeleton && (!theLayer.filterBones.is_empty() || !theLayer.filterBonesReq.is_empty())):
			var theFilter:BoneFilter = BoneFilter.new(self, skeleton)
			for theBone:String in theLayer.filterBones:
				theFilter.enableBone(theBone)
			for theBone:String in theLayer.filterBonesReq:
				theFilter.enableBoneReqursive(theBone)
			theRunTimeLayer.fileteredBonePaths = theFilter.bones

func setNodeOf(_layer:DATLayerRun, _node:AnimationNode):
	var theCurrentNode:AnimationNode = layerNode[_layer] if layerNode.has(_layer) else null
	var theLayerStr:String = str(_layer.layerIndx)
	
	if(theCurrentNode):
		var thePrevName:String = findPrevNodeNameToConnectTo(_layer)
		var theNextName:String = findNextNodeNameToConnectTo(_layer)
		baseBlendTree.remove_node(theLayerStr)
		layerNode.erase(_layer)
		baseBlendTree.connect_node(theNextName, 0, thePrevName)
	
	if(_node):
		layerNode[_layer] = _node
		var thePrevName:String = findPrevNodeNameToConnectTo(_layer)
		var theNextName:String = findNextNodeNameToConnectTo(_layer)
		baseBlendTree.disconnect_node(theNextName, 0)
		#print("WE: "+theLayerStr+" PREV: "+str(thePrevName)+" NEXT: "+str(theNextName))
		baseBlendTree.add_node(theLayerStr, _node)
		
		baseBlendTree.connect_node(theLayerStr, 0, thePrevName)
		baseBlendTree.connect_node(theNextName, 0, theLayerStr)

func findPrevNodeNameToConnectTo(_layer:DATLayerRun) -> String:
	var thePrevLayer:DATLayerRun = prevLayer[_layer] if prevLayer.has(_layer) else null
	while(thePrevLayer && !layerNode.has(thePrevLayer)):
		thePrevLayer = prevLayer[thePrevLayer] if prevLayer.has(thePrevLayer) else null
	if(thePrevLayer):
		return str(thePrevLayer.layerIndx)
	
	#if(customStartNode):
	#	return customStartNodeName
	return "START"

func findNextNodeNameToConnectTo(_layer:DATLayerRun) -> String:
	var theNextLayer:DATLayerRun = nextLayer[_layer] if nextLayer.has(_layer) else null
	while(theNextLayer && !layerNode.has(theNextLayer)):
		theNextLayer = nextLayer[theNextLayer] if nextLayer.has(theNextLayer) else null
	if(theNextLayer):
		return str(theNextLayer.layerIndx)
	return "output"

func setCustomStartNode(_node:AnimationNode, _name:String = "CUSTOM"):
	var theFirstName:String = "output"
	if(!runLayers.is_empty()):
		theFirstName = str(runLayers.keys()[0])
	
	var _isConnectedToCustom:bool = (customStartNode != null)
	
	baseBlendTree.disconnect_node("START", 0)
	if(customStartNode):
		#if(theFirstName == "START"):
		#set("parameters/START/transition_request", "0")
		#else:
		#	baseBlendTree.disconnect_node(theFirstName, 0)
		baseBlendTree.remove_node(customStartNodeName)
		customStartNode = null
	customStartNode = _node
	customStartNodeName = _name
	
	if(customStartNode):
		baseBlendTree.add_node(customStartNodeName, customStartNode)
		#if(theFirstName == "START"):
		baseBlendTree.connect_node("START", 0, customStartNodeName)
		#set("parameters/START/transition_request", "1")
		#else:
		#	baseBlendTree.connect_node(theFirstName, 0, customStartNodeName)
	else:
		baseBlendTree.connect_node("START", 0, "START_ANIM")
	#elif(_isConnectedToCustom):
	#	baseBlendTree.connect_node(theFirstName, 0, "START")

func getNodeOf(_layer:DATLayerRun) -> AnimationNode:
	if(!layerNode.has(_layer)):
		return null
	return layerNode[_layer]

func getLayer(_indx:int) -> DATLayerRun:
	if(!runLayers.has(_indx)):
		return null
	return runLayers[_indx]

func getALayer(_indx:int) -> DATAnimRun:
	if(!runLayers.has(_indx)):
		return null
	return runLayers[_indx]

func getB2Layer(_indx:int) -> DATBlend2DRun:
	if(!runLayers.has(_indx)):
		return null
	return runLayers[_indx]

const EMPTY_ANIM_NAME:String = "EMPTY/ANIM"

func getAnimPlayer() -> AnimationPlayer:
	return get_node(anim_player)

func getAnimation(_name:String) -> Animation:
	var theAnimPlayer:AnimationPlayer = getAnimPlayer()
	if(!theAnimPlayer):
		return null
	return theAnimPlayer.get_animation(_name)

func ensureAnimPlayerHasEmptyAnim():
	var theAnimPlayer:AnimationPlayer = get_node(anim_player)
	if(!theAnimPlayer):
		return
	if(!theAnimPlayer.has_animation("EMPTY/ANIM")):
		var newLib:AnimationLibrary = AnimationLibrary.new()
		newLib.add_animation("ANIM", Animation.new())
		theAnimPlayer.add_animation_library("EMPTY", newLib)

func addLayerAnimNode(_node:AnimationNode, _layer:DATLayerRun, _name:String) -> String:
	var theFullName:String = str(_layer.layerIndx)+"_"+_name
	layerToUsedNodes[_layer].append(theFullName)
	baseBlendTree.add_node(theFullName, _node)
	return theFullName

func deleteLayerAnimNode(_layer:DATLayerRun, _name:String):
	var theFullName:String = str(_layer.layerIndx)+"_"+_name
	layerToUsedNodes[_layer].erase(theFullName)
	baseBlendTree.remove_node(theFullName)

func clearAnimNodesOf(_layer:DATLayerRun):
	if(!layerToUsedNodes.has(_layer)):
		return
	for theName:String in layerToUsedNodes[_layer]:
		baseBlendTree.remove_node(theName)
	layerToUsedNodes[_layer].clear()

func startProcessingLayer(_layer:DATLayerRun):
	if(processLayers.has(_layer)):
		return
	if(processLayers.is_empty()):
		set_process(true)
	processLayers.append(_layer)

func _process(_delta: float) -> void:
	var _am:int = processLayers.size()
	for _i:int in _am:
		var _index:int = _am - 1 - _i
		var theLayer:DATLayerRun = processLayers[_index]
		if(!theLayer.processLayer(_delta)):
			processLayers.remove_at(_index)
	
	if(processLayers.is_empty()):
		set_process(false)


class BoneFilter:
	var bones:Array[String] = []
	var animTree:AnimationTree
	var skeleton:Skeleton3D
	
	func _init(_animTree:AnimationTree, _skeleton:Skeleton3D) -> void:
		animTree = _animTree
		skeleton = _skeleton
	
	func enableBone(_bone:String):
		var thePath := animTree.get_node(animTree.root_node).get_path_to(skeleton)
		var theFinalPath := thePath.get_concatenated_names()+":"+_bone
		bones.append(theFinalPath)
		#print(theFinalPath)
	
	func enableBoneReqursive(_bone:String):
		var thePreBonePath:String = animTree.get_node(animTree.root_node).get_path_to(skeleton).get_concatenated_names()+":"
		var toCheck:Array[int] = [skeleton.find_bone(_bone)]
		while(!toCheck.is_empty()):
			var theNextBone:int = toCheck.pop_back()
			bones.append(thePreBonePath+skeleton.get_bone_name(theNextBone))
			for _boneIndx:int in skeleton.get_bone_children(theNextBone):
				toCheck.append(_boneIndx)
	
	func getBonesFinal() -> Array[String]:
		return bones.duplicate()

extends Node
class_name SynchronizedTargetNode

@export var UID:Array:set = onUIDSync

signal onNodeChanged(newNode)

func onUIDSync(newUID:Array):
	UID = newUID
	if(onNodeChanged.has_connections()):
		onNodeChanged.emit(getNode())

func setNode(theNode:Node):
	UID = GameInteractor.getUniqueIDOf(theNode)

func getNode() -> Node:
	if(UID.is_empty()):
		return null
	return GameInteractor.getNodeByUniqueID(UID)

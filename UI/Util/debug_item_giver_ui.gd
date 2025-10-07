extends PanelContainer

var dollUser
var giverNode:WeakRef

@onready var item_list: ItemList = %ItemList
var itemIDs:Array[String] = []

func _enter_tree() -> void:
	UIHandler.addUI(self)

func _exit_tree() -> void:
	UIHandler.removeUI(self)

func _on_close_button_pressed() -> void:
	queue_free()

func _ready() -> void:
	for theItemID in GlobalRegistry.getItemRefs():
		item_list.add_item(theItemID)
		itemIDs.append(theItemID)

func _on_give_button_pressed() -> void:
	if(item_list.get_selected_items().is_empty()):
		return
	var theSelectedIndx:int = item_list.get_selected_items()[0]
	
	if(theSelectedIndx < 0 || theSelectedIndx >= itemIDs.size()):
		return
	var theItemID:String = itemIDs[theSelectedIndx]
	
	if(!giverNode || !giverNode.get_ref()):
		Log.Printerr("Debug item giver UI needs to be connected to an item giver!")
		return
	GM.netNodes.sendServerEvent(giverNode.get_ref(), "giveItem", [theItemID, dollUser])

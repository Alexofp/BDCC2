extends ConfirmationDialog

var selectedID:String = ""
var textureVariantIDs:Array = []
var idListActual:Array[String] = []

@onready var texture_variant_list: ItemList = %TextureVariantList

signal onApply(window, newText)
signal onClose(window)

func setData(_data:Dictionary):
	if(_data.has("name")):
		title = _data["name"]
	if(_data.has("value")):
		selectedID = _data["value"]
	if(_data.has("values")):
		textureVariantIDs = _data["values"]
	updateList()
	
func updateList():
	var _i:int = 0
	idListActual.clear()
	texture_variant_list.clear()
	for textureVariantID in textureVariantIDs:
		var textureVariant:TextureVariant = GlobalRegistry.getTextureVariant(textureVariantID)
		if(!textureVariant):
			continue
		
		texture_variant_list.add_item(textureVariant.getName(), load(textureVariant.previewPath) if textureVariant.previewPath != "" else null)
		if(selectedID == textureVariantID):
			texture_variant_list.select(_i)
		idListActual.append(textureVariantID)
		_i += 1
		

func _on_canceled() -> void:
	onClose.emit(self)

func _on_confirmed() -> void:
	if(selectedID != ""):
		onApply.emit(self, selectedID)

func _on_texture_variant_list_item_selected(index: int) -> void:
	if(index < 0 || index >= idListActual.size()):
		return
	selectedID = idListActual[index]

func _enter_tree() -> void:
	UIHandler.addWindow(self)

func _exit_tree() -> void:
	UIHandler.removeWindow(self)

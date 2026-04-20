extends Control
#@onready var close_control_space: Control = %CloseControlSpace

var charID:String = ""

const TAB_CHARACTER = "character"
const TAB_INVENTORY = "inventory"
const TAB_POSE = "pose"
const TAB_INTERACT = "interact"

var currentTab:String = TAB_INVENTORY

@onready var tabToButton:Dictionary = {
	TAB_CHARACTER: %CharacterButton,
	TAB_INVENTORY: %InventoryButton,
	TAB_POSE: %PoseButton,
	TAB_INTERACT: %InteractButton,
}
@onready var tabToNode:Dictionary = {
	TAB_CHARACTER: %CharacterTab,
	TAB_INVENTORY: %InventoryUIEmbed,
	TAB_POSE: %PosingMenu,
	TAB_INTERACT: %InteractionMenuEmbedded,
}
var tabToName:Dictionary[String, String] = {
	TAB_CHARACTER: "Character",
	TAB_INVENTORY: "Inventory",
	TAB_POSE: "Pose",
	TAB_INTERACT: "Interact",
}

@onready var interaction_menu_embedded: ScrollContainer = %InteractionMenuEmbedded
@onready var inventory_ui_embed: VBoxContainer = %InventoryUIEmbed
@onready var posing_menu: VBoxContainer = %PosingMenu

signal onClose

func _ready() -> void:
	#close_control_space.visible = true
	setTab(currentTab)

func setCharacter(_char:BaseCharacter):
	if(!_char):
		charID = ""
		resetTabs()
		return
	charID = _char.getID()
	updateCurrentTab()

func setTab(_theTab:String):
	currentTab = _theTab
	
	for theTab in tabToButton:
		var theButton:Button = tabToButton[theTab]
		theButton.disabled = (currentTab == theTab)
		theButton.text = "["+tabToName[theTab]+"]" if (currentTab == theTab) else tabToName[theTab]
		
		var theNode = tabToNode[theTab]
		if(theNode):
			theNode.visible = (currentTab == theTab)
	updateCurrentTab()

func resetTabs():
	inventory_ui_embed.setCharacter(null)
	interaction_menu_embedded.setCharacter(null)
	posing_menu.setCharacter(null)

func updateCurrentTab():
	if(currentTab == TAB_INVENTORY):
		inventory_ui_embed.setCharacter(GM.characterRegistry.getCharacter(charID) if charID != "" else null)
	if(currentTab == TAB_INTERACT):
		interaction_menu_embedded.setCharacter(GM.characterRegistry.getCharacter(charID) if charID != "" else null)
	if(currentTab == TAB_POSE):
		posing_menu.setCharacter(GM.characterRegistry.getCharacter(charID) if charID != "" else null)
	
func _on_character_button_pressed() -> void:
	setTab(TAB_CHARACTER)

func _on_inventory_button_pressed() -> void:
	setTab(TAB_INVENTORY)

func _on_pose_button_pressed() -> void:
	setTab(TAB_POSE)

func _on_interact_button_pressed() -> void:
	setTab(TAB_INTERACT)

func _on_close_button_pressed() -> void:
	onClose.emit()

func _enter_tree() -> void:
	UIHandler.addUI(self, UIHandler.CLOSE_TRYCLOSEMENU_FUNC)

func _exit_tree() -> void:
	UIHandler.removeUI(self)

func tryCloseMenu() -> bool:
	onClose.emit()
	return true


func _on_gui_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		if(event.button_index == MOUSE_BUTTON_RIGHT && event.pressed):
			if(GM.pcDoll):
				GM.dollHolder.askLookAtClear(GM.pcDoll)
		
		if(event.button_index == MOUSE_BUTTON_LEFT && event.pressed):
			#print("PRESSED!")
			shoot_ray()

func shoot_ray():
	var theCamera := get_viewport().get_camera_3d()
# here we tell where to raycast is pointing adn from where
	var mouse_pos := get_viewport().get_mouse_position() 
	var ray_length := 1000.0
	var from := theCamera.project_ray_origin(mouse_pos)
	var to := from + theCamera.project_ray_normal(mouse_pos) * ray_length
	var space_state := theCamera.get_world_3d().direct_space_state

# here i set params for intersect_ray
	var params := PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	params.collide_with_areas = true  # Set to true to include Area nodes
	params.collide_with_bodies = true  # Set to true to include PhysicsBody nodes (don't know if necessary)

	var result := space_state.intersect_ray(params)

# here I try to see the result
	if result and result.collider:
		#print("Raycast hit: ", result.collider, " ", result.position)
		if(GM.pcDoll):
			if(result.collider == GM.pcDoll):
				GM.dollHolder.askLookAtClear(GM.pcDoll)
			else:
				GM.dollHolder.askLookAtCustom(GM.pcDoll, result.position)
	else: 
		#print("Raycast hit: ", result)
		if(GM.pcDoll):
			GM.dollHolder.askLookAtClear(GM.pcDoll)

func _on_masturbate_button_pressed() -> void:
	if(GM.pc):
		GM.sexManager.askStartMasturbation(GM.pc.getID())
		_on_close_button_pressed()

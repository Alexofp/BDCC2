extends Control
@onready var close_control_space: Control = %CloseControlSpace

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
	TAB_CHARACTER: null,
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
	close_control_space.visible = true
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
	UIHandler.addUI(self)

func _exit_tree() -> void:
	UIHandler.removeUI(self)

extends Control
class_name SexUI

@onready var action_progress_bar: ProgressBar = %ActionProgressBar
@onready var fade_anim_player: AnimationPlayer = %FadeAnimPlayer
@onready var fade_rect: ColorRect = %FadeRect
@onready var action_text_label: RichTextLabel = %ActionTextLabel
@onready var auto_consent_check_box: CheckBox = %AutoConsentCheckBox
@onready var participants_list: VBoxContainer = %ParticipantsList
@onready var chat_widget: VBoxContainer = %ChatWidget
@onready var smart_button_grid: SmartButtonGrid = %SmartButtonGrid

var sexParticipantUIEntryScene := preload("res://Game/Sex/UI/sex_participant_ui_entry.tscn")

var sexEngine:SexEngine
var pawn:CharacterPawn

var buttonsCache:Array = []

var actionTextCache:String = ""

var controllingCamera:bool = false

func _enter_tree() -> void:
	UIHandler.addUI(self)
	UIHandler.addMouseCapturer(self)

func _exit_tree() -> void:
	UIHandler.removeUI(self)
	UIHandler.removeMouseCapturer(self)

func _ready():
	fade_rect.visible = false
	updateButtons()

func onActionButtonPressed(_indx:int):
	if(_indx < 0 || _indx >= buttonsCache.size()):
		return
	var theAction:Dictionary = buttonsCache[_indx]
	sexEngine.askSelectAction(pawn.getCharID(), theAction)

func setEngine(theEngine:SexEngine):
	if(sexEngine):
		sexEngine.onAnimSceneSwitched.disconnect(onSexEngineAnimSceneSwitched)
		sexEngine.onParticipantUpdate.disconnect(onSexEngineParticipantUpdate)
	sexEngine = theEngine
	if(sexEngine):
		sexEngine.onAnimSceneSwitched.connect(onSexEngineAnimSceneSwitched)
		sexEngine.onParticipantUpdate.connect(onSexEngineParticipantUpdate)
		playQuickFade()
	
	updateSexParticipantsList()

func onSexEngineParticipantUpdate(_charID:String):
	if(!pawn || !getEngine()):
		return
	updateSexParticipantsList()
	var ourID:String = pawn.getCharID()
	if(ourID != _charID):
		return
	updateAutoConsentCheckbox()

func updateAutoConsentCheckbox():
	if(!pawn || !getEngine()):
		return
	var ourID:String = pawn.getCharID()
	var participant:SexParticipantInfo = getEngine().getParticipant(ourID)
	if(!participant):
		return
	var hasAutoConsent:bool = participant.isAutoConsentToggledOn()
	
	auto_consent_check_box.set_pressed_no_signal(hasAutoConsent)

func onSexEngineAnimSceneSwitched():
	playQuickFade()

func setPawn(thePawn:CharacterPawn):
	pawn = thePawn
	updateAutoConsentCheckbox()

func getEngine() -> SexEngine:
	return sexEngine

func getPawn() -> CharacterPawn:
	return pawn

func calculateButtons() -> Array:
	if(!sexEngine || !pawn):
		return []
	
	return sexEngine.getActions(pawn.getCharID())

func getCurrentPage() -> int:
	return 0

func updateButtons():
	smart_button_grid.clearButtons(false)
	var _i:int = 0
	for buttonEntry in buttonsCache:
		smart_button_grid.addButton(SmartGridButtonEntry.make(buttonEntry["name"], "act", [_i], buttonEntry["cat"]))
		_i += 1
	
func _process(_delta: float) -> void:
	if(!is_instance_valid(pawn) || !pawn):
		setPawn(null)
	var newSexEngine:SexEngine = GM.sexManager.getSexEngineOfPawn(pawn)
	if(newSexEngine != sexEngine):
		setEngine(newSexEngine)
		if(newSexEngine):
			visible = true
			updateAutoConsentCheckbox()
		else:
			visible = false
	if(!sexEngine):
		visible = false
		return
	
	var newButtons:Array = calculateButtons()
	
	if(newButtons != buttonsCache):
		buttonsCache = newButtons

		updateButtons()
	
	var progressBarValue:float = sexEngine.getProgressBarValue()
	if(progressBarValue >= 0.0):
		action_progress_bar.value = clamp(progressBarValue, 0.0, 1.0)
		action_progress_bar.visible = true
	else:
		action_progress_bar.visible = false
	
	sexEngine.processCameraControl(_delta, controllingCamera)
	
	var actionText:String = sexEngine.getActionText()
	if(actionText != actionTextCache):
		action_text_label.text = actionText
		actionTextCache = actionText
		action_text_label.visible = !action_text_label.text.is_empty()


func _on_free_camera_button_pressed() -> void:
	sexEngine.setCameraMode(SexEngine.CAMERA_FREE)

func _on_locked_camera_button_pressed() -> void:
	sexEngine.setCameraMode(SexEngine.CAMERA_LOCKED)

func shouldCaptureMouse() -> bool:
	if(!is_visible_in_tree()):
		return false
	if(controllingCamera):
		return true
	return false

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("game_chat")):
		if(!UIHandler.isMenuInputBlocked() && !get_viewport().gui_get_focus_owner()):
			chat_widget.grabLineEditFocus()

func _on_empty_space_gui_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		if(event.button_index == MOUSE_BUTTON_LEFT):
			if(event.pressed):
				UIHandler.releaseUIFocus()
		
		if(event.button_index == MOUSE_BUTTON_RIGHT):
			if(event.pressed):
				UIHandler.releaseUIFocus()
				controllingCamera = true
			else:
				controllingCamera = false

func _input(event: InputEvent) -> void:
	if(controllingCamera && event is InputEventMouseMotion):
		var mouseD:Vector2 = event.relative
		sexEngine.processCameraMouseMotion(mouseD)

func playQuickFade():
	fade_anim_player.play("QuickFade")
	#fade_anim_player.seek(0.0, true)

func _on_auto_consent_check_box_toggled(toggled_on: bool) -> void:
	if(!getEngine() || !pawn):
		return
	getEngine().askSetParticipantAutoConsent(pawn.getCharID(), toggled_on)

func updateSexParticipantsList():
	Util.delete_children(participants_list)
	
	if(!getEngine()):
		return
	for charID in getEngine().participants:
		var character:BaseCharacter = GM.characterRegistry.getCharacter(charID)
		if(!character):
			continue
		
		var newEntry:SexParticipantUIEntry = sexParticipantUIEntryScene.instantiate()
		participants_list.add_child(newEntry)
		newEntry.setCharID(charID)
		
func _on_smart_button_grid_on_button_pressed(_buttonEntry: SmartGridButtonEntry) -> void:
	if(_buttonEntry.actionID == "act"):
		onActionButtonPressed(_buttonEntry.actionArgs[0])
	
	smart_button_grid.clearButtons()
	buttonsCache.clear()

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
@onready var forcing_check: CheckBox = %ForcingCheck
@onready var resist_minigame: ResistMinigame = %ResistMinigame
@onready var grip_bar: ProgressBar = %GripBar
@onready var sex_desc_label: RichTextLabel = %SexDescLabel
@onready var ai_check: CheckBox = %AICheck

var sexParticipantUIEntryScene := preload("res://Game/Sex/UI/sex_participant_ui_entry.tscn")

var sexEngine:SexEngine
var pawn:CharacterPawn

var buttonsCache:Array = []

var actionTextCache:String = ""

var controllingCamera:bool = false

func _enter_tree() -> void:
	UIHandler.addUI(self, UIHandler.CLOSE_IGNORE)
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

func getResist() -> ResistMinigameNode:
	return sexEngine.resistMinigame if sexEngine else null

func setEngine(theEngine:SexEngine):
	if(sexEngine):
		sexEngine.onAnimSceneSwitched.disconnect(onSexEngineAnimSceneSwitched)
		sexEngine.onParticipantUpdate.disconnect(onSexEngineParticipantUpdate)
		sexEngine.onSexChange.disconnect(onSexEngineChange)
		sexEngine.resistMinigame.onUpdate.disconnect(onResistMinigameUpdate)
	sexEngine = theEngine
	if(sexEngine):
		sexEngine.onAnimSceneSwitched.connect(onSexEngineAnimSceneSwitched)
		sexEngine.onParticipantUpdate.connect(onSexEngineParticipantUpdate)
		sexEngine.onSexChange.connect(onSexEngineChange)
		sexEngine.resistMinigame.onUpdate.connect(onResistMinigameUpdate)
		playQuickFade()
	
	updateSexParticipantsList()
	updateResistMinigame()

func onSexEngineChange(_change:SexEngineChange):
	if(_change.type == SexEngineChange.MODE_CHANGE):
		updateSexSettingsUI()

func onSexEngineParticipantUpdate(_charID:String):
	if(!pawn || !getEngine()):
		return
	updateSexParticipantsList()
	var ourID:String = pawn.getCharID()
	if(ourID != _charID):
		return
	updateSexSettingsUI()

func getSexParticipantInfo() -> SexParticipantInfo:
	if(!pawn || !getEngine()):
		return
	var ourID:String = pawn.getCharID()
	var participant:SexParticipantInfo = getEngine().getParticipant(ourID)
	if(!participant):
		return null
	return participant

func getSexParticipantID() -> String:
	if(!pawn || !getEngine()):
		return ""
	var ourID:String = pawn.getCharID()
	return ourID

func updateRightPanel():
	updateSexSettingsUI()
	updateSexParticipantsList()

func updateSexSettingsUI():
	var theEngine := getEngine()
	if(!theEngine):
		return
	updateAutoConsentCheckbox()
	forcing_check.set_pressed_no_signal(theEngine.isForced())
	updateResistMinigame()
	
func updateAutoConsentCheckbox():
	var participant:SexParticipantInfo = getSexParticipantInfo()
	if(!participant):
		return
	var hasAutoConsent:bool = participant.isAutoConsentToggledOn()
	
	auto_consent_check_box.set_pressed_no_signal(hasAutoConsent)
	ai_check.set_pressed_no_signal(participant.pcAuto)

func onSexEngineAnimSceneSwitched():
	playQuickFade()

func setPawn(thePawn:CharacterPawn):
	pawn = thePawn
	updateSexSettingsUI()

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
		if(buttonEntry.has("dis") && buttonEntry["dis"]):
			smart_button_grid.addButton(SmartGridButtonEntry.makeDisabled(buttonEntry["name"], buttonEntry["cat"]))
		else:
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
			updateSexSettingsUI()
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
	
	var actionText:String = sexEngine.parseText(sexEngine.getActionText())
	if(actionText != actionTextCache):
		action_text_label.text = actionText
		actionTextCache = actionText
		action_text_label.visible = !action_text_label.text.is_empty()
	
	if(resist_minigame.visible):
		processResistMinigame(_delta)
	
	updateSexControlButtonsAndText()

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
	var theInfo := getSexParticipantInfo()
	if(!theInfo):
		return
	
	theInfo.autoConsent = toggled_on
	theInfo.syncUserOptions()
	#getEngine().askSetParticipantAutoConsent(pawn.getCharID(), toggled_on)

func updateSexParticipantsList():
	Util.delete_children(participants_list)
	
	var theEngine := getEngine()
	if(!theEngine):
		return
	for charID in getEngine().participants:
		var character:BaseCharacter = GM.characterRegistry.getCharacter(charID)
		if(!character):
			continue
		
		var newEntry:SexParticipantUIEntry = sexParticipantUIEntryScene.instantiate()
		participants_list.add_child(newEntry)
		newEntry.setInfo(theEngine.getInfo(charID))
		
func _on_smart_button_grid_on_button_pressed(_buttonEntry: SmartGridButtonEntry) -> void:
	if(_buttonEntry.actionID == "act"):
		onActionButtonPressed(_buttonEntry.actionArgs[0])
	
	smart_button_grid.clearButtons()
	buttonsCache.clear()

func _on_forcing_check_toggled(_toggled_on: bool) -> void:
	getEngine().askSetSexMode(SexEngine.MODE_FORCED if _toggled_on else SexEngine.MODE_NORMAL)

func processResistMinigame(_dt:float):
	var theID:String = pawn.getCharID() if pawn else ""
	var theMinigame := getResist()
	if(!theMinigame):
		return
	
	#resist_minigame.setTimeRaw(theMinigame.getCurTime(theID))
	resist_minigame.setSpeedRaw(theMinigame.getCurSpeed(theID))
	pass
	
func updateResistMinigame():
	var theMinigame := getResist()
	if(!theMinigame || theMinigame.isDisabled()):
		resist_minigame.visible = false
		smart_button_grid.visible = true
		return
	resist_minigame.visible = true
	smart_button_grid.visible = false
	
	resist_minigame.setResultLabel(theMinigame.resultText)
	resist_minigame.setState(theMinigame.state)
	resist_minigame.setTimerBar(theMinigame.timeFull, theMinigame.time)
	resist_minigame.setRedZone(theMinigame.target, theMinigame.yellowZone)
	
	resist_minigame.setIsFrozen(theMinigame.resultMarks.has(pawn.getCharID()))
	
	resist_minigame.clearSmallMarkers()
	for theCharID in theMinigame.resultMarks:
		var thePos:float = theMinigame.resultMarks[theCharID]
		
		var theCharName:String = theCharID
		if(theCharID == pawn.getCharID()):
			theCharName = "you"
		else:
			var theChar:BaseCharacter = GM.characterRegistry.getCharacter(theCharID)
			if(theChar):
				theCharName = theChar.getName()
		
		resist_minigame.addSmallMarker(thePos, theCharName)
	
	#processResistMinigame(0.0)
	#updateRunningMarksForResistMinigame()

func onResistMinigameUpdate(_updateType:int):
	if(_updateType == ResistMinigameNode.RESIST_START):
		var theMinigame := getResist()
		if(theMinigame):
			var theID:String = pawn.getCharID() if pawn else ""
			resist_minigame.setTimeRaw(theMinigame.getCurTime(theID))
			resist_minigame.setSpeedRaw(theMinigame.getCurSpeed(theID))
			
			#updateRunningMarksForResistMinigame()
				
			#resist_minigame.setMainMarkerPos(RNG.randfRange(0.0, 1.0))
	updateResistMinigame()

#unused
func updateRunningMarksForResistMinigame():
	var theMinigame := getResist()
	if(!theMinigame):
		return
	var theID:String = pawn.getCharID() if pawn else ""
	var theRunningMarks:Array = []
	for theCharID in theMinigame.times:
		if(theCharID == theID || theMinigame.resultMarks.has(theCharID)):
			continue
		theRunningMarks.append([theCharID, theMinigame.times[theCharID], theMinigame.speeds[theCharID]])
	resist_minigame.setRunningMarkers(theRunningMarks)

func _on_resist_minigame_on_click(_pos: float) -> void:
	var theResist := getResist()
	if(!theResist):
		return
	theResist.pushResult(pawn.getCharID(), _pos)

func canDoDomActions() -> bool:
	var theEngine:= getEngine()
	if(!theEngine || !pawn):
		return false
	return theEngine.canDoDomActions(pawn.getCharID())

func canDoAnyActions() -> bool:
	var theEngine:= getEngine()
	if(!theEngine || !pawn):
		return false
	return theEngine.isCharIDInvolved(pawn.getCharID())

var savedSexDescText:String = " "
func updateSexControlButtonsAndText():
	var theEngine := getEngine()
	if(!theEngine):
		return
	grip_bar.value = clamp(theEngine.getGripLevel(), 0.0, 1.0)
	
	var _canDoDomActions:bool = canDoDomActions()
	forcing_check.visible = _canDoDomActions
	
	var sexDescs:Array[String] = []
	
	if(!_canDoDomActions):
		if(theEngine.isForced()):
			sexDescs.append("[color=red]Forcing mode[/color]")
	
	var newSavedSexDescText:String = Util.join(sexDescs, "\n")
	if(newSavedSexDescText != savedSexDescText):
		savedSexDescText = newSavedSexDescText
		sex_desc_label.text = newSavedSexDescText
		sex_desc_label.visible = !newSavedSexDescText.is_empty()

func _on_ai_check_toggled(_toggled_on: bool) -> void:
	var theInfo := getSexParticipantInfo()
	if(!theInfo):
		return
	theInfo.pcAuto = _toggled_on
	theInfo.syncUserOptions()

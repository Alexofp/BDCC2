extends Control
class_name CombatUI

@export var menuToConnectTo:Control

@onready var stats_bars: VBoxContainer = %StatsBars
@onready var pain_bar: PanelContainer = %PainBar
@onready var recovery_bar: PanelContainer = %RecoveryBar
@onready var exhaustion_bar: PanelContainer = %ExhaustionBar
@onready var strain_bar: PanelContainer = %StrainBar

var shouldBarsBeVisible := false
var keepUITimer:float = 0.0

func _physics_process(_delta: float) -> void:
	var currentPawn := GM.pcPawn
	
	if(!currentPawn):
		visible = false
		return
	visible = true
	
	var theChar := currentPawn.getCharacter()
	var thePain := theChar.getCharState().getPainLevel()
	var theExhaustionLevel := currentPawn.combatMovePlayer.getExhaustionLevel()
	var theExhaustion := currentPawn.combatMovePlayer.getExhaustion()
	var theStrain := currentPawn.combatMovePlayer.getStrainLevel()
	var theStrainHaveEffectLevel := currentPawn.combatMovePlayer.getStrainHaveEffectLevel()
	
	var shouldShowCombatUI:bool = currentPawn.state.shouldShowCombatUI()
	if(menuToConnectTo && menuToConnectTo.is_visible_in_tree()):
		shouldShowCombatUI = true
	if(pain_bar.setValue(thePain)):
		shouldShowCombatUI = true
	if(exhaustion_bar.setValue(theExhaustionLevel)):
		shouldShowCombatUI = true
	if(strain_bar.setValue(theStrain) && theStrain >= theStrainHaveEffectLevel):
		shouldShowCombatUI = true
	
	if(theStrain >= theStrainHaveEffectLevel):
		strain_bar.visible = true
	else:
		strain_bar.visible = false
	
	if(shouldShowCombatUI):
		fadeIn()
		keepUITimer = 3.0
	else:
		if(keepUITimer > 0.0):
			keepUITimer -= _delta
		else:
			fadeOut()
	
	var thePainRaw := theChar.getCharState().getPain()
	var thePainMax := theChar.getCharState().getPainMax()
	
	pain_bar.setRightText(rawValueToStr(thePainRaw)+"/"+rawValueToStr(thePainMax))
	exhaustion_bar.setRightText(rawValueToStr(theExhaustion)+"%")
	strain_bar.setRightText(rawValueToStr(theStrain)+"%")
	if(currentPawn.isDefeated()):
		recovery_bar.visible = true
		recovery_bar.setRightText(str(int(currentPawn.getDefeatRecoveryTime())))
	else:
		recovery_bar.visible = false
		

func rawValueToStr(_val:float) -> String:
	return str(int(ceil(_val*100.0)))

var fadeTween:Tween
func fadeIn():
	if(!shouldBarsBeVisible):
		return
	shouldBarsBeVisible = false

	if(fadeTween):
		fadeTween.kill()
	fadeTween = create_tween()
	fadeTween.tween_property(stats_bars, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func fadeOut():
	if(shouldBarsBeVisible):
		return
	shouldBarsBeVisible = true
	
	if(fadeTween):
		fadeTween.kill()
	fadeTween = create_tween()
	fadeTween.tween_property(stats_bars, "modulate", Color.TRANSPARENT, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

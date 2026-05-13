extends InteractionBase

func _init() -> void:
	id = "FriendlyFight"

func getRequiredRoles(_args:Array) -> Dictionary[int, String]:
	return {
		ROLE_MAIN: "main",
		ROLE_TARGET: "target",
	}

func start(_roles:Dictionary, _args:Array):
	lookAt(ROLE_MAIN, ROLE_TARGET)
	sayText(ROLE_MAIN, "Let's FIGHT!")
	
	getPawn(ROLE_MAIN).combatAI.addEnemy(getPawn(ROLE_TARGET), CombatPawnAI.ENEMY_FRIENDLY_FIGHT)
	getPawn(ROLE_TARGET).combatAI.addEnemy(getPawn(ROLE_MAIN), CombatPawnAI.ENEMY_FRIENDLY_FIGHT)

func onEnd():
	var theTarget := getPawn(ROLE_TARGET)
	var theMain := getPawn(ROLE_MAIN)
	
	if(theTarget && theMain):
		theMain.combatAI.removeEnemy(theTarget)
		theTarget.combatAI.removeEnemy(theMain)
		
		theMain.ai.goalHandler.addGoal("HelpGetUp", [theTarget.getCharID()])
		theTarget.ai.goalHandler.addGoal("HelpGetUp", [theMain.getCharID()])

func processRare(_dt:float):
	if(getDistanceBetween(ROLE_MAIN, ROLE_TARGET) > 10.0):
		stopInteraction()
	elif(getPawn(ROLE_MAIN).isDefeated() || getPawn(ROLE_TARGET).isDefeated()):
		sayText(ROLE_MAIN, "IT'S OVER!")
		stopInteraction()
	else:
		getPawn(ROLE_MAIN).combatAI.addEnemy(getPawn(ROLE_TARGET), CombatPawnAI.ENEMY_FRIENDLY_FIGHT)
		getPawn(ROLE_TARGET).combatAI.addEnemy(getPawn(ROLE_MAIN), CombatPawnAI.ENEMY_FRIENDLY_FIGHT)

func plan(_role:int, _action:AIActionBase) -> AIPlan:
	return _action.makePlan().add("Combat")

func onGettingHit(_role:int, _attackContext:AttackContext) -> bool:
	if(_attackContext.attacker != getPawn(ROLE_MAIN) && _attackContext.attacker != getPawn(ROLE_TARGET)):
		stopInteraction()
		return false
	#getPawn().combatAI.addEnemy(_attackContext.attacker)
	#startSubActionUnlessSameTag("Combat")
	return true

func isHandlingCombat(_role:int) -> bool:
	return true

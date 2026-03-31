extends RefCounted
class_name AIGoalBase

var id:String = "error"
var pawn:CharacterPawn
#var savedPlan:AIPlan

var handlingInteractions:Array[String] # The IDs of the interactions that this goal wants to handle the actions of
var mainGoal:bool = true # if false, the goal will only influence the existing actions, not give new ones
var wasDeleted:bool = false
var importantGoal:bool = false

# FUNCTIONS TO OVERRIDE

func getName() -> String:
	return id

# Goals are sorted by priority once a second
# Higher priority -> checked first
func getPriority() -> float:
	return 0.0

func isImpossible() -> bool:
	return false

# Important goals are prioritized no matter what
func isImportant() -> bool:
	return importantGoal

# Add the interaction id into handlingInteractions array first
func getInteractionActionScoreOverride(_interaction:InteractionBase, _action:InteractionAction, _score:float) -> float:
	return _score

# Us performing a certain action, called after that action
func handleInteractionAction(_interaction:InteractionBase, _action:InteractionAction) -> bool:
	return false

func start(_args:Array):
	pass

func processRare(_dt:float):
	pass

# Not implemented
func isSame(_existingGoal:AIGoalBase) -> bool:
	if(id == _existingGoal.id):
		return true
	return false

func getKeepScore() -> float:
	return maxf(getScore() + 0.1, 1.0)

func getScore() -> float:
	return 0.0

func isMainGoal() -> bool:
	return mainGoal

func getPlan() -> AIPlan:
	return null

func onPlanCompleted(_plan:AIPlan):
	satisfyGoal()

func onPlanFail(_plan:AIPlan, _failedAction:AIActionBase, _failStatus:int):
	failGoal()

# Not implemented
func onAction(_action:PawnActionBase, _context:PawnActionContext):
	pass

# Not implemented
func onDelayedAction(_action:ActionSystemEntry, _context:PawnActionContext):
	pass

# FUNCTIONS TO OVERRIDE END

func stopMe():
	if(!pawn):
		return
	pawn.ai.goalHandler.removeGoal(self)

func satisfyGoal():
	stopMe()

func failGoal():
	stopMe()

func processRareFinal(_dt:float):
	processRare(_dt)

func startFinal(_args:Array):
	start(_args)

func getPawn(_id:String) -> CharacterPawn:
	return GM.main.pawn_registry.getPawn(_id)

func setPawn(_p:CharacterPawn):
	pawn = _p

func makePlan(_id:String = "") -> AIPlan:
	var newPlan:AIPlan = AIPlan.new()
	newPlan.id = _id
	return newPlan

func isStaticGoal() -> bool:
	return false

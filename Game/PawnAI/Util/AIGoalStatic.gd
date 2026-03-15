extends AIGoalBase
class_name AIGoalStatic

## Static AI goals are always added to the pawn AI and never removed

func isStaticGoal() -> bool:
	return true

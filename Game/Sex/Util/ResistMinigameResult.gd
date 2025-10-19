extends RefCounted
class_name ResistMinigameResult

var team1win:bool = true

func didTeam1Win() -> bool:
	return team1win

func didTeam2Win() -> bool:
	return !team1win

func didDomsWin() -> bool:
	return team1win

func didSubsWin() -> bool:
	return !team1win

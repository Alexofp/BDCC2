@tool
extends PropBasic

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func getEditorOptionsEasy() -> Dictionary:
	return {
		#"roughness": {type="roughness"},
		#"colorbase": {type="color"},
		#"color1": {type="color"},
	}

func setAnimNormal():
	animation_player.play("Stocks_Normal", 0.2)

func setAnimStanding():
	animation_player.play("Stocks_Standing", 0.2)

@tool
extends PropBasic

@onready var skeleton_3d: Skeleton3D = %Skeleton3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var stocks_anim_handler: Node3D = %StocksAnimHandler

func getEditorOptionsEasy() -> Dictionary:
	return {
		#"roughness": {type="roughness"},
		#"colorbase": {type="color"},
		#"color1": {type="color"},
	}

func getPropSkeleton() -> Skeleton3D:
	return skeleton_3d

func onPropSpotChanged(_propSpot:PropSpot):
	if(!_propSpot):
		skeleton_3d.reset_bone_poses()
		#animation_player.play("Stocks_Normal", 0.3)
		animation_player.play("Stocks_Open", 0.3)
		animation_player.active = true
		#Log.Print("PROP IS NO LONGER INVOLVED IN A SCENE")
	else:
		animation_player.active = false
		#Log.Print("PROP BECAME INVOLVED IN A SCENE")

func getStocksHandler() -> Node3D:
	return stocks_anim_handler

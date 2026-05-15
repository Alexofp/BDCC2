@tool
extends PropBasic

@onready var skeleton_3d: Skeleton3D = %Skeleton3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var stocks_anim_handler: Node3D = %StocksAnimHandler
@onready var stocks_test: MeshInstance3D = %StocksTest

@export var colorbase:Color = Color("ba6b2f"):
	set(value):
		colorbase = value
		notifySetEditorValue("colorbase", value)
@export var color1:Color = Color("8c8680"):
	set(value):
		color1 = value
		notifySetEditorValue("color1", value)
@export var color2:Color = Color("ffbe9e"):
	set(value):
		color2 = value
		notifySetEditorValue("color2", value)
@export var color3:Color = Color("ff7700"):
	set(value):
		color3 = value
		notifySetEditorValue("color3", value)

func applyEditorOption(_id, _value):
	if(!%StocksTest):
		return
	var theMat:ShaderMaterial = %StocksTest.get_active_material(0)
	if(!theMat):
		return
	match _id:
		#"roughness":
		#	setInstanceShaderParameter("roughness_mult", _value)
		"colorbase":
			theMat.set_shader_parameter("color_mask_r", _value)
			#setInstanceShaderParameter("trim_color_base", _value)
		"color1":
			theMat.set_shader_parameter("color_mask_g", _value)
			#setInstanceShaderParameter("trim_color_main", _value)
		"color2":
			theMat.set_shader_parameter("color_mask_b", _value)
			#setInstanceShaderParameter("trim_color_second", _value)
		"color3":
			theMat.set_shader_parameter("emission", _value)
			#setInstanceShaderParameter("trim_color_third", _value)

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

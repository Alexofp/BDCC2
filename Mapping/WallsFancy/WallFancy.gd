@tool
extends PropBasic

@export var panel1:MeshInstance3D
@export var panel2:MeshInstance3D

@export var roughness:float = 0.5:
	set(value):
		roughness = value
		setInstanceShaderParameter("roughness_mult", roughness)
@export var color1:Color = Color("242424"):
	set(value):
		color1 = value
		setInstanceShaderParameter("trim_color_base", color1)
@export var color2:Color = Color("292833"):
	set(value):
		color2 = value
		setInstanceShaderParameter("trim_color_main", color2)
@export var color3:Color = Color("121212"):
	set(value):
		color3 = value
		setInstanceShaderParameter("trim_color_second", color3)
@export var color4:Color = Color("19315c"):
	set(value):
		color4 = value
		setInstanceShaderParameter("trim_color_third", color4)
@export var panelMat:TilableWallMat.Mats = TilableWallMat.Mats.Hexagon:
	set(value):
		panelMat = value
		updateMat()
@export var colorPanel:Color = Color("404040"):
	set(value):
		colorPanel = value
		if(panel1 != null):
			panel1.set_instance_shader_parameter("color_tile_base", colorPanel)
@export var panelMat2:TilableWallMat.Mats = TilableWallMat.Mats.Hexagon:
	set(value):
		panelMat2 = value
		updateMat2()
@export var colorPanel2:Color = Color("6b7380"):
	set(value):
		colorPanel2 = value
		if(panel2 != null):
			panel2.set_instance_shader_parameter("color_tile_base", colorPanel2)

func _ready() -> void:
	super._ready()
	setInstanceShaderParameter("uvShift", 0.0)

func updateMat():
	var theFinalMat:Material = null
	
	if(TilableWallMat.MatToPath.has(panelMat)):
		theFinalMat = load(TilableWallMat.MatToPath[panelMat])
	#elif(!floorMatCustom.is_empty() && ResourceLoader.exists(floorMatCustom)):
	#	theFinalMat = load(floorMatCustom)
	
	if(panel1 != null):
		panel1.set_surface_override_material(0, theFinalMat)

func updateMat2():
	var theFinalMat:Material = null
	
	if(TilableWallMat.MatToPath.has(panelMat2)):
		theFinalMat = load(TilableWallMat.MatToPath[panelMat2])
	#elif(!floorMatCustom.is_empty() && ResourceLoader.exists(floorMatCustom)):
	#	theFinalMat = load(floorMatCustom)
	
	if(panel2 != null):
		panel2.set_surface_override_material(0, theFinalMat)

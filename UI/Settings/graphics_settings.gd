extends Control
@onready var settings_list: VarList = %SettingsList
@onready var fps_label: Label = %FPSLabel

var last_tick:int = 0
var frametimes:Array = []
var gpuFrametimes:Array = []

func _ready():
	updateSettingsList()
	last_tick = Time.get_ticks_usec()

func updateSettingsList():
	settings_list.setVars(OPTIONS.graphics.getSettingsWithValues())

func _on_settings_list_on_var_change(id: Variant, value: Variant) -> void:
	OPTIONS.graphics.setSettingValue(id, value)

func _process(_delta: float) -> void:
	var viewport_rid := get_viewport().get_viewport_rid()
	var frametime_gpu := RenderingServer.viewport_get_measured_render_time_gpu(viewport_rid)
	gpuFrametimes.append(frametime_gpu)
	while(gpuFrametimes.size() > 60):
		gpuFrametimes.pop_front()
		
	var frametime := (Time.get_ticks_usec() - last_tick) * 0.001
	frametimes.append(frametime)
	while(frametimes.size() > 60):
		frametimes.pop_front()
	
	var avgFrametime:float = 0.0
	for theFT in frametimes:
		avgFrametime += theFT
	if(!frametimes.is_empty()):
		avgFrametime /= float(frametimes.size())
	
	var avgGPUFrametime:float = 0.0
	for theFT in gpuFrametimes:
		avgGPUFrametime += theFT
	if(!gpuFrametimes.is_empty()):
		avgGPUFrametime /= float(gpuFrametimes.size())
	
	
	var fps:int= int(1000.0 / (avgFrametime if avgFrametime > 0.01 else 0.01))
	
	fps_label.text = "FPS: "+str(fps)+" ("+str(round(avgFrametime*100.0)/100.0)+"ms)"+"\nGPU memory used: " + str(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1024.0/1024.0).pad_decimals(2)+" MB"+"\nGPU frametime: "+str(round(avgGPUFrametime*100.0)/100.0)+"ms"
	
	last_tick = Time.get_ticks_usec()

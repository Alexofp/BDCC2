extends Node
class_name ShaderCompilationTracker

const SHADER_TRACKER_ENABLED = false

var wave:int = 0

var pipelineAmounts:Dictionary[int, int] = {}
const TRACKED_PIPELINES = {
	#Performance.PIPELINE_COMPILATIONS_CANVAS: "Canvas",
	Performance.PIPELINE_COMPILATIONS_MESH: "Mesh",
	Performance.PIPELINE_COMPILATIONS_SURFACE: "Surface",
	Performance.PIPELINE_COMPILATIONS_DRAW: "Draw",
	#Performance.PIPELINE_COMPILATIONS_SPECIALIZATION: "Special",
}

func setShouldCheck(_c:bool):
	set_process(_c)

func _ready() -> void:
	for pipelineID in TRACKED_PIPELINES:
		pipelineAmounts[pipelineID] = 0

func _process(_delta: float) -> void:
	if(!SHADER_TRACKER_ENABLED):
		set_process(false)
		return
	var newStuff:Dictionary[int, int] = {}
	
	for pipelineID in TRACKED_PIPELINES:
		var newVal:int = int(Performance.get_monitor(pipelineID))
		
		if(newVal != pipelineAmounts[pipelineID]):
			var diff:int = newVal - pipelineAmounts[pipelineID]
			newStuff[pipelineID] = diff
			pipelineAmounts[pipelineID] = newVal
	
	if(newStuff.is_empty()):
		return
	
	var reportTexts:Array[String] =  []
	for pipelineID in newStuff:
		var pipelineName:String = TRACKED_PIPELINES[pipelineID]
		reportTexts.append(pipelineName+" (+"+str(newStuff[pipelineID])+")")
	
	wave += 1
	var finalReportText:String = "(wave "+str(wave)+") NEW SHADERS: " + join(reportTexts, ", ")
	
	Log.Print(finalReportText)

func join(arr: Array, separator: String = "") -> String:
	var output = ""
	for s in arr:
		output += str(s) + separator
	output = output.left( output.length() - separator.length() )
	return output

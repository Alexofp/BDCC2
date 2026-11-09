extends DATLayer
class_name DATAnim

var instantEnable:bool = false # Skip fade-in interpolation when the layer is enabled. Useful for locomotion/most-lowest level

func createRunLayer() -> DATLayerRun:
	var theLayer:DATAnimRun = DATAnimRun.new()
	return theLayer

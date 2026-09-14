extends DollPart

@onready var chastity_cage_handler: ChastityCageHandler = %ChastityCageHandler
@onready var cage: Node3D = %Cage

func gatherPartFlags(_theFlags:Dictionary):
	_theFlags["CageType"] = "CageFlat"

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HidePenis") && _theFlags["HidePenis"]):
		cage.visible = false
	else:
		cage.visible = true

func getPenisHandler() -> PenisHandlerBase:
	return chastity_cage_handler

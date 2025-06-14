extends AIActionBase

var timer:float = 5.0

func _init() -> void:
	id = "Wait"

func start(_args:Array):
	if(_args.size() > 0):
		timer = _args[0]
	stopWalking()

func processAction(_dt:float):
	timer -= _dt
	if(timer <= 0.0):
		completeAction()

func processRare():
	pass

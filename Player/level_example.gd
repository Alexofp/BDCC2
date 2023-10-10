extends Node3D

@onready var baseCharacter: BaseCharacter = $BaseCharacter

# Called when the node enters the scene tree for the first time.
func _ready():
	$Doll.setCharacter(baseCharacter)

	var silly:BaseBodypart = baseCharacter.getRootBodypart().getBodypart(BodypartSlot.Head).setBodypart(BodypartSlot.RightEar, BaseHeadBodypart.new())
	silly.setBodypart(BodypartSlot.LeftEar, BaseEarBodypart.new())
	silly.setBodypart(BodypartSlot.RightEar, BaseEarBodypart.new())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

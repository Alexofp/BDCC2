extends Node3D

@onready var baseCharacter: BaseCharacter = $BaseCharacter

func _init():
	GlobalRegistry.doInit()

# Called when the node enters the scene tree for the first time.
func _ready():
	UiHandler.addUI($CanvasLayer)
	
	baseCharacter.getRootBodypart().setBodypart(BodypartSlot.Head, GlobalRegistry.createBodypart("FelineHeadNew"))
	
	$Doll.getDoll().setCharacter(baseCharacter)
	$Doll3.getDoll().setCharacter(baseCharacter)

	#var silly:BaseBodypart = baseCharacter.getRootBodypart().getBodypart(BodypartSlot.Head).setBodypart(BodypartSlot.RightEar, BaseHeadBodypart.new())
	#silly.setBodypart(BodypartSlot.LeftEar, BaseEarBodypart.new())
	#silly.setBodypart(BodypartSlot.RightEar, BaseEarBodypart.new())
	
	#baseCharacter.getRootBodypart().getBodypart(BodypartSlot.Head).removeBodypart(BodypartSlot.RightEar)
	#baseCharacter.getRootBodypart().getBodypart(BodypartSlot.Head).setBodypart(BodypartSlot.RightEar, BaseEarBodypart.new())

	$Doll2.getDoll().setCharacter(baseCharacter)
	
	baseCharacter.getRootBodypart().getBodypart(BodypartSlot.Head).addExtraPart(GlobalRegistry.createExtraPart("FelineHeadWhiskers"))
	
	#baseCharacter.getRootBodypart().setOptionValue("thickbutt", 1.0)
	
	$CanvasLayer/CharacterCreator.setCharacter(baseCharacter)
	
	#$Doll.queue_free()
	#$Doll2.queue_free()
	#$Doll3.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("debug_showcharactercreator"):
		$CanvasLayer.visible = !$CanvasLayer.visible
		
	if(Input.is_action_just_pressed("debug_F1")):
		#baseCharacter.getInventory().equipItem(GlobalRegistry.createItem("TestHat"))
		#baseCharacter.getInventory().equipItem(GlobalRegistry.createItem("TestPanties"))
		#baseCharacter.getInventory().equipItem(GlobalRegistry.createItem("TestBra"))
		baseCharacter.getInventory().equipItem(GlobalRegistry.createItem("TestShirt"))
		baseCharacter.getInventory().equipItem(GlobalRegistry.createItem("TestShorts"))
	if(Input.is_action_just_pressed("debug_F2")):
		#baseCharacter.getInventory().clearSlot(InventorySlot.Hat)
		baseCharacter.getInventory().clearSlot(InventorySlot.UnderwearBottom)
		baseCharacter.getInventory().clearSlot(InventorySlot.UnderwearTop)
		baseCharacter.getInventory().clearSlot(InventorySlot.Legs)
		baseCharacter.getInventory().clearSlot(InventorySlot.Chest)

func removeShirt():
	baseCharacter.getInventory().clearSlot(InventorySlot.Chest)

func addShirt():
	baseCharacter.getInventory().equipItem(GlobalRegistry.createItem("TestTShirt"))

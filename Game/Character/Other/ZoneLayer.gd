extends Object
class_name ZoneLayer

# Higher number = above
# Lower number = below
# 0.0 = skin

const Hat = 25.0 # Hat goes above everything!
const EyeCover = 20.0 #Blindfolds, glasses
const MouthCover = 19.0 #Gags, cloth masks
const Collar = 17.0 # A neck collar goes above the hood
const Hood = 15.0 # Skin-tight hood that covers the whole head and neck

const Wrists = 10.3 # Cuffs go above any top or bottom
const Ankles = 10.2 # Cuffs go above any top or bottom
const Top = 10.0 #T-Shirt, top. The most default layer possible
const Bottom = 9.0 # Shorts, pants. Worn under the top

const UnderwearTop = 5.0 #Bra
const NippleAttach = 4.5 # Under the top

const UnderwearBottom = 4.0 #Panties
const CrotchAttach = 3.5 # Under the bottom, pussy tape, cages

const Bodysuit = 1.0 # Skin-tight bodysuit
const HolePlug = 0.5 # Buttplug, vaginal toy

const InvSlotToLayer = {
	InventorySlot.Eyes: EyeCover,
	InventorySlot.Mouth: MouthCover,
	InventorySlot.Collar: Collar,
	InventorySlot.Top: Top,
	InventorySlot.Bottom: Bottom,
	InventorySlot.Suit: Bodysuit,
	InventorySlot.Wrists: Wrists,
	InventorySlot.Ankles: Ankles,
	InventorySlot.Nipples: NippleAttach,
	InventorySlot.UnderwearTop: UnderwearTop,
	InventorySlot.UnderwearBottom: UnderwearBottom,
}

static func getDefaultFromInvSlot(_invSlot:int) -> float:
	if(InvSlotToLayer.has(_invSlot)):
		return InvSlotToLayer[_invSlot]
	return 6.9

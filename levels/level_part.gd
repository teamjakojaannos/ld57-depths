@tool
extends Resource
class_name LevelPart

@export var scenes: Array[PackedScene] = []
@export var allowed_placement: AllowedPlacement = AllowedPlacement.EITHER

@export var special_sequence: SpecialSequence = SpecialSequence.NONE

@export var blocks_left_utility: bool = false
@export var blocks_right_utility: bool = false

enum AllowedPlacement {
	## Can be placed to either of the slots
	EITHER,
	## Part can only be placed to the top slot
	TOP,
	## Part can only be placed to the bottom slot
	BOTTOM,
	## Part fills both of the slots
	DOUBLE_SIZE,
}

enum Slot {
	TOP,
	BOTTOM,
}

enum SpecialSequence {
	## The part is not part of any special sequence
	NONE,
	## Part is part of the crab bossfight sequence
	CRAB_RAVE,
	## Part is part of shop sequence
	SHOP,
}

func can_be_placed_in(slot: Slot) -> bool:
	match allowed_placement:
		AllowedPlacement.TOP:
			return slot == Slot.TOP
		AllowedPlacement.BOTTOM:
			return slot == Slot.BOTTOM
		# Only allow placing double-sized slots to bottom slot
		AllowedPlacement.DOUBLE_SIZE:
			return slot == Slot.BOTTOM
		_: # Either
			return true

static func other_slot(slot: Slot) -> Slot:
	return Slot.TOP if slot == Slot.BOTTOM else Slot.BOTTOM

extends Resource
class_name Spawnlist

## Minimum depth the player has to have reached to encounter this spawnlist.
## E.g. 0 means any floor can use this.
@export var min_depth: int = 0

## The maximum depth the player can have reached to encounter this spawnlist.
## Use -1 for no maximum.
@export var max_depth: int = -1

## Total (minimum) cost of the spawnables to attempt to spawn. May overflow. 
@export var total_cost: int = 5

## Enemy spawnables to use for this spawnlist
@export var enemies: Array[Spawnable]

## Level parts override to use for this spawnlist
@export var level_override: Array[LevelPart]

@export var special_sequence: LevelPart.SpecialSequence = LevelPart.SpecialSequence.NONE

@export var entry_text_override: Array[String] = []

var is_special: bool:
	get:
		return special_sequence != LevelPart.SpecialSequence.NONE

func is_valid_for_depth(depth: int) -> bool:
	if depth < min_depth:
		return false
	if max_depth == -1:
		return true
	if depth > max_depth:
		return false

	return true

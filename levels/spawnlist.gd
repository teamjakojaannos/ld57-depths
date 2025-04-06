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

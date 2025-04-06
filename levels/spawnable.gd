extends Resource
class_name Spawnable

## The scene to instantiate when spawning this
@export var prefab: PackedScene

## Any nodes added to a group with this name are considered a valid spawnpoint
@export var spawnpoint_group: StringName = "enemy_spawn"

## How much does it cost to spawn this
@export var spawn_cost: int = 1

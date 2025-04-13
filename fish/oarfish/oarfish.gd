@tool
extends CharacterBody2D
class_name Oarfish

@export var movement_speed: float = 75.0
@export var simulate_tail_in_editor: bool = false

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	if Engine.is_editor_hint():
		return

	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	actor_setup.call_deferred()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	set_movement_target(Vector2.ZERO)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _process(_delta: float) -> void:
	var reset_tail = Engine.is_editor_hint() && !simulate_tail_in_editor
	
	var anchor: Vector2 = $Head.global_position
	var first_segment_pos: Vector2 = Vector2.ZERO
	for segment in $Segments.get_children():
		if segment is OarfishSegment:
			var segment_pos = segment.global_position
			if first_segment_pos == Vector2.ZERO:
				first_segment_pos = segment_pos
			
			var direction: Vector2 = segment_pos - anchor
			if not direction.is_finite() || direction.is_zero_approx() || reset_tail:
				direction = Vector2.DOWN
			direction = direction.normalized()

			var new_pos = anchor + direction * segment.distance_constraint
			segment.global_position = new_pos
			anchor = new_pos

	if navigation_agent.target_position is Vector2:
		var head_pos: Vector2 = $Head.global_position
		var head_angle = head_pos.angle_to(navigation_agent.target_position)
		$Head.rotation = head_angle

func _physics_process(_delta):
	if Engine.is_editor_hint():
		return

	if Globals.player is Player:
		set_movement_target(Globals.player.global_position)

	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var physics_velocity = current_agent_position.direction_to(next_path_position) * movement_speed

	# This triggers avoidance calculations, which eventually emits the
	# velocity_computed signal on the navigation agent.
	navigation_agent.velocity = physics_velocity


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

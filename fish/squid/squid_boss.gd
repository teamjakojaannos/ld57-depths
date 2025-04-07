extends Node2D

var squid_level: SquidFightLevel

var attacks = []
var ready_to_attack = false
var fight_has_started = false

func _ready() -> void:
	var current_level = get_parent()
	if current_level is not SquidFightLevel:
		printerr("Squid is not in squid fight level!")
		return
	
	visible = false
	squid_level = current_level
	
	var attack_nodes = $Moves.get_children()
	for attack_node in attack_nodes:
		if attack_node is not SquidAttack:
			printerr("This node is not squid attack: ", attack_node.name)
		else:
			attacks.append(attack_node)

func _physics_process(_delta: float) -> void:
	if !ready_to_attack:
		return
	
	var attack: SquidAttack = attacks.pick_random()
	ready_to_attack = false
	attack.do_attack(squid_level)
	await attack.squid_attack_done
	await get_tree().create_timer(3.0).timeout
	ready_to_attack = true


func _on_start_fight_trigger_area_entered(_area: Area2D) -> void:
	if fight_has_started:
		return
	
	print("Starting squid fight!")
	
	fight_has_started = true
	$AnimationPlayer.play("emerge")
	await $AnimationPlayer.animation_finished
	ready_to_attack = true

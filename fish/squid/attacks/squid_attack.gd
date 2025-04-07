# generic attack class, meant to be extended by actual attacks
class_name SquidAttack
extends Node

signal squid_attack_done

func do_attack(level: SquidFightLevel):
	printerr("you forgot to implement functionality for your attack...")
	await get_tree().create_timer(1.0).timeout
	squid_attack_done.emit()

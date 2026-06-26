extends Area2D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	body_entered.connect(_on_body)


func _on_body(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.lose_life()

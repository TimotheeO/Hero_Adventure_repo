extends Area2D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	body_entered.connect(_on_body)


func _on_body(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("complete_level"):
		level.complete_level()

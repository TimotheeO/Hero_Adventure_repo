extends Area2D

@export var value: int = 1
var _taken := false


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	body_entered.connect(_on_body)


func _on_body(body: Node2D) -> void:
	if _taken or not body.is_in_group("player"):
		return
	_taken = true
	set_deferred("monitoring", false)
	GameManager.add_coins(value)
	AudioManager.play_sfx("coin")
	var t := create_tween()
	t.tween_property(self, "position:y", position.y - 16.0, 0.15)
	t.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
	t.tween_callback(queue_free)

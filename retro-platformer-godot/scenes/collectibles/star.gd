extends Area2D

@export var star_index: int = 0
var _collected := false


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	if SaveManager.has_star(GameManager.current_level, star_index):
		modulate.a = 0.3
	body_entered.connect(_on_body)


func _on_body(body: Node2D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	set_deferred("monitoring", false)
	if not SaveManager.has_star(GameManager.current_level, star_index):
		SaveManager.collect_star(GameManager.current_level, star_index)
		GameManager.add_star()
		AudioManager.play_sfx("star")
	var t := create_tween()
	t.tween_property(self, "scale", scale * 1.5, 0.15)
	t.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
	t.tween_callback(queue_free)

extends StaticBody2D
## Porte / passage bloque. S'ouvre quand tous les ennemis listes
## dans required_enemies sont morts. Assigner les ennemis dans l'inspecteur.

@export var required_enemies: Array[NodePath] = []

var _remaining: int = 0


func _ready() -> void:
	for path in required_enemies:
		var enemy := get_node_or_null(path)
		if enemy and enemy.has_signal("died"):
			_remaining += 1
			enemy.died.connect(_on_enemy_died)
	if _remaining == 0:
		open()


func _on_enemy_died() -> void:
	_remaining -= 1
	if _remaining <= 0:
		open()


func open() -> void:
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

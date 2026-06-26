extends Area2D
## Fleche. Detruite au contact d'un ennemi, d'un mur, ou apres lifetime.

@export var speed: float = 420.0
@export var damage: int = 1
@export var lifetime: float = 2.5

var direction := 1
var _hit := false


func _ready() -> void:
	collision_layer = 1
	collision_mask = 5   # sol(1) + ennemis(4)
	var spr := get_node_or_null("Sprite2D")
	if spr and direction < 0:
		spr.flip_h = true
	body_entered.connect(_on_body)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta


func _on_body(body: Node) -> void:
	if _hit or body.is_in_group("player"):
		return
	_hit = true
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

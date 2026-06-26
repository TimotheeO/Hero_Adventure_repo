extends Area2D
## Hitbox epee. attack(facing) la place devant le joueur et l'active brievement.

@export var damage: int = 1
@export var cooldown: float = 0.4
@export var active_time: float = 0.18

var _can_attack := true
var _reach := 24.0


func _ready() -> void:
	_reach = absf(position.x) if position.x != 0.0 else 24.0
	monitoring = false
	body_entered.connect(_on_body)


func attack(facing: int) -> void:
	if not _can_attack:
		return
	_can_attack = false
	position.x = _reach * facing
	monitoring = true
	AudioManager.play_sfx("sword")
	await get_tree().create_timer(active_time).timeout
	monitoring = false
	await get_tree().create_timer(maxf(cooldown - active_time, 0.0)).timeout
	_can_attack = true


func _on_body(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)

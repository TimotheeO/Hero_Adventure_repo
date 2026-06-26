extends Node2D
## Arc. shoot(facing) spawn une fleche apres un court delai (sync animation).

@export var arrow_scene: PackedScene
@export var cooldown: float = 0.7
@export var shoot_delay: float = 0.35

var _can_shoot := true


func shoot(facing: int) -> void:
	if not _can_shoot or arrow_scene == null:
		return
	_can_shoot = false
	get_tree().create_timer(shoot_delay).timeout.connect(
		_spawn.bind(facing), CONNECT_ONE_SHOT)
	get_tree().create_timer(cooldown).timeout.connect(
		func(): _can_shoot = true, CONNECT_ONE_SHOT)


func _spawn(facing: int) -> void:
	var arrow := arrow_scene.instantiate()
	arrow.direction = facing
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = global_position + Vector2(12.0 * facing, -2.0)
	AudioManager.play_sfx("bow")

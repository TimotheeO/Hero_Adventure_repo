extends AnimatableBody2D
## Plateforme mobile. Va-et-vient entre position de depart et depart+offset.
## Regler move_offset (Vector2) et duration dans l'inspecteur ou a l'instanciation.

@export var move_offset: Vector2 = Vector2(120, 0)
@export var duration: float = 2.0
@export var pause_time: float = 0.4

var _start: Vector2


func _ready() -> void:
	_start = position
	sync_to_physics = true
	_loop()


func _loop() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", _start + move_offset, duration)
	tween.tween_interval(pause_time)
	tween.tween_property(self, "position", _start, duration)
	tween.tween_interval(pause_time)

extends CharacterBody2D
## Ennemi : patrouille, demi-tour, degats au joueur via HurtBox (Area2D), mort propre.

signal died

@export var speed: float = 50.0
@export var max_health: int = 1
@export var coin_reward: int = 1
@export var hurts_player: bool = true

var _dir := 1
var _health := 1
var _dying := false
var _hurt_cd := false
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var floor_check: RayCast2D = get_node_or_null("FloorCheck")
@onready var hurt_box: Area2D = get_node_or_null("HurtBox")


func _ready() -> void:
	add_to_group("enemies")
	_health = max_health
	collision_layer = 4
	collision_mask = 1   # sol/murs uniquement (pas le joueur, sinon ils se bloquent)
	if anim:
		anim.flip_h = false
		anim.play("walk")
		anim.animation_finished.connect(_on_anim_finished)
	if hurt_box:
		hurt_box.collision_layer = 4
		hurt_box.collision_mask = 2   # detecte le joueur (layer 2)
		hurt_box.body_entered.connect(_on_player_touched)


func _physics_process(delta: float) -> void:
	if _dying:
		return
	if not is_on_floor():
		velocity.y += _gravity * delta
	velocity.x = speed * _dir
	move_and_slide()
	if is_on_wall() or _edge_ahead():
		_flip()


func _on_player_touched(body: Node2D) -> void:
	if _dying or not hurts_player or _hurt_cd:
		return
	if body.is_in_group("player"):
		_hurt_cd = true
		GameManager.lose_life()
		get_tree().create_timer(1.0).timeout.connect(func(): _hurt_cd = false)


func _edge_ahead() -> bool:
	return floor_check != null and is_on_floor() and not floor_check.is_colliding()


func _flip() -> void:
	_dir = -_dir
	if floor_check:
		floor_check.position.x = absf(floor_check.position.x) * _dir
	if anim:
		anim.flip_h = _dir > 0


func take_damage(amount: int) -> void:
	if _dying:
		return
	_health -= amount
	if _health <= 0:
		_die()
	elif anim and anim.sprite_frames.has_animation("hit"):
		anim.play("hit")


func _on_anim_finished() -> void:
	if not _dying and anim and anim.animation == "hit":
		anim.play("walk")


func _die() -> void:
	_dying = true
	set_physics_process(false)
	if hurt_box:
		hurt_box.set_deferred("monitoring", false)
	GameManager.add_coins(coin_reward)
	AudioManager.play_sfx("enemy_death")
	died.emit()
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.25)
	t.tween_callback(queue_free)

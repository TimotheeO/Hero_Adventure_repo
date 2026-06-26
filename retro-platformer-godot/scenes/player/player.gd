extends CharacterBody2D

const MAX_SPEED := 220.0
const ACCELERATION := 900.0
const FRICTION := 1200.0
const JUMP_FORCE := -380.0
const GRAVITY := 1000.0
const FALL_GRAVITY := 1500.0
const COYOTE_TIME := 0.12
const JUMP_BUFFER_TIME := 0.12

const ANIMS := {
	"idle":    [4, 8.0,  true],
	"run":     [6, 10.0, true],
	"jump":    [4, 10.0, false],
	"fall":    [2, 8.0,  true],
	"attack1": [5, 14.0, false],
	"attack2": [6, 14.0, false],
	"die":     [7, 8.0,  false],
	"hurt":    [3, 10.0, false],
	"bow":     [9, 10.0, false],
}

const FRAME_W := 50
const FRAME_H := 37

var facing := 1
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var _busy := false

@onready var anim:     AnimatedSprite2D = $AnimatedSprite2D
@onready var sword:    Area2D           = $SwordHitbox
@onready var bow_node: Node2D           = $Bow


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask  = 5
	_build_frames(str(SaveManager.data.get("equipped_skin", "default")))
	anim.animation_finished.connect(_on_anim_finished)
	anim.play("idle")


func _build_frames(skin: String) -> void:
	var prefix := "res://assets/sprites/player_"
	if skin != "default":
		prefix = "res://assets/sprites/skins/player_%s_" % skin
	var sf := SpriteFrames.new()
	if sf.has_animation("default"):
		sf.remove_animation("default")
	for name in ANIMS:
		var info: Array = ANIMS[name]
		var path := "%s%s.png" % [prefix, name]
		if not ResourceLoader.exists(path):
			path = "res://assets/sprites/player_%s.png" % name
		var tex: Texture2D = load(path)
		sf.add_animation(name)
		sf.set_animation_speed(name, info[1])
		sf.set_animation_loop(name, info[2])
		for i in range(info[0]):
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * FRAME_W, 0, FRAME_W, FRAME_H)
			sf.add_frame(name, atlas)
	anim.sprite_frames = sf


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += (FALL_GRAVITY if velocity.y > 0.0 else GRAVITY) * delta

	coyote_timer = COYOTE_TIME if is_on_floor() else coyote_timer - delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_FORCE
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		AudioManager.play_sfx("jump")

	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		facing = 1 if dir > 0.0 else -1
		anim.flip_h = facing < 0
		velocity.x = move_toward(velocity.x, dir * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	if Input.is_action_just_pressed("attack") and not _busy:
		_busy = true
		sword.attack(facing)
		_play("attack1")
	elif Input.is_action_just_pressed("shoot") and not _busy and GameManager.bow_unlocked:
		_busy = true
		bow_node.shoot(facing)
		_play("bow")

	move_and_slide()
	if not _busy:
		_update_anim()


func _on_anim_finished() -> void:
	if anim.animation in ["attack1", "attack2", "bow", "hurt"]:
		_busy = false
		_update_anim()


func _update_anim() -> void:
	if not is_on_floor():
		_play("fall" if velocity.y > 0.0 else "jump")
	elif absf(velocity.x) > 10.0:
		_play("run")
	else:
		_play("idle")


func _play(name: String) -> void:
	if anim.animation != name:
		anim.play(name)

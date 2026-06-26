extends Node2D

const GAME_OVER_SCENE := "res://scenes/ui/game_over.tscn"
const LEVEL_COMPLETE_SCENE := "res://scenes/ui/level_complete.tscn"
const MAIN_MENU_SCENE := "res://scenes/menus/MainMenu.tscn"

@export var level_number: int = 1

var _paused := false
var _pause_layer: CanvasLayer


func _ready() -> void:
	add_to_group("level")
	GameManager.start_run(level_number)
	GameManager.player_died.connect(_respawn)
	GameManager.game_over.connect(_on_game_over)
	AudioManager.play_music("level")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()


func _toggle_pause() -> void:
	_paused = not _paused
	get_tree().paused = _paused
	if _paused:
		_show_pause_menu()
	elif _pause_layer:
		_pause_layer.queue_free()
		_pause_layer = null


func _show_pause_menu() -> void:
	_pause_layer = CanvasLayer.new()
	_pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_pause_layer)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	_pause_layer.add_child(dim)

	var vbox := VBoxContainer.new()
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.offset_left = -100
	vbox.offset_top = -80
	vbox.offset_right = 100
	vbox.offset_bottom = 80
	vbox.add_theme_constant_override("separation", 14)
	_pause_layer.add_child(vbox)

	var title := Label.new()
	title.text = "PAUSE"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var resume := Button.new()
	resume.text = "Reprendre"
	resume.custom_minimum_size = Vector2(200, 42)
	resume.pressed.connect(_toggle_pause)
	vbox.add_child(resume)

	var retry := Button.new()
	retry.text = "Recommencer"
	retry.custom_minimum_size = Vector2(200, 42)
	retry.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file(GameManager.LEVEL_PATHS[level_number]))
	vbox.add_child(retry)

	var menu := Button.new()
	menu.text = "Retour au menu"
	menu.custom_minimum_size = Vector2(200, 42)
	menu.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file(MAIN_MENU_SCENE))
	vbox.add_child(menu)


func _respawn() -> void:
	var player := get_tree().get_first_node_in_group("player")
	var spawn := get_node_or_null("PlayerSpawn")
	if player and spawn:
		player.global_position = spawn.global_position
		if "velocity" in player:
			player.velocity = Vector2.ZERO


func complete_level() -> void:
	GameManager.finish_level()
	AudioManager.play_sfx("level_complete")
	AudioManager.stop_music()
	get_tree().call_deferred("change_scene_to_file", LEVEL_COMPLETE_SCENE)


func _on_game_over() -> void:
	get_tree().call_deferred("change_scene_to_file", GAME_OVER_SCENE)

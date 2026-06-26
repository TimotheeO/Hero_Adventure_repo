extends Control

const MAIN_MENU := "res://scenes/menus/MainMenu.tscn"


func _ready() -> void:
	$VBox/RetryButton.pressed.connect(func():
		get_tree().change_scene_to_file(GameManager.LEVEL_PATHS[GameManager.current_level]))
	$VBox/MenuButton.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU))

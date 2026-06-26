extends Control

const MAIN_MENU := "res://scenes/menus/MainMenu.tscn"


func _ready() -> void:
	$VBox/TimeLabel.text = "Temps : %s" % HUD.format_time(GameManager.last_time)
	$VBox/RecordLabel.visible = GameManager.last_is_record
	$VBox/StarsLabel.text = "Etoiles recuperees : %d" % GameManager.run_stars
	var next_level: int = GameManager.current_level + 1
	var nb: Button = $VBox/NextButton
	nb.visible = GameManager.LEVEL_PATHS.has(next_level) and SaveManager.is_level_unlocked(next_level)
	if nb.visible:
		nb.pressed.connect(func(): get_tree().change_scene_to_file(GameManager.LEVEL_PATHS[next_level]))
	$VBox/RetryButton.pressed.connect(func():
		get_tree().change_scene_to_file(GameManager.LEVEL_PATHS[GameManager.current_level]))
	$VBox/MenuButton.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU))

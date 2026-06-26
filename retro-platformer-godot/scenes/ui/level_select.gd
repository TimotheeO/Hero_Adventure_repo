extends Control

const MAIN_MENU := "res://scenes/menus/MainMenu.tscn"


func _ready() -> void:
	$VBox/BackButton.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU))
	for level in GameManager.LEVEL_PATHS:
		$VBox/Levels.add_child(_make_button(level))


func _make_button(level: int) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(280, 40)
	if SaveManager.is_level_unlocked(level):
		var txt := "Niveau %d   Etoiles %d/3" % [level, SaveManager.stars_in_level(level)]
		var best := SaveManager.get_best_time(level)
		if best >= 0.0:
			txt += "   %s" % HUD.format_time(best)
		b.text = txt
		b.pressed.connect(func(): get_tree().change_scene_to_file(GameManager.LEVEL_PATHS[level]))
	else:
		b.text = "Niveau %d   [verrouille]" % level
		b.disabled = true
	return b

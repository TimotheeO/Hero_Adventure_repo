extends Control

const LEVEL_SELECT := "res://scenes/menus/LevelSelect.tscn"
const SHOP_SCENE := "res://scenes/menus/ShopMenu.tscn"
const TOTAL_STARS := 9

@onready var stars_label: Label = $VBox/StarsLabel
var _confirm_reset := false


func _ready() -> void:
	AudioManager.play_music("menu")
	$VBox/PlayButton.pressed.connect(func(): get_tree().change_scene_to_file(LEVEL_SELECT))
	$VBox/ShopButton.pressed.connect(func(): get_tree().change_scene_to_file(SHOP_SCENE))
	$VBox/ResetButton.pressed.connect(_on_reset)
	$VBox/QuitButton.pressed.connect(func(): get_tree().quit())
	_update_stars()


func _update_stars() -> void:
	stars_label.text = "Etoiles : %d / %d" % [SaveManager.total_stars(), TOTAL_STARS]


func _on_reset() -> void:
	var btn: Button = $VBox/ResetButton
	if not _confirm_reset:
		# Premier clic : demander confirmation
		_confirm_reset = true
		btn.text = "Confirmer la suppression ?"
		# Annuler la confirmation apres 3s si pas recliquE
		get_tree().create_timer(3.0).timeout.connect(func():
			_confirm_reset = false
			if is_instance_valid(btn):
				btn.text = "Effacer la progression")
	else:
		# Second clic : effacer
		SaveManager.reset_save()
		_confirm_reset = false
		btn.text = "Progression effacee !"
		_update_stars()
		get_tree().create_timer(1.5).timeout.connect(func():
			if is_instance_valid(btn):
				btn.text = "Effacer la progression")

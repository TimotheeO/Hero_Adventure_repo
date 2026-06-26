class_name HUD
extends CanvasLayer

@onready var lives_label: Label = $Margin/HBox/LivesLabel
@onready var coins_label: Label = $Margin/HBox/CoinsLabel
@onready var stars_label: Label = $Margin/HBox/StarsLabel
@onready var level_label: Label = $Margin/HBox/LevelLabel
@onready var timer_label: Label = $Margin/HBox/TimerLabel


func _ready() -> void:
	GameManager.lives_changed.connect(_on_lives)
	GameManager.coins_changed.connect(_on_coins)
	GameManager.stars_changed.connect(_on_stars)
	_on_lives(GameManager.lives)
	_on_coins(GameManager.coins)
	_on_stars(GameManager.run_stars)
	level_label.text = "Niveau %d" % GameManager.current_level


func _process(_d: float) -> void:
	timer_label.text = format_time(GameManager.run_time)


func _on_lives(v: int) -> void:  lives_label.text = "Vies %d" % v
func _on_coins(v: int) -> void:  coins_label.text = "Pieces %d" % v
func _on_stars(v: int) -> void:  stars_label.text = "Etoiles %d/3" % v


static func format_time(t: float) -> String:
	var m := floori(t / 60.0)
	var s := floori(fmod(t, 60.0))
	var c := floori(fmod(t, 1.0) * 100.0)
	return "%02d:%02d.%02d" % [m, s, c]

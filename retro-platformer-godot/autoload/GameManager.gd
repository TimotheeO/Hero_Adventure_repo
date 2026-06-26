extends Node
## Etat du run en cours : vies, pieces, etoiles, timer.

signal lives_changed(lives: int)
signal coins_changed(coins: int)
signal stars_changed(count: int)
signal player_died
signal game_over

const START_LIVES := 3
const COINS_PER_LIFE := 10

const LEVEL_PATHS := {
	1: "res://scenes/levels/Level1.tscn",
	2: "res://scenes/levels/Level2.tscn",
	3: "res://scenes/levels/Level3.tscn",
}

var lives: int = START_LIVES
var coins: int = 0
var run_stars: int = 0
var current_level: int = 1
var bow_unlocked: bool = false
var run_time: float = 0.0
var timer_active: bool = false

var last_time: float = 0.0
var last_is_record: bool = false

var _coin_streak: int = 0


func _process(delta: float) -> void:
	if timer_active:
		run_time += delta


func start_run(level: int) -> void:
	current_level = level
	bow_unlocked = level >= 2
	lives = START_LIVES
	coins = 0
	run_stars = 0
	run_time = 0.0
	_coin_streak = 0
	timer_active = true
	lives_changed.emit(lives)
	coins_changed.emit(coins)
	stars_changed.emit(run_stars)


func add_coins(amount: int = 1) -> void:
	coins += amount
	_coin_streak += amount
	while _coin_streak >= COINS_PER_LIFE:
		_coin_streak -= COINS_PER_LIFE
		lives += 1
		lives_changed.emit(lives)
	coins_changed.emit(coins)


func add_star() -> void:
	run_stars += 1
	stars_changed.emit(run_stars)


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		timer_active = false
		game_over.emit()
	else:
		player_died.emit()


func finish_level() -> void:
	timer_active = false
	last_time = run_time
	last_is_record = SaveManager.submit_time(current_level, run_time)
	SaveManager.add_coins(coins)
	if LEVEL_PATHS.has(current_level + 1):
		SaveManager.unlock_level(current_level + 1)

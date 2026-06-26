extends Node

const SFX := {
	"coin":         "res://assets/audio/sfx/coin.wav",
	"star":         "res://assets/audio/sfx/star.wav",
	"jump":         "res://assets/audio/sfx/jump.wav",
	"sword":        "res://assets/audio/sfx/sword.wav",
	"bow":          "res://assets/audio/sfx/bow.wav",
	"enemy_death":  "res://assets/audio/sfx/enemy_death.wav",
	"buy":          "res://assets/audio/sfx/buy.wav",
	"level_complete": "res://assets/audio/sfx/level_complete.wav",
}

const MUSIC := {
	"menu":  "res://assets/audio/music/menu.wav",
	"level": "res://assets/audio/music/level.mp3",
}

var _music_player: AudioStreamPlayer


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)


func play_sfx(key: String) -> void:
	var path: String = SFX.get(key, "")
	if path == "" or not ResourceLoader.exists(path):
		return
	var player := AudioStreamPlayer.new()
	player.stream = load(path)
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func play_music(key: String) -> void:
	var path: String = MUSIC.get(key, "")
	if path == "" or not ResourceLoader.exists(path):
		_music_player.stop()
		return
	var stream := load(path)
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()

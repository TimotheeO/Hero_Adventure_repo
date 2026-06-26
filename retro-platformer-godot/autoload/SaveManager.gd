extends Node
## Sauvegarde JSON : progression, temps, etoiles, pieces, skins personnage.

const SAVE_PATH := "user://save.json"
const MAX_STARS_PER_LEVEL := 3
const MAX_LEVELS := 3

var data: Dictionary = {}


func _ready() -> void:
	data = _default_data()
	load_game()
	_sanitize()


func _default_data() -> Dictionary:
	return {
		"unlocked_levels": 1,
		"best_times":      {},
		"stars":           {},
		"coins_bank":      0,
		"owned_skins":     ["default"],
		"equipped_skin":   "default",
	}


func _sanitize() -> void:
	var changed := false
	# Nettoyer les etoiles hors-limites
	for key in data.stars.keys():
		var lvl := int(key)
		if lvl < 1 or lvl > MAX_LEVELS:
			data.stars.erase(key)
			changed = true
			continue
		var clean := []
		for idx in data.stars[key]:
			var i := int(idx)
			if i >= 0 and i < MAX_STARS_PER_LEVEL and not clean.has(i):
				clean.append(i)
		if clean.size() != int(data.stars[key].size()):
			data.stars[key] = clean
			changed = true
	# Toujours posseder le skin par defaut
	if not data.owned_skins.has("default"):
		data.owned_skins.append("default")
		changed = true
	if changed:
		save_game()


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		var merged := _default_data()
		merged.merge(parsed, true)
		data = merged


func reset_save() -> void:
	data = _default_data()
	save_game()


# --- Niveaux ---

func is_level_unlocked(level: int) -> bool:
	return level <= int(data.unlocked_levels)


func unlock_level(level: int) -> void:
	if level > int(data.unlocked_levels):
		data.unlocked_levels = level
		save_game()


# --- Temps ---

func get_best_time(level: int) -> float:
	return float(data.best_times.get(str(level), -1.0))


func submit_time(level: int, time: float) -> bool:
	var best := get_best_time(level)
	if best < 0.0 or time < best:
		data.best_times[str(level)] = time
		save_game()
		return true
	return false


# --- Etoiles ---

func collect_star(level: int, index: int) -> void:
	if index < 0 or index >= MAX_STARS_PER_LEVEL:
		return
	var key := str(level)
	var collected: Array = data.stars.get(key, [])
	if not collected.has(index):
		collected.append(index)
		data.stars[key] = collected
		save_game()


func has_star(level: int, index: int) -> bool:
	return (data.stars.get(str(level), []) as Array).has(index)


func stars_in_level(level: int) -> int:
	return mini((data.stars.get(str(level), []) as Array).size(), MAX_STARS_PER_LEVEL)


func total_stars() -> int:
	var total := 0
	for key in data.stars.keys():
		var lvl := int(key)
		if lvl >= 1 and lvl <= MAX_LEVELS:
			total += stars_in_level(lvl)
	return mini(total, MAX_STARS_PER_LEVEL * MAX_LEVELS)


# --- Pieces ---

func add_coins(amount: int) -> void:
	data.coins_bank = int(data.coins_bank) + amount
	save_game()


func spend_coins(amount: int) -> bool:
	if int(data.coins_bank) >= amount:
		data.coins_bank = int(data.coins_bank) - amount
		save_game()
		return true
	return false


# --- Skins personnage ---

func owns_skin(id: String) -> bool:
	return (data.owned_skins as Array).has(id)


func is_skin_equipped(id: String) -> bool:
	return data.equipped_skin == id


func buy_skin(id: String, price: int) -> bool:
	if owns_skin(id):
		return false
	if not spend_coins(price):
		return false
	data.owned_skins.append(id)
	save_game()
	return true


func equip_skin(id: String) -> void:
	if owns_skin(id):
		data.equipped_skin = id
		save_game()

extends Node

const SAVE_PATH = "user://save.json"

var save_data = {
	"unlocked_levels": 1,
	"best_times": {},
	"coins": 0,
	"owned_skins": [],
	"owned_swords": [],
	"stars": {}
}

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		
		var json = JSON.parse_string(content)
		
		if json:
			save_data = json
		
		file.close()

extends Control

const MAIN_MENU := "res://scenes/menus/MainMenu.tscn"

const SKINS := [
	{"id": "default", "name": "Default", "price": 0},
	{"id": "red",   "name": "Skin rouge", "price": 30},
	{"id": "ninja", "name": "Skin ninja", "price": 50},
	{"id": "gold",  "name": "Skin dore",  "price": 0, "stars_required": 9},
]

@onready var coins_label: Label = $VBox/CoinsLabel
@onready var items_box: VBoxContainer = $VBox/Items


func _ready() -> void:
	$VBox/BackButton.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU))
	_refresh()


func _refresh() -> void:
	coins_label.text = "Pieces : %d    Etoiles : %d" % [
		int(SaveManager.data.coins_bank), SaveManager.total_stars()]
	for c in items_box.get_children():
		c.queue_free()
	for skin in SKINS:
		items_box.add_child(_make_row(skin))


func _make_row(skin: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(340, 0)
	var lbl := Label.new()
	lbl.text = String(skin.name)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	row.add_child(_make_button(skin))
	return row


func _make_button(skin: Dictionary) -> Button:
	var b := Button.new()
	var id := String(skin.id)
	var stars_req := int(skin.get("stars_required", 0))
	if SaveManager.is_skin_equipped(id):
		b.text = "Equipe"
		b.disabled = true
	elif SaveManager.owns_skin(id):
		b.text = "Equiper"
		b.pressed.connect(func(): SaveManager.equip_skin(id); _refresh())
	elif stars_req > 0 and SaveManager.total_stars() < stars_req:
		b.text = "Etoiles %d requises" % stars_req
		b.disabled = true
	else:
		b.text = "Acheter (%d)" % int(skin.price)
		b.pressed.connect(func():
			if SaveManager.buy_skin(id, int(skin.price)):
				AudioManager.play_sfx("buy")
			_refresh())
	return b

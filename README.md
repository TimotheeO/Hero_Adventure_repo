# Pack "coup de pouce" — plateforme Godot 4

Scripts + scènes UI prêts à copier dans ton projet. Syntaxe validée (Godot 4.x).

## 1. Installation (5 min)

1. Copie les dossiers `autoload/`, `player/`, `enemies/`, `collectibles/`, `levels/`, `ui/` à la racine de ton projet (`res://`). Si tes dossiers existent déjà, fusionne.
2. **Autoloads** — Projet → Paramètres du projet → Autoload, ajoute **dans cet ordre** et avec **exactement ces noms** :
   - `SaveManager` → `res://autoload/save_manager.gd`
   - `GameManager` → `res://autoload/game_manager.gd`
   - `AudioManager` → `res://autoload/audio_manager.gd`
3. **Inputs** — Projet → Paramètres → Mappage des entrées : crée `attack` (ex: J) et `shoot` (ex: K). Si tes actions ont d'autres noms, adapte le patch ci-dessous.
4. **Scène principale** : `res://ui/main_menu.tscn`.

## 2. Patch de ton player.gd

```gdscript
var facing: int = 1
@onready var sword: Area2D = $SwordHitbox
@onready var bow: Node2D = $Bow

func _ready() -> void:
	add_to_group("player")

# Dans _physics_process, après le calcul de direction :
	if direction != 0:
		facing = 1 if direction > 0 else -1
	if Input.is_action_just_pressed("attack"):
		sword.attack(facing)
		# joue ici l'animation "sword_attack"
	if Input.is_action_just_pressed("shoot"):
		bow.shoot(facing)
```

Nœuds à ajouter au joueur :
- `SwordHitbox` (Area2D, script `player/sword_hitbox.gd`) + CollisionShape2D décalé devant (ex: position (16, 0)).
- `Bow` (Node2D, script `player/bow.gd`).
- Mets une texture sur le `Sprite2D` de `player/arrow.tscn`.

## 3. Structure d'une scène de niveau (level_1.tscn)

```
Level1 (Node2D, script levels/level_base.gd, level_number = 1)
├── PlayerSpawn (Marker2D)          ← point de réapparition
├── Player (ton joueur, groupe "player")
├── TileMap / plateformes
├── HUD (instance de ui/hud.tscn)
├── Exit (Area2D + CollisionShape2D, script levels/exit.gd)   ← fin de niveau
├── DeathZone (Area2D sous le niveau, script levels/death_zone.gd)
├── Coins (Area2D + Sprite2D + CollisionShape2D, script collectibles/coin.gd)
├── Stars (script collectibles/star.gd, star_index = 0, 1, 2 — unique par niveau)
├── Enemies (CharacterBody2D + Sprite2D + CollisionShape2D, script enemies/enemy.gd)
│     └── FloorCheck (RayCast2D vers le bas, devant — optionnel, évite de tomber)
└── Door (StaticBody2D + CollisionShape2D + Sprite2D, script enemies/door.gd,
          required_enemies = liste des ennemis à tuer pour ouvrir)
```

Niveaux 2 et 3 : duplique `level_1.tscn`, change `level_number`, sauvegarde sous
`res://levels/level_2.tscn` / `level_3.tscn` (chemins définis dans `GameManager.LEVEL_PATHS`).

## 4. Ce qui est géré automatiquement

- 3 vies, +1 vie toutes les 10 pièces, Game Over, respawn au PlayerSpawn
- Timer par niveau, meilleur temps sauvegardé, écran de fin avec "NOUVEAU RECORD"
- Déblocage du niveau suivant à la fin d'un niveau
- Pièces du run versées dans la banque (boutique) à la fin du niveau
- Étoiles persistantes (fantôme semi-transparent si déjà récupérée)
- Boutique : achat/équipement skins + épées, skin doré débloqué à 9 étoiles
- Sauvegarde JSON : `user://save.json` (supprime-le pour reset, ou appelle `SaveManager.reset_save()`)
- Audio : dépose tes fichiers dans `res://audio/sfx/` et `res://audio/music/`
  avec les noms listés dans `audio_manager.gd` (silencieux tant qu'ils n'existent pas)

## 5. Skins équipés

`SaveManager.data.equipped_skin` / `equipped_sword` contiennent l'id équipé.
Dans player.gd, change la texture selon cette valeur, ex :

```gdscript
const SKIN_TEXTURES := {
	"default": preload("res://assets/player_default.png"),
	"red": preload("res://assets/player_red.png"),
}

func _ready() -> void:
	$Sprite2D.texture = SKIN_TEXTURES.get(SaveManager.data.equipped_skin, SKIN_TEXTURES["default"])
```

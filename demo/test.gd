extends Control

@onready var button: Button = $Button
@onready var pixel_sprite_monster_generator: PixelSpriteMonsterGenerator = $CenterContainer/PixelSpriteMonsterGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(func(): pixel_sprite_monster_generator.draw_sprite())

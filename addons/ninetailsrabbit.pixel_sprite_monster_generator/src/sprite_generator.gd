class_name PixelSpriteMonsterGenerator extends Node2D


## The sprite size at which the sprite will be generated
@export var sprite_size: Vector2 = Vector2(48, 48)
@export var sprite_draw_rect: Vector2 = Vector2(256, 256)
## A symmetry of 100 % draw a more organic monster with symmetrical sides, the less symmetry, the more chaotic the final monster.
@export_range(0, 100.0, 0.1) var symmetry: float = 100.0
## When pixel perfect it's enabled, the final result will be more 'pixelated' and squared
@export var pixel_perfect: bool = false
@export var outlined: bool = true
## The randomization of seed when it comes to generate the sprite. When this is false, the manual seed is used instead
@export var randomize_seed: bool = true
@export var manual_seed: int = 0
@export_category("Color scheme")
## The number of colors to generate the sprie palette
@export var number_of_colors: int = 12
## This noise shapes the color fill using the generated palette
@export var main_noise: FastNoiseLite
## This secondary noise shapes the color fill using the generated palette
@export var secondary_noise: FastNoiseLite
@export_category("Cellular automata")
## More the steps, more detailed the final result
@export var steps: int = 4
## A cell is born if it has exactly "n" neighbors.
@export var birth_limit: int = 5
## A cell dies if it has fewer than "n" or more than "n" neighbors.
@export var death_limit: int = 4


var map_generator: MapGenerator
var cellular_automata: CellularAutomata
var color_scheme_generator: ColorSchemeGenerator
var color_filler: ColorFiller


func _enter_tree() -> void:
	map_generator = MapGenerator.new()
	cellular_automata = CellularAutomata.new(steps, birth_limit, death_limit)
	color_scheme_generator = ColorSchemeGenerator.new()
	color_filler = ColorFiller.new(main_noise, secondary_noise)


func _ready() -> void:
	assert(main_noise != null, "PixelSpriteMonsterGenerator: This generator needs a main noise (FastNoiseLite)")
	assert(secondary_noise != null, "PixelSpriteMonsterGenerator: This generator needs a secondary noise (FastNoiseLite)")
	
	draw_sprite()


func draw_sprite() -> void:
	clear()
	
	seed(randi() if randomize_seed else manual_seed)
	
	var map: Array[Variant] = map_generator.generate_new(Vector2(64, 64), 100)
	map = cellular_automata.do_steps(map)
	
	var scheme: PackedColorArray = color_scheme_generator.generate_new_colorscheme(4)
	var eye_scheme: PackedColorArray = color_scheme_generator.generate_new_colorscheme(4)
	var all_color_groups: Dictionary = color_filler.fill_colors(map, scheme, eye_scheme, 4, outlined)
	
	var draw_size = min((sprite_draw_rect.x / sprite_size.x), (sprite_draw_rect.y / sprite_size.y))
	
	var g_draw = GroupDrawer.new()
	g_draw.position = Vector2.ZERO
	g_draw.groups = all_color_groups.groups
	g_draw.negative_groups = all_color_groups.negative_groups
	g_draw.draw_size = 1 if pixel_perfect else draw_size

	add_child(g_draw)
	
	
func clear() -> void:
	for child in get_children():
		child.free()

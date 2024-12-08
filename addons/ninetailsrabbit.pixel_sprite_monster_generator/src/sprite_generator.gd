class_name PixelSpriteMonsterGenerator extends Node2D


## The sprite size at which the sprite will be generated
@export var sprite_size: Vector2 = Vector2(48, 48)
@export var sprite_draw_size: Vector2 = Vector2(128, 128)
## A symmetry of 100 % draw a more organic monster with symmetrical sides, the less symmetry, the more chaotic the final monster.
@export_range(0, 100.0, 0.1) var symmetry: float = 100.0
## When pixel perfect it's enabled, the final result will be more 'pixelated' and squared
@export var pixel_perfect: bool = false
@export var outlined: bool = true
## The randomization of seed when it comes to generate the sprite. When this is false, the manual seed is used instead
@export var randomize_seed: bool = true
@export var manual_seed: int = 0
@export_category("Cell Draw")
@export var cell_animation: bool = true:
	set(value):
		if value != cell_animation:
			cell_animation = value
			update_group_drawer()
@export var cell_horizontal_animation: bool = false:
	set(value):
		if value != cell_horizontal_animation:
			cell_horizontal_animation = value
			update_group_drawer()
@export var cell_vertical_animation: bool = true:
	set(value):
		if value != cell_vertical_animation:
			cell_vertical_animation = value
			update_group_drawer()
@export var cell_animation_speed: float =  5.0:
	set(value):
		if value != cell_animation_speed:
			cell_animation_speed = value
			update_group_drawer()
@export var cell_smooth_lerp_factor: float =  20.0:
	set(value):
		if value != cell_smooth_lerp_factor:
			cell_smooth_lerp_factor = value
			update_group_drawer()
@export_category("Color scheme")
## The number of colors to generate the sprie palette
@export var number_of_colors: int = 12:
	set(value):
		if value != number_of_colors:
			number_of_colors = value
			update_group_drawer()
## This noise shapes the color fill using the generated palette
@export var main_noise: FastNoiseLite = preload("res://addons/ninetailsrabbit.pixel_sprite_monster_generator/src/noises/main_noise.tres")
## This secondary noise shapes the color fill using the generated palette
@export var secondary_noise: FastNoiseLite = preload("res://addons/ninetailsrabbit.pixel_sprite_monster_generator/src/noises/secondary_noise.tres")
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

var cell_group_drawer: CellGroupDrawer
var scheme: PackedColorArray 
var eye_scheme: PackedColorArray
var all_color_groups: Dictionary = {}


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
	
	if randomize_seed:
		main_noise.seed = randi()
		secondary_noise.seed = randi()
	
	var map: Array[Variant] = map_generator.generate_new(sprite_size, symmetry)
	map = cellular_automata.do_steps(map)
	
	scheme = color_scheme_generator.generate_new_colorscheme(number_of_colors)
	eye_scheme = color_scheme_generator.generate_new_colorscheme(number_of_colors)
	all_color_groups = color_filler.fill_colors(map, scheme, eye_scheme, number_of_colors, outlined)
	
	update_group_drawer()


func update_group_drawer() -> void:
	if cell_group_drawer == null:
		cell_group_drawer = CellGroupDrawer.new()
	
	if all_color_groups.is_empty():
		return
		
	cell_group_drawer.position = Vector2.ZERO
	cell_group_drawer.groups = all_color_groups.groups
	cell_group_drawer.negative_groups = all_color_groups.negative_groups
	cell_group_drawer.draw_size = 1 if pixel_perfect else min((sprite_draw_size.x / sprite_size.x), (sprite_draw_size.y / sprite_size.y))
	cell_group_drawer.animation = cell_animation
	cell_group_drawer.horizontal_animation = cell_horizontal_animation
	cell_group_drawer.vertical_animation = cell_vertical_animation
	cell_group_drawer.speed = cell_animation_speed
	cell_group_drawer.smooth_lerp_factor = cell_smooth_lerp_factor
	
	if not cell_group_drawer.is_inside_tree():
		add_child(cell_group_drawer)
	
	
func clear() -> void:
	for child in get_children():
		child.free()

#region Helpers
func _set_owner_to_edited_scene_root(node: Node) -> void:
	if Engine.is_editor_hint() and node.get_tree():
		node.owner = node.get_tree().edited_scene_root
#endregion

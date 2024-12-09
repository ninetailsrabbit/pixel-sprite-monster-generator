extends Control

@export var main_noise: FastNoiseLite
@export var secondary_noise: FastNoiseLite

@onready var sprite_result_container: CenterContainer = $CenterContainer
@onready var generate_button: Button = $GenerateButton


func _ready() -> void:
	generate_button.pressed.connect(on_generate_button_pressed)
	draw_sprite()


func draw_sprite() -> void:
	for child in sprite_result_container.get_children():
		child.free()
	
	var pixel_perfect: bool = false
	
	var map_generator: MapGenerator = MapGenerator.new()
	var cellular_automata: CellularAutomata = CellularAutomata.new(4)
	var color_scheme_generator: ColorSchemeGenerator = ColorSchemeGenerator.new()
	var color_filler: ColorFiller = ColorFiller.new(main_noise, secondary_noise)
	
	seed(randi())
	
	var map: Array[Variant] = map_generator.generate_new(Vector2(64, 64), 100)
	
	seed(randi())
	map = cellular_automata.do_steps(map)
	
	var scheme: PackedColorArray = color_scheme_generator.generate_new_colorscheme(4)
	var eye_scheme: PackedColorArray = color_scheme_generator.generate_new_colorscheme(4)
	var all_color_groups: Dictionary = color_filler.fill_colors(map, scheme, eye_scheme, 4, true)
	
	var g_draw = CellGroupDrawer.new()
	g_draw.groups = all_color_groups.groups
	g_draw.negative_groups = all_color_groups.negative_groups
	
	var sprite_draw_rect = Vector2(400, 400)
	var draw_size = min((sprite_draw_rect.x / size.x), (sprite_draw_rect.y / size.y))
	
	if pixel_perfect:
		g_draw.draw_size = 1
	else:
		g_draw.draw_size = draw_size
		g_draw.position = Vector2(-draw_size * size.x * 0.5, -draw_size * size.y *0.5)
	
	sprite_result_container.add_child(g_draw)
	g_draw.position = Vector2.ZERO
	
	
func on_generate_button_pressed() -> void:
	draw_sprite()

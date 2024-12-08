class_name CellGroupDrawer extends Node2D

var groups: Array[Variant] = []
var negative_groups: Array[Variant] = []
var draw_size: int = 6
var animation = true:
	set(value):
		if value != animation:
			animation = value
			
			for cell: CellDrawer in cells():
				cell.animation = animation
var horizontal_animation = true:
	set(value):
		if value != horizontal_animation:
			horizontal_animation = value
			
			for cell: CellDrawer in cells():
				cell.horizontal_animation = horizontal_animation
				
var vertical_animation = true:
	set(value):
		if value != vertical_animation:
			vertical_animation = value
			
			for cell: CellDrawer in cells():
				cell.vertical_animation = vertical_animation
var speed: float = 5.0
var smooth_lerp_factor: float = 20.0


func _enter_tree() -> void:
	name = "CellGroupDrawer"

	
func _ready():
	var largest = 0
	
	for g in groups:
		largest = maxi(largest, g.arr.size())
	
	for i in range(groups.size() - 1, -1, -1):
		var g = groups[i].arr
		groups[i]["start_time"] = g.size() + groups.size()
		
		if g.size() >= largest * 0.25:
			var cell = create_cell(g, animation, groups[i].start_time, speed, smooth_lerp_factor) 
			add_child(cell)
		else:
			groups.erase(g)
		
	for g in negative_groups:
		if g.valid:
			var touching = false
			
			for g2 in groups:
				if group_is_touching_group(g.arr, g2.arr):
					touching = true
					
					if g.has("start_time"):
						g2["start_time"] = g["start_time"]
					else:
						g["start_time"] = g2["start_time"]
						
			if touching:
				var cell = create_cell(g.arr, animation, 0, speed, smooth_lerp_factor) 
				add_child(cell)

				if (g.arr.size() + negative_groups.size()) % 5 >= 3:
					cell.set_eye()


func create_cell(cells, cell_animation: bool, cell_lifetime: int, cell_speed: float, cell_smooth_lerp_factor: float) -> CellDrawer:
	var cell =  CellDrawer.new()
	cell.set_cells(cells)
	
	cell.speed = cell_speed
	cell.lifetime = cell_lifetime
	cell.animation = cell_animation
	cell.horizontal_animation = horizontal_animation
	cell.vertical_animation = vertical_animation
	cell.smooth_lerp_factor = cell_smooth_lerp_factor
	
	return cell
	
	
func cells() -> Array[CellDrawer]:
	var cells: Array[CellDrawer] = []
	cells.assign(get_children().filter(func(child: Node): return child is CellDrawer))
	
	return cells
	
	
func enable_animation():
	animation = true
	

func disable_animation():
	animation = false


func group_is_touching_group(g1, g2):
	for c in g1:
		for c2 in g2:
			if c.position.x == c2.position.x:
				if c.position.y == c2.position.y + 1 || c.position.y == c2.position.y - 1:
					return true
			elif c.position.y == c2.position.y:
				if c.position.x == c2.position.x + 1 || c.position.x == c2.position.x - 1:
					return true
			
	
	return false

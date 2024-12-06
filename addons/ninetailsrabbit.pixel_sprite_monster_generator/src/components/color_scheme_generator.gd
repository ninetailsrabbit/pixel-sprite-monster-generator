class_name ColorSchemeGenerator

# Using ideas from https://www.iquilezles.org/www/articles/palettes/palettes.htm
func generate_new_colorscheme(number_of_colors: int) -> PackedColorArray:
	var a = Vector3(randf_range(0.0, 0.5), randf_range(0.0, 0.5), randf_range(0.0, 0.5))
	var b = Vector3(randf_range(0.1, 0.6), randf_range(0.1, 0.6), randf_range(0.1, 0.6))
	var c = Vector3(randf_range(0.15, 0.8), randf_range(0.15, 0.8), randf_range(0.15, 0.8))
	var d = Vector3(randf_range(0.4, 0.6), randf_range(0.4, 0.6), randf_range(0.4, 0.6))

	var colors: PackedColorArray = PackedColorArray()
	var n: float = float(number_of_colors - 1.0)
	
	for i in number_of_colors:
		var vec3 = Vector3(
			(a.x + b.x * cos(TAU * (c.x * float(i / n) + d.x))) + (i / n),
			(a.y + b.y * cos(TAU * (c.y * float(i / n) + d.y))) + (i / n),
			(a.z + b.z * cos(TAU * (c.z * float(i / n) + d.z))) + (i / n)
		)

		colors.append(Color(vec3.x, vec3.y, vec3.z).darkened(0.2))

	return colors

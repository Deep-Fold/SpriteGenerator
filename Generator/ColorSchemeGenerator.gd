extends Node

# Using ideas from https://www.iquilezles.org/www/articles/palettes/palettes.htm
func generate_new_colorscheme(n_colors):
	var a = Vector3(rand_range(0.0, 0.5), rand_range(0.0, 0.5), rand_range(0.0, 0.5))
	var b = Vector3(rand_range(0.1, 0.6), rand_range(0.1, 0.6), rand_range(0.1, 0.6))
	var c = Vector3(rand_range(0.15, 0.8), rand_range(0.15, 0.8), rand_range(0.15, 0.8))
	var d = Vector3(rand_range(0.0, 1.0), rand_range(0.0, 1.0), rand_range(0.0, 1.0))

	var cols = PoolColorArray()
	var n = float(n_colors - 1.0)
	for i in range(0, n_colors, 1):
		var vec3 = Vector3()
		vec3.x = (a.x + b.x *cos(6.28318 * (c.x*float(i/n) + d.x))) + (i/n)*0.8
		vec3.y = (a.y + b.y *cos(6.28318 * (c.y*float(i/n) + d.y))) + (i/n)*0.8
		vec3.z = (a.z + b.z *cos(6.28318 * (c.z*float(i/n) + d.z))) + (i/n)*0.8

		cols.append(Color(vec3.x, vec3.y, vec3.z))
	
	return cols

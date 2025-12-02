package main


vec2 :: struct {
	x: i32,
	y: i32,
}
add_vec :: proc {
	add_vecs,
	add_vec_scalar,
}
mult_vec :: proc {
	mult_scalar_i32,
	mult_scalar_f32,
}

add_vec_scalar :: proc(a: vec2, b: i32) -> vec2 {
	return vec2{x = a.x + b, y = a.y + b}
}
add_vecs :: proc(a, b: vec2) -> vec2 {
	return vec2{x = a.x + b.x, y = a.y + b.y}
}
mult_scalar_i32 :: proc(a: vec2, b: i32) -> vec2 {
	return vec2{x = a.x * b, y = a.y * b}
}
mult_scalar_f32 :: proc(a: vec2, b: f32) -> vec2 {
	return vec2{x = i32(f32(a.x) * b), y = i32(f32(a.y) * b)}
}

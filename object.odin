package main

object :: struct {
	cells:   [][]Cell,
	pos:     vec2,
	pre_pos: [dynamic]vec2,
}

draw_object :: proc(o: ^object, m: [][]Cell) {
	for pre_pos in o.pre_pos {
		for _, y in o.cells {
			for _, x in o.cells[y] {
				m[i32(y) + pre_pos.y][i32(x) + pre_pos.x] = Cell{}
			}
		}
	}
	for _, y in o.cells {
		for _, x in o.cells[y] {
			m[i32(y) + o.pos.y][i32(x) + o.pos.x] = o.cells[y][x]
		}
	}
	clear(&o.pre_pos)
	append(&o.pre_pos, o.pos)

}

delete_object :: proc(o: ^object) {
	delete(o.pre_pos)
	delete(o.cells)
}
move_object :: proc(o: ^object, n_pos: vec2, m: [][]Cell) {
	append(&o.pre_pos, o.pos)
	o.pos = n_pos
}

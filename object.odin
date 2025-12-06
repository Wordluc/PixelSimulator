package main

import "core:fmt"
object :: struct {
	cells:   [][]Cell,
	pos:     vec2,
	pre_pos: vec2,
	size:    vec2,
}
new_object :: proc(parts: [][]Cell, pos: vec2) -> (res: ^object) {
	res = new(object)
	res.cells = parts
	res.pos = pos
	res.pre_pos = pos
	res.size.y = i32(len(parts))
	for _, p in res.cells {
		w := i32(len(res.cells[p]))
		if w > res.size.x {
			res.size.x = w
		}
		for &i in res.cells[p] {
			i.origin = res
		}
	}

	return res
}
delete_object :: proc(o: ^object) {
	free(o)
}
draw_object :: proc(o: ^object, m: [][]Cell) {
	for _, y in o.cells {
		for _, x in o.cells[y] {
			m[i32(y) + o.pos.y][i32(x) + o.pos.x] = o.cells[y][x]
		}
	}
}

move_object :: proc(
	o: ^object,
	n_pos: vec2,
	m: [][]Cell,
	stopIfOccupied: bool,
) -> (
	stopped: bool,
) {
	if n_pos.x < 0 || n_pos.x + o.size.x > W_M {
		return true
	}
	if n_pos.y < 0 || n_pos.y + o.size.y > H_M {
		return true
	}
	for _, y in o.cells {
		for _, x in o.cells[y] {
			if is_out(i32(x) + n_pos.x, i32(y) + n_pos.y) {
				return true
			}
			if stopIfOccupied {
				if is_occupied(m[i32(y) + n_pos.y][i32(x) + n_pos.x]) {
					if m[i32(y) + n_pos.y][i32(x) + n_pos.x].origin != o {
						return true
					}
				}
			}
		}
	}
	for _, y in o.cells {
		for _, x in o.cells[y] {
			m[i32(y) + o.pre_pos.y][i32(x) + o.pre_pos.x] = Cell{}
		}
	}
	o.pre_pos = o.pos
	o.pos = n_pos
	for _, y in o.cells {
		for _, x in o.cells[y] {
			m[i32(y) + o.pos.y][i32(x) + o.pos.x] = o.cells[y][x]
		}
	}
	return false
}

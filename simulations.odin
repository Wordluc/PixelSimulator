package main

import "core:math/rand"
import "vendor:raylib"
simulateWater :: proc(m: [][]Cell, pos: vec2) {
	old := m[pos.y][pos.x]
	if old.type != .Water {
		return
	}
	offsets := []vec2 {
		vec2{y = 2},
		vec2{y = 1},
		vec2{y = 2, x = 2},
		vec2{y = 1, x = 1},
		vec2{y = 2, x = -2},
		vec2{y = 1, x = -1},
		vec2{x = 2},
		vec2{x = -2},
		vec2{x = 1},
		vec2{x = -1},
	}
	moved := simulate(old, pos, m, offsets)
	if moved {
		m[pos.y][pos.x] = Cell{}
	}
	old = m[pos.y][pos.x]
	if old.type == .Water {
		if is_occupied(m[pos.y + 1][pos.x]) && m[pos.y + 1][pos.x].type == .Fire {
			m[pos.y + 1][pos.x].life = 0
		}
	}
}
simulateSand :: proc(m: [][]Cell, pos: vec2) {
	old := m[pos.y][pos.x]
	if old.type != .Dirty && old.type != .Wodden {
		return
	}

	offsets := []vec2{vec2{y = 1}, vec2{y = 1, x = 1}, vec2{y = 1, x = -1}}
	moved := simulate(old, pos, m, offsets)
	if moved {
		m[pos.y][pos.x] = Cell{}
	} else {
		old := m[pos.y][pos.x]
		if !is_out(pos.x, pos.y + 1) && old.type == .Dirty && !m[pos.y + 1][pos.x].touched {
			if is(m[pos.y + 1][pos.x], .Water) {
				w := m[pos.y + 1][pos.x]
				w.touched = true
				m[pos.y + 1][pos.x] = old
				old.touched = true
				m[pos.y][pos.x] = w

			}
		}
		if !is_out(pos.x, pos.y - 1) && old.type == .Wodden && !m[pos.y - 1][pos.x].touched {
			if is(m[pos.y - 1][pos.x], .Water) {
				w := m[pos.y - 1][pos.x]
				w.touched = true
				old.touched = true
				m[pos.y - 1][pos.x] = old
				m[pos.y][pos.x] = w

			}
		}
		return
	}
}
simulateFire :: proc(m: [][]Cell, pos: vec2) {
	old := &m[pos.y][pos.x]
	if old.type != .Fire {
		return
	}
	old.life -= 1
	if old.life <= 0 {
		r := rand.choice([]int{0, 1})
		if r == 1 {
			m[pos.y][pos.x] = Cell {
				type  = .Smoke,
				life  = LIFE_SMOKE,
				color = raylib.GRAY,
			}
		} else {
			m[pos.y][pos.x] = Cell{}
		}
		return
	}
	fire := proc(m: [][]Cell, fire: ^Cell, y, x: i32, life: int) {
		if m[y][x].type == .Wodden {
			m[y][x] = Cell {
				color = raylib.RED,
				type  = .Fire,
				life  = life,
			}
		}
	}
	offsetX := rand.choice([]i32{1, -1, 0})
	offsetY := rand.choice([]i32{1, -1, 0})

	y := pos.y + offsetY
	x := pos.x + offsetX
	if !is_out(x, y) {
		fire(m, old, y, x, LIFE_FIRE)
	}
}
simulateSmoke :: proc(m: [][]Cell, pos: vec2) {
	old := &m[pos.y][pos.x]
	if old.type != .Smoke {
		return
	}
	old.life -= rand.choice([]int{1, 2})
	if old.life <= 0 {
		m[pos.y][pos.x] = Cell{}
		return
	}
	offsets := []vec2 {
		vec2{y = -1},
		vec2{x = -1},
		vec2{x = -1},
		vec2{y = -1, x = 1},
		vec2{y = -1, x = -1},
	}
	moved := simulate(old^, pos, m, offsets)
	if moved {
		m[pos.y][pos.x] = Cell{}
	}
}

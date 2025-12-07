package main

import "core:math/rand"
simulateLiquid :: proc(m: [][]Cell, pos: vec2) {
	old := m[pos.y][pos.x]
	if old.type != .Liquid {
		return
	}
	offsets := []vec2 {
		vec2{y = 1},
		vec2{y = 1, x = 1},
		vec2{y = 1, x = -1},
		vec2{x = 1},
		vec2{x = -1},
	}
	moved := simulate(old, pos, m, offsets)
	if moved {
		m[pos.y][pos.x] = Cell{}
	}
}
simulateGrain :: proc(m: [][]Cell, pos: vec2) {
	old := m[pos.y][pos.x]
	if old.type != .Grain {
		return
	}

	offsets := []vec2{vec2{y = 1}, vec2{y = 1, x = 1}, vec2{y = 1, x = -1}}
	moved := simulate(old, pos, m, offsets)
	if moved {
		m[pos.y][pos.x] = Cell{}
	} else {
		old := m[pos.y][pos.x]
		if old.type != .Grain {
			return
		}
		if !is_out(pos.x, pos.y + 1) && !old.isFloater && !m[pos.y + 1][pos.x].touched {
			if is(m[pos.y + 1][pos.x], .Liquid) {
				w := m[pos.y + 1][pos.x]
				w.touched = true
				m[pos.y + 1][pos.x] = old
				old.touched = true
				m[pos.y][pos.x] = w

			}
		}
		if !is_out(pos.x, pos.y - 1) && old.isFloater && !m[pos.y - 1][pos.x].touched {
			if is(m[pos.y - 1][pos.x], .Liquid) {
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
	if !old.isCombusting {
		return
	}
	if !old.isPersistent {
		old.life -= 1
	}
	if old.life <= 0 {
		r := rand.choice([]int{0, 1})
		if r == 1 {
			m[pos.y][pos.x] = create_smoke()
		} else {
			m[pos.y][pos.x] = Cell{}
		}
	}
}
simulateAir_Gas :: proc(m: [][]Cell, pos: vec2) {
	old := &m[pos.y][pos.x]
	if old.type != .Gas_like {
		return
	}
	if !old.isPersistent {
		old.life -= rand.choice([]int{1, 2})
	}
	if old.life <= 0 {
		m[pos.y][pos.x] = Cell{}
		return
	}
	offsets := []vec2 {
		vec2{y = -1},
		vec2{y = -1, x = 1},
		vec2{y = -1, x = -1},
		vec2{x = 1},
		vec2{x = -1},
	}
	moved := simulate(old^, pos, m, offsets)
	if moved {
		m[pos.y][pos.x] = Cell{}
	}
}

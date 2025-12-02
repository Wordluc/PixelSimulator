package main
import "core:fmt"
import "core:math"
import "core:math/rand"
import "vendor:raylib"
LIFE_FIRE :: 10
LIFE_SMOKE :: 100
Particletype :: enum {
	Dirty,
	Water,
	Wodden,
	Fire,
	Smoke,
	Stone,
}
Cell :: struct {
	color:   raylib.Color,
	type:    Particletype,
	life:    int,
	touched: bool,
}

free_matrix :: proc(m: [][]Cell) {
	for _, x in m {
		delete(m[x])
	}
}
new_matrix :: proc(x, y: i32) -> [][]Cell {
	cells := make([][]Cell, H_M)
	for _, i in cells {
		cells[i] = make_slice([]Cell, W_M)
		for _, t in cells[i] {
			cells[i][t].color = raylib.BLACK
		}
	}
	return cells
}
is_out :: proc(x, y: i32) -> bool {
	if x < 0 || x >= W_M {
		return true
	}
	if y < 0 || y >= H_M {
		return true
	}
	return false
}
simulate :: proc(cell: Cell, pos: vec2, m: [][]Cell, offsets: []vec2) -> (placed: bool) {
	x: i32
	y: i32
	for offset in offsets {
		x = pos.x + offset.x
		y = pos.y + offset.y
		if is_out(x, y) {
			continue
		}
		if !is_occupied(m[y][x]) {
			m[y][x] = cell
			m[y][x].touched = true
			return true
		}
	}
	return false
}
is_occupied :: proc(cell: Cell) -> bool {
	return cell.color != raylib.BLACK
}
is :: proc(cell: Cell, type: Particletype) -> bool {
	return cell.type == type && is_occupied(cell)
}
simulateFire :: proc(m: [][]Cell, pos: vec2) {
	old := &m[pos.y][pos.x]
	if old.type != .Fire {
		return
	}
	if old.touched {
		return
	}
	old.life -= 1
	if old.life <= 0 {
		r := rand.choice([]int{0, 0, 0, 0, 1})
		if r == 1 {
			m[pos.y][pos.x] = Cell {
				type  = .Smoke,
				life  = LIFE_SMOKE,
				color = raylib.GRAY,
			}
		} else {
			m[pos.y][pos.x] = Cell {
				color = raylib.BLACK,
			}
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
	if old.touched {
		return
	}
	old.life -= rand.choice([]int{1, 2, 4, 8})
	if old.life <= 0 {
		m[pos.y][pos.x] = Cell {
			color = raylib.BLACK,
		}
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
		m[pos.y][pos.x] = Cell {
			color = raylib.BLACK,
		}
	}
}
simulateWater :: proc(m: [][]Cell, pos: vec2) {
	old := m[pos.y][pos.x]
	if old.type != .Water {
		return
	}
	if old.touched {
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
		m[pos.y][pos.x] = Cell {
			color = raylib.BLACK,
		}
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
	if old.touched {
		return
	}

	offsets := []vec2{vec2{y = 1}, vec2{y = 1, x = 1}, vec2{y = 1, x = -1}}
	moved := simulate(old, pos, m, offsets)
	if moved {
		m[pos.y][pos.x] = Cell {
			color = raylib.BLACK,
		}
	} else {
		old := m[pos.y][pos.x]
		if old.type == .Dirty && !m[pos.y + 1][pos.x].touched {
			if is(m[pos.y + 1][pos.x], .Water) {
				w := m[pos.y + 1][pos.x]
				w.touched = true
				m[pos.y + 1][pos.x] = old
				m[pos.y][pos.x] = w

			}
		}
		return
	}
}
rain_matrix :: proc(m: [][]Cell) -> [][]Cell {
	sense := false
	for _, y in m {
		for _, x in m[y] {
			m[y][x].touched = false
		}
	}
	for _, iy in m {
		y := cast(int)H_M - iy - 1 //DAL BASSO AL ALTO
		for _, x in m[iy] {
			x := x
			if iy % 2 == 0 {
				x = cast(int)W_M - x - 1
			}
			old := &m[y][x]
			if cast(int)y + 1 >= int(H_M) {
				if old.type == .Fire {
					m[y][x] = Cell {
						color = raylib.BLACK,
					}
				}
				continue
			}
			if !is_occupied(old^) {
				continue
			}
			pos := vec2 {
				x = i32(x),
				y = i32(y),
			}
			simulateSand(m, pos)
			simulateWater(m, pos)
			simulateFire(m, pos)
			simulateSmoke(m, pos)
		}
	}
	return m
}
W_M: i32 : 450
H_M: i32 : 200
W: i32
H: i32

main :: proc() {
	size: i32 = 3
	radio: i32 = 5
	raylib.InitWindow(W_M * size, H_M * size, "Boo")
	W = W_M * size
	H = H_M * size + 1
	cells: [][]Cell = new_matrix(W_M, H_M)
	defer free_matrix(cells)
	raylib.SetTargetFPS(60)
	p := raylib.GetMousePosition()
	rain := false
	type: Particletype = .Dirty
	for {
		if raylib.WindowShouldClose() {
			return
		}
		p = raylib.GetMousePosition()
		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.BLACK)
		isValid := true
		if (cast(i32)p.x >= W || cast(i32)p.x < 0) {
			isValid = false
		}
		if cast(i32)p.y >= H || cast(i32)p.y < 0 {
			isValid = false
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.R) {
			rain = !rain
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.T) {
			type = .Dirty
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.Y) {
			type = .Wodden
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.W) {
			type = .Water
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.F) {
			type = .Fire
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.S) {
			type = .Stone
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.C) {
			free_matrix(cells)
			cells = new_matrix(W_M, H_M)
			rain = false
		}
		y := (f32(p.y) / f32(size))
		x := (f32(p.x) / f32(size))
		if isValid && rain {
			for ix in -radio ..= radio {
				for iy in -radio ..= radio {
					yt := y + f32(iy)
					xt := x + f32(ix)
					if math.pow(xt - f32(x), 2) + math.pow(yt - f32(y), 2) <
					   math.pow(f32(radio), 2) {
						yt := i32(yt)
						xt := i32(xt)
						if is_out(xt, yt) {
							continue
						}
						if type == .Water {
							cells[yt][xt].color = raylib.BLUE
							cells[yt][xt].type = .Water
						} else if type == .Dirty {
							cells[yt][xt].color = raylib.BROWN
							cells[yt][xt].type = .Dirty
						} else if type == .Wodden {
							cells[yt][xt].color = raylib.DARKBROWN
							cells[yt][xt].type = .Wodden
						} else if type == .Fire {
							cells[yt][xt].color = raylib.RED
							cells[yt][xt].type = .Fire
							cells[yt][xt].life = LIFE_FIRE
						} else if type == .Stone {
							cells[yt][xt].color = raylib.DARKGRAY
							cells[yt][xt].type = .Stone
						}


					}
				}
			}
		}
		for _, y in cells {
			for _, x in cells[y] {
				raylib.DrawRectangle(
					cast(i32)x * size,
					cast(i32)y * size,
					size,
					size,
					cells[y][x].color,
				)
			}
		}
		raylib.EndDrawing()
		cells = rain_matrix(cells)
	}
}

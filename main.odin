package main
import "core:fmt"
import "core:math"
import "core:math/rand"
import "vendor:raylib"
LIFE_FIRE :: 40
Particletype :: enum {
	Dirty,
	Water,
	Wodden,
	Fire,
}
Cell :: struct {
	color:   raylib.Color,
	type:    Particletype,
	life:    int,
	touched: int,
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
is_occupied :: proc(cell: Cell) -> bool {
	return cell.color != raylib.BLACK
}
is :: proc(cell: Cell, type: Particletype) -> bool {
	return cell.type == type && is_occupied(cell)
}
simulateFire :: proc(m: [][]Cell, x, y: int) {
	old := &m[y][x]
	if old.type != .Fire {
		return
	}
	old.life -= 1
	if old.life <= 0 {
		m[y][x] = Cell {
			color = raylib.BLACK,
		}
		return
	}
	fire := proc(m: [][]Cell, y, x: int, life: int) {
		if m[y][x].type != .Wodden {
			return
		}
		m[y][x] = Cell {
			color = raylib.RED,
			type  = .Fire,
			life  = life,
		}
	}
	offsetX := rand.choice([]int{1, -1, 0})
	offsetY := rand.choice([]int{1, -1, 0})

	fire(m, y + offsetY, x + offsetX, LIFE_FIRE)
}
simulateWater :: proc(m: [][]Cell, x, y: int) {
	old := m[y][x]
	if old.type != .Water {
		return
	}
	moved := false
	if !is_occupied(m[y + 1][x]) {
		m[y + 1][x] = old
		moved = true
	} else if !is_occupied(m[y + 1][x + 1]) {
		m[y + 1][x + 1] = old
		moved = true
	} else if !is_occupied(m[y + 1][x - 1]) {
		m[y + 1][x - 1] = old
		moved = true
	} else if !is_occupied(m[y][x + 1]) {
		m[y][x + 1] = old
		moved = true
	} else if !is_occupied(m[y][x - 1]) {
		m[y][x - 1] = old
		moved = true
	}
	old = m[y][x]
	if old.type == .Water {
		if is_occupied(m[y + 1][x]) && m[y + 1][x].type == .Fire {
			m[y + 1][x].life = 0
		}
	}
	if moved {
		m[y][x] = Cell {
			color = raylib.BLACK,
		}
	}

}
simulateSand :: proc(m: [][]Cell, x, y: int) {
	old := m[y][x]
	if old.type != .Dirty && old.type != .Wodden {
		return
	}
	if !is_occupied(m[y + 1][x]) {
		m[y + 1][x] = old
	} else if !is_occupied(m[y + 1][x + 1]) {
		m[y + 1][x + 1] = old
	} else if !is_occupied(m[y + 1][x - 1]) {
		m[y + 1][x - 1] = old
	} else {
		old := m[y][x]
		if old.type == .Dirty && m[y + 1][x].touched == 0 {
			if is(m[y + 1][x], .Water) {
				w := m[y + 1][x]
				w.touched += 1
				m[y + 1][x] = old
				m[y][x] = w

			}
		}
		return
	}
	m[y][x] = Cell {
		color = raylib.BLACK,
	}
}
rain_matrix :: proc(m: [][]Cell) -> [][]Cell {
	sense := false
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
			simulateSand(m, x, y)
			simulateFire(m, x, y)
			simulateWater(m, x, y)
		}
	}
	for _, iy in m {
		for _, x in m[iy] {
			m[iy][x].touched = 0
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

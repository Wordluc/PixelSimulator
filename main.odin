package main
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strconv"
import "core:strings"
import "vendor:raylib"
LIFE_FIRE :: 10
LIFE_SMOKE :: 200
Particletype :: enum {
	None,
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
	return cell.type != .None
}
is :: proc(cell: Cell, type: Particletype) -> bool {
	return cell.type == type && is_occupied(cell)
}


simulates := []proc(m: [][]Cell, pos: vec2) {
	simulateSand,
	simulateWater,
	simulateFire,
	simulateSmoke,
}
rain_matrix :: proc(m: [][]Cell) -> [][]Cell {
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
					m[y][x] = Cell{}
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
			for i in simulates {
				if old.touched {
					continue
				}
				i(m, pos)
			}
		}
	}
	return m
}
W_M: i32
H_M: i32
W: i32 = 1400
H: i32 = 700
SIZE: i32 = 5
RADIO_CURSOR: i32 = 5

main :: proc() {
	W_M = W / SIZE
	H_M = H / SIZE + 1
	raylib.InitWindow(W, H, "Boo")
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
		raylib.ClearBackground(raylib.SKYBLUE)
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
		if raylib.IsKeyPressed(raylib.KeyboardKey.A) {
			type = .Smoke
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.C) {
			free_matrix(cells)
			cells = new_matrix(W_M, H_M)
			rain = false
		}
		y := (f32(p.y) / f32(SIZE))
		x := (f32(p.x) / f32(SIZE))
		if isValid && rain {
			for ix in -RADIO_CURSOR ..= RADIO_CURSOR {
				for iy in -RADIO_CURSOR ..= RADIO_CURSOR {
					yt := y + f32(iy)
					xt := x + f32(ix)
					if math.pow(xt - f32(x), 2) + math.pow(yt - f32(y), 2) <
					   math.pow(f32(RADIO_CURSOR), 2) {
						yt := i32(yt)
						xt := i32(xt)
						if is_out(xt, yt) {
							continue
						}
						if type == .Water {
							cells[yt][xt].color = raylib.BLUE
							cells[yt][xt].type = .Water
						} else if type == .Dirty {
							cells[yt][xt].color = raylib.YELLOW
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
						} else if type == .Smoke {
							cells[yt][xt].color = raylib.GRAY
							cells[yt][xt].type = .Smoke
							cells[yt][xt].life = LIFE_SMOKE
						}


					}
				}
			}
		}
		for _, y in cells {
			for _, x in cells[y] {
				raylib.DrawRectangle(
					cast(i32)x * SIZE,
					cast(i32)y * SIZE,
					SIZE,
					SIZE,
					cells[y][x].color,
				)
			}
		}
		raylib.EndDrawing()

		label := &strings.Builder{}
		raylib.DrawText(fmt.ctprint("fps:", raylib.GetFPS()), 10, 10, 20, raylib.MAGENTA)
		raylib.DrawText(fmt.ctprint("fps:", type), 10, 25, 20, raylib.MAGENTA)

		cells = rain_matrix(cells)
	}
}

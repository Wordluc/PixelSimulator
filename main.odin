package main
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strconv"
import "core:strings"
import "vendor:raylib"
LIFE_FIRE :: 10
LIFE_SMOKE :: 200

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
				continue
			}
			pos := vec2 {
				x = i32(x),
				y = i32(y),
			}
			for i in simulates {
				old := &m[y][x]
				if !is_occupied(old^) {
					continue
				}
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
SIZE: i32 = 4
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
	type: Particletype = .Sand
	c := &object {
		cells = [][]Cell {
			[]Cell{create_stone(), create_stone()},
			[]Cell{create_stone(), create_stone()},
		},
	}
	defer delete_object(c)
	x := 0
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
			type = .Sand
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
			type = .Still
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.A) {
			type = .Smoke
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.UP) {
			move_object(c, add_vec(c.pos, vec2{y = -1}), cells)
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.DOWN) {
			move_object(c, add_vec(c.pos, vec2{y = 1}), cells)
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.RIGHT) {
			move_object(c, add_vec(c.pos, vec2{x = 1}), cells)
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.LEFT) {
			move_object(c, add_vec(c.pos, vec2{x = -1}), cells)
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
							cells[yt][xt] = create_water()
						} else if type == .Sand {
							cells[yt][xt] = create_sand()
						} else if type == .Wodden {
							cells[yt][xt] = create_wodden()
						} else if type == .Fire {
							cells[yt][xt] = create_fire()
						} else if type == .Still {
							cells[yt][xt] = create_stone()
						} else if type == .Smoke {
							cells[yt][xt] = create_smoke()
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

		raylib.DrawText(fmt.ctprint("fps:", raylib.GetFPS()), 10, 10, 20, raylib.BLACK)
		raylib.DrawText(fmt.ctprint("Type:", type), 10, 30, 20, raylib.BLACK)
		draw_object(c, cells)

		cells = rain_matrix(cells)
	}
}

package main
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strconv"
import "core:strings"
import "vendor:raylib"
LIFE_FIRE :: 5
LIFE_SMOKE :: 200

Material :: enum {
	None,
	Sand,
	Water,
	Fire,
	Smoke,
	Wodden,
	Lava,
	Stone,
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
	if cell.touched {
		return false
	}
	for offset in offsets {
		x = pos.x + offset.x
		y = pos.y + offset.y
		if is_out(x, y) {
			continue
		}
		if is_occupied(m[y][x]) &&
		   !m[y][x].isCombusting &&
		   (m[y][x].isFlammable || m[y][x].type == .Liquid) {

			offsetX := rand.choice([]i32{0, 1, -1})
			offsetY := rand.choice([]i32{-1, 1})
			ty := y + offsetY
			tx := x + offsetX
			if !is_out(tx, ty) && m[ty][tx].isCombusting {
				if m[y][x].isFlammable {
					m[y][x] = create_fire()
					return false
				} else if m[y][x].type == .Liquid {
					m[y][x] = create_smoke()
					return false
				}
			}
		}
		if !is_occupied(m[y][x]) || m[y][x].type == .Gas_like {
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
	simulateSmoke,
	simulateWater,
	simulateFire,
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
			pos := vec2 {
				x = i32(x),
				y = i32(y),
			}
			for i in simulates {
				old := &m[y][x]
				if !is_occupied(old^) {
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
	H_M = H / SIZE
	raylib.InitWindow(W, H, "Boo")
	cells: [][]Cell = new_matrix(W_M, H_M)
	defer free_matrix(cells)
	raylib.SetTargetFPS(60)
	p := raylib.GetMousePosition()
	rain := false
	type: Material = .Sand
	c := new_object(
		[][]Cell{[]Cell{create_stone(), create_stone()}, []Cell{create_stone(), create_stone()}},
		vec2{x = 0, y = 0},
	)
	defer delete_object(c)
	generator := Generator {
		range = RADIO_CURSOR,
	}
	ges: [dynamic]Generator = make([dynamic]Generator)
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
			generator.material = .Sand
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.L) {
			generator.material = .Lava
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.Y) {
			generator.material = .Wodden
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.W) {
			generator.material = .Water
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.F) {
			generator.material = .Fire
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.S) {
			generator.material = .Stone
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.A) {
			generator.material = .Smoke
		}
		if raylib.IsKeyPressed(raylib.KeyboardKey.C) {
			free_matrix(cells)
			cells = new_matrix(W_M, H_M)
			rain = false
			clear(&ges)
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.UP) {
			move_object(c, add_vec(c.pos, vec2{y = -1}), cells, true)
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.DOWN) {
			move_object(c, add_vec(c.pos, vec2{y = 1}), cells, true)
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.RIGHT) {
			move_object(c, add_vec(c.pos, vec2{x = 1}), cells, true)
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.LEFT) {
			move_object(c, add_vec(c.pos, vec2{x = -1}), cells, true)
		}
		y := (f32(p.y) / f32(SIZE))
		x := (f32(p.x) / f32(SIZE))
		if raylib.IsKeyPressed(raylib.KeyboardKey.G) {
			append(
				&ges,
				Generator {
					pos = vec2{x = i32(x), y = i32(y)},
					material = generator.material,
					range = generator.range,
				},
			)
		}
		if isValid && rain {
			generator.pos = vec2 {
				x = i32(x),
				y = i32(y),
			}
			do_Generator(generator, cells)
		}
		for i in ges {
			do_Generator(i, cells)
		}
		draw_object(c, cells)
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
		raylib.DrawText(fmt.ctprint("fps:", raylib.GetFPS()), 10, 10, 20, raylib.BLACK)
		raylib.DrawText(fmt.ctprint("Type:", type), 10, 30, 20, raylib.BLACK)
		raylib.EndDrawing()


		cells = rain_matrix(cells)
	}
}

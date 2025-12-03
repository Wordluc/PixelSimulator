package main
import "core:math/rand"
import "vendor:raylib"

Particletype :: enum {
	None,
	Sand,
	Water,
	Wodden,
	Fire,
	Smoke,
	Still,
}
Cell :: struct {
	color:   raylib.Color,
	type:    Particletype,
	life:    int,
	touched: bool,
	origin:  ^object,
}
create_water :: proc() -> (res: Cell) {
	res.color = rand.choice([]raylib.Color{raylib.BLUE, raylib.BLUE, raylib.BLUE, raylib.DARKBLUE})
	res.type = .Water
	return res
}
create_sand :: proc() -> (res: Cell) {
	res.color = rand.choice([]raylib.Color{raylib.YELLOW, raylib.YELLOW, raylib.ORANGE})
	res.type = .Sand
	return res
}
create_wodden :: proc() -> (res: Cell) {
	res.color = rand.choice([]raylib.Color{raylib.BROWN, raylib.BROWN, raylib.DARKBROWN})
	res.type = .Wodden
	return res
}
create_fire :: proc() -> (res: Cell) {
	res.color = rand.choice(
		[]raylib.Color{raylib.ORANGE, raylib.ORANGE, raylib.RED, raylib.YELLOW},
	)
	res.type = .Fire
	res.life = LIFE_FIRE
	return res
}
create_smoke :: proc() -> (res: Cell) {
	res.color = raylib.GRAY
	res.type = .Smoke
	res.life = LIFE_SMOKE
	return res
}
create_stone :: proc() -> (res: Cell) {
	res.color = rand.choice([]raylib.Color{raylib.GRAY, raylib.DARKGRAY, raylib.BLACK})
	res.type = .Still
	return res
}

package main
import "core:math/rand"
import "vendor:raylib"

Particletype :: enum {
	None,
	Grain,
	Liquid,
	Gas_like,
	Still,
}
Cell :: struct {
	color:        raylib.Color,
	type:         Particletype,
	material:     Material,
	life:         int,
	touched:      bool,
	origin:       ^object,
	speed:        i32,
	isFlammable:  bool,
	isPersistent: bool,
	isCombusting: bool,
	isFloater:    bool,
}
create_water :: proc() -> (res: Cell) {
	res.color = rand.choice([]raylib.Color{raylib.BLUE, raylib.BLUE, raylib.BLUE, raylib.DARKBLUE})
	res.type = .Liquid
	res.material = .Water
	res.speed = 3
	res.touched = true
	return res
}
create_oil :: proc() -> (res: Cell) {
	res.color = rand.choice([]raylib.Color{raylib.BLACK, raylib.DARKBLUE})
	res.type = .Liquid
	res.material = .Oil
	res.speed = 1
	res.touched = true
	res.isFlammable = true
	res.isFloater = true
	return res
}
create_sand :: proc() -> (res: Cell) {
	res.color = rand.choice([]raylib.Color{raylib.YELLOW, raylib.YELLOW, raylib.ORANGE})
	res.type = .Grain
	res.material = .Sand
	res.touched = true
	res.speed = 1
	return res
}
create_wodden :: proc() -> (res: Cell) {
	res.color = rand.choice([]raylib.Color{raylib.BROWN, raylib.BROWN, raylib.DARKBROWN})
	res.type = .Grain
	res.isFlammable = true
	res.isFloater = true
	res.material = .Wodden
	res.touched = true
	res.speed = 1
	return res
}
create_lava :: proc() -> (res: Cell) {
	res.color = rand.choice([]raylib.Color{raylib.ORANGE, raylib.RED})
	res.material = .Fire
	res.isPersistent = true
	res.isCombusting = true
	res.type = .Liquid
	res.life = 1
	res.touched = true
	res.speed = 1
	return res
}
create_fire :: proc() -> (res: Cell) {
	res.color = rand.choice(
		[]raylib.Color{raylib.ORANGE, raylib.ORANGE, raylib.RED, raylib.YELLOW},
	)
	res.isCombusting = true
	res.life = LIFE_FIRE
	res.material = .Fire
	res.type = .Still
	res.touched = true
	res.speed = 1
	return res
}
create_smoke :: proc() -> (res: Cell) {
	res.color = raylib.GRAY
	res.type = .Gas_like
	res.life = LIFE_SMOKE
	res.material = .Smoke
	res.touched = true
	res.isFlammable = true
	res.speed = 3
	return res
}
create_stone :: proc() -> (res: Cell) {
	res.color = rand.choice([]raylib.Color{raylib.GRAY, raylib.DARKGRAY, raylib.BLACK})
	res.type = .Still
	res.material = .Stone
	res.touched = true
	return res
}

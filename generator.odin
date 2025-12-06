package main

import "core:math"
Generator :: struct {
	material: Material,
	pos:      vec2,
	range:    i32,
}

do_Generator :: proc(g: Generator, m: [][]Cell) {
	type := g.material
	for ix in -RADIO_CURSOR ..= RADIO_CURSOR {
		for iy in -RADIO_CURSOR ..= RADIO_CURSOR {
			yt := g.pos.y + iy
			xt := g.pos.x + ix
			if math.pow(f32(xt - g.pos.x), 2) + math.pow(f32(yt - g.pos.y), 2) <
			   math.pow(f32(RADIO_CURSOR), 2) {
				yt := yt
				xt := xt
				if is_out(xt, yt) {
					continue
				}
				if type == .Water {
					m[yt][xt] = create_water()
				} else if type == .Sand {
					m[yt][xt] = create_sand()
				} else if type == .Wodden {
					m[yt][xt] = create_wodden()
				} else if type == .Fire {
					m[yt][xt] = create_fire()
				} else if type == .Stone {
					m[yt][xt] = create_stone()
				} else if type == .Smoke {
					m[yt][xt] = create_smoke()
				} else if type == .Lava {
					m[yt][xt] = create_lava()
				}


			}
		}
	}
}

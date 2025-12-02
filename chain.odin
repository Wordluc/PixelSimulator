#+private
package main
handlerType :: proc(cellToUpdate: ^Cell, m: [][]Cell, try_x, try_y: i32) -> error
checkItIsInBoundaris :: proc(cellToUpdate: ^Cell, m: [][]Cell, try_x, try_y: i32) -> error {
	if try_x >= W_M || try_x < 0 {
		return "x: out of matrix"
	}
	if try_y >= H_M || try_y < 0 {
		return "y: out of matrix"
	}
	return nil
}
vec2 :: struct {
	x: i32,
	y: i32,
}
chain :: struct {
	handler:  handlerType,
	next:     ^chain,
	stopIfOk: bool,
	offsets:  []vec2,
}

NewChain :: proc(
	handler: handlerType,
	stopIfOk: bool,
	offsets: []vec2,
	next: ^chain = nil,
) -> (
	chain,
	error,
) {
	offsets := offsets
	if offsets == nil {
		offsets = []vec2{vec2{0, 0}}
	}
	return chain{handler = handler, stopIfOk = stopIfOk, next = next, offsets = offsets}, nil
}
RunChain :: proc(c: chain, m: [][]Cell, x, y: i32) -> error {
	e: error
	for offset in c.offsets {
		cellToUpdate := &m[y][x]
		xt := x + offset.x
		yt := y + offset.y
		e = checkItIsInBoundaris(cellToUpdate, m, xt, yt)
		if e != nil {
			continue
		}
		e = c.handler(cellToUpdate, m, xt, yt)
		if c.stopIfOk {
			break
		}
	}
	if c.next == nil {
		return e
	}
	return RunChain(c.next^, m, x, y)
}

RunChainWithNext :: proc(c: chain, m: [][]Cell, x, y: i32, next: chain) -> error {
	e := RunChain(c, m, x, y)
	if e != nil {
		return e
	}
	return RunChain(next, m, x, y)
}

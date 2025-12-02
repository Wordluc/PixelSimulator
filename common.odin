package main

import "core:strings"
error :: Maybe(string)

JoinErrors :: proc(errors: ..error) -> error {
	if errors == nil {
		return nil
	}
	res: ^strings.Builder = &strings.Builder{}
	for i in errors {
		if i == nil {
			continue
		}
		strings.write_string(res, i.(string))
	}
	return strings.to_string(res^)
}

module main

import os
import readline

pub struct Entry {
pub:
	is_dir        bool
	is_link       bool
	is_executable bool
	path          string
	base          string
}

pub fn entry(str string) Entry {
	return Entry{
		is_dir:        os.is_dir(str)
		is_link:       os.is_link(str)
		is_executable: os.is_executable(str)
		path:          str
		base:          os.base(str)
	}
}

pub fn page_size(app App) int {
	return (app.tui.window_height - 1) - 2
}

pub fn update(mut app App, path string) {
	app.selection = NoSelection{}
	if path == '..' || path == '.' {
		app.current_dir = os.norm_path(os.join_path(app.current_dir, path))
	} else {
		app.current_dir = os.norm_path(path)
	}
	os.chdir(app.current_dir) or {}
	app.entries = collect(app.current_dir, app.filter)
	sort(mut app.entries)

	if app.cursor_index >= app.entries.len {
		app.cursor_index = app.entries.len - 1
	}
	if app.page > app.entries.len / page_size(app) {
		app.page = 0
	}
}

pub fn update_change(mut app App, path string) {
	if !(os.exists(path) && os.is_dir(path)) {
		return
	}

	app.selection = NoSelection{}
	app.current_dir = os.norm_path(os.abs_path(path))
	os.chdir(app.current_dir) or {}
	app.entries = collect(app.current_dir, app.filter)
	sort(mut app.entries)

	if app.cursor_index >= app.entries.len {
		app.cursor_index = app.entries.len - 1
	}
	if app.page > app.entries.len / page_size(app) {
		app.page = 0
	}
}

pub fn get_input(mut app App, prompt string) string {
	app.tui.set_cursor_position(0, app.tui.window_height)
	app.tui.flush()
	app.requesting_input = true

	input := readline.read_line(prompt) or { '' }
	app.requesting_input = false

	return input
}

pub fn matches(expr string, checked string) bool {
	if checked == '..' || checked == '.' {
		return false
	}

	mut ei := 0
	mut ci := 0
	mut star := -1
	mut match_i := 0

	for ci < checked.len {
		if ei < expr.len {
			c := expr[ei]

			if c == `\\` && ei + 1 < expr.len {
				if checked[ci] == expr[ei + 1] {
					ei += 2
					ci++
					continue
				}
			}

			if c == `,` {
				ei++
				ci++
				continue
			}

			if c == `*` {
				star = ei
				match_i = ci
				ei++
				continue
			}

			if checked[ci] == c {
				ei++
				ci++
				continue
			}
		}

		if star != -1 {
			ei = star + 1
			match_i++
			ci = match_i
			continue
		}

		return false
	}

	for ei < expr.len && expr[ei] == `*` {
		ei++
	}

	return ei == expr.len
}

pub fn system(cmd string) int {
	c_cmd := cmd.str
	return unsafe { C.system(c_cmd) }
}

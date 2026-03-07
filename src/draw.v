module main

import term.ui as tui

pub fn draw_prefix(mut app App, entry Entry, current_index int, b int) {
	app.tui.set_bg_color(tui.Color{255, 255, 255})
	app.tui.set_color(tui.Color{0, 0, 0})

	if entry in app.action_list {
		app.tui.draw_point(1, b + 2)
		app.tui.draw_text(1, b + 2, '?')
	}
	if app.cursor_index == current_index {
		app.tui.draw_point(0, b + 2)
		app.tui.draw_text(0, b + 2, '>')
	}
	if app.selection is RangeSelection {
		mut range := app.selection as RangeSelection

		if range.start > range.end {
			range.start, range.end = range.end, range.start
		}

		if current_index == range.start {
			app.tui.draw_point(1, b + 2)
			app.tui.draw_text(1, b + 2, '[')
		} else if current_index == range.end {
			app.tui.draw_point(1, b + 2)
			app.tui.draw_text(1, b + 2, ']')
		} else if current_index > range.start && current_index < range.end {
			app.tui.draw_point(1, b + 2)
			app.tui.draw_text(1, b + 2, '|')
		}
	}

	app.tui.reset_bg_color()
	app.tui.reset_color()
}

pub fn draw_postfix(mut app App, entry Entry, draw_index int) {
	start := (app.tui.window_width - 1) - 2
	if entry.is_dir {
		app.tui.set_bg_color(tui.Color{66, 206, 245})
	} else if entry.is_link {
		app.tui.set_bg_color(tui.Color{43, 55, 227})
	} else if entry.is_executable {
		app.tui.set_bg_color(tui.Color{76, 242, 61})
	} else {
		app.tui.set_bg_color(tui.Color{245, 179, 66})
	}

	app.tui.draw_line(start, draw_index + 2, app.tui.window_width, draw_index + 2)

	app.tui.reset_bg_color()
}

pub fn draw_bar(mut app App) {
	app.tui.set_bg_color(tui.Color{66, 69, 245})
	app.tui.draw_line(0, (app.tui.window_height - 1), app.tui.window_width - 1, app.tui.window_height - 1)

	mut str := '${1 + app.page}/${app.entries.len / page_size(app) + 1} PAGE'
	if app.action_list.len > 0 {
		str += ' | SELECTED: ${app.action_list.len}'
	}
	app.tui.draw_text(0, (app.tui.window_height - 1), str)

	app.tui.reset_bg_color()
}

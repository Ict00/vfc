module main

import term.ui as tui
import os

struct App {
mut:
	tui &tui.Context = unsafe { nil }
pub mut:
	selection        Selection     = NoSelection{}
	action_list      []Entry       = []Entry{}
	filter           CollectFilter = CollectFilter{}
	entries          []Entry       = []Entry{}
	current_dir      string        = '/'
	cursor_index     int
	page             int
	requesting_input bool
}

fn frame(x voidptr) {
	mut app := unsafe { &App(x) }

	if app.requesting_input {
		return
	}

	app.tui.clear()
	app.tui.set_bg_color(tui.Color{ r: 219, g: 18, b: 34 })
	app.tui.draw_line(0, 0, app.tui.window_width - 1, 0)
	app.tui.set_cursor_position(0, 0)
	app.tui.draw_text(0, 0, app.current_dir)
	app.tui.reset_bg_color()

	entries_per_page := page_size(app)
	mut b := 0
	max_characters := (app.tui.window_width - 1) - 4

	for i in (entries_per_page * app.page) .. ((app.page + 1) * entries_per_page) {
		if i >= app.entries.len {
			break
		}

		entry := app.entries[i]
		entry_basename := app.entries[i].base

		draw_prefix(mut app, entry, i, b)
		if entry_basename.len < max_characters {
			app.tui.draw_text(2, b + 2, entry_basename)
		} else {
			changed := entry_basename[0..max_characters - 3] + '...'
			app.tui.draw_text(2, b + 2, changed)
		}

		draw_postfix(mut app, entry, b)

		b += 1
	}
	draw_bar(mut app)

	app.tui.set_cursor_position(0, 0)
	app.tui.reset()
	app.tui.flush()
}

fn main() {
	mut app := &App{}
	app.current_dir = os.getwd()
	app.entries = collect(app.current_dir, app.filter)
	sort(mut app.entries)

	app.tui = tui.init(
		user_data:   app
		event_fn:    event
		frame_fn:    frame
		hide_cursor: true
	)
	app.tui.run()!
}

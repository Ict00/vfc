module main

import term.ui as tui

pub struct MainContext {}

pub fn (c MainContext) frame(mut app App) {
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

pub fn (mut c MainContext) input(e &tui.Event, mut app App) {
	if app.requesting_input {
		return
	}

	if e.typ == .key_down {
		match e.code {
			.r {
				remove(mut app)
			}
			.v {
				change_filter(mut app)
			}
			.semicolon {
				process(mut app)
			}
			.c {
				copy_cmd(mut app)
			}
			.y {
				mass_select(mut app)
			}
			.m {
				move(mut app)
			}
			.e {
				move_to(mut app)
			}
			.b {
				add_current_to_bookmarks(mut app)
			}
			.f {
				filter_search(mut app)
			}
			.x {
				jump_to_entry(mut app)
			}
			.left_square_bracket {
				start_range(mut app)
			}
			.right_square_bracket {
				end_range(mut app)
			}
			.escape {
				exit(0)
			}
			.n {
				rename(mut app)
			}
			.w, .up {
				move_up(mut app)
			}
			.k {
				previous_page(mut app)
			}
			.l {
				next_page(mut app)
			}
			.s, .down {
				move_down(mut app)
			}
			.i {
				add_current(mut app)
			}
			.enter, .d {
				go_next_dir(mut app)
			}
			.a {
				go_back(mut app)
			}
			.u {
				clear_action_list(mut app)
			}
			else {
				// Skip
			}
		}
	}
	if e.typ == .mouse_down {
		if e.button == .left {
			go_next_dir(mut app)
		}
		if e.button == .right {
			go_back(mut app)
		}
	}
	if e.typ == .mouse_scroll {
		if e.direction == .down {
			move_up(mut app)
		}
		if e.direction == .up {
			move_down(mut app)
		}
	}
}

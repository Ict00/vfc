module main

import term.ui as tui

pub fn event(e &tui.Event, x voidptr) {
	mut app := unsafe { &App(x) }

	if app.requesting_input {
		return
	}

	if e.typ == .key_down {
		match e.code {
			.q {
				exit(0)
			}
			.r {
				remove(mut app)
			}
			.v {
				change_filter(mut app)
			}
			.semicolon {
				process(mut app, false)
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
			.w {
				move_up(mut app)
			}
			.k {
				previous_page(mut app)
			}
			.l {
				next_page(mut app)
			}
			.s {
				move_down(mut app)
			}
			.i {
				add_current(mut app)
			}
			.enter {
				go_next_dir(mut app)
			}
			.d {
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

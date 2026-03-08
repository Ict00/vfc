module main

import term.ui as tui
import os

struct App {
mut:
	tui &tui.Context = unsafe { nil }
pub mut:
	selection        Selection      = NoSelection{}
	action_list      []Entry        = []Entry{}
	bookmarks        []Entry        = []Entry{}
	filter           CollectFilter  = CollectFilter{}
	entries          []Entry        = []Entry{}
	ctx              ControlContext = MainContext{}
	current_dir      string         = '/'
	cursor_index     int
	page             int
	requesting_input bool
}

fn input(e &tui.Event, x voidptr) {
	mut app := unsafe { &App(x) }

	match e.code {
		.f1, ._1 {
			app.ctx = MainContext{}
		}
		.f2, ._2 {
			app.ctx = BookmarkContext{}
		}
		.q {
			exit(0)
		}
		.escape {
			exit(0)
		}
		else {}
	}

	app.ctx.input(e, mut app)
}

fn frame(x voidptr) {
	mut app := unsafe { &App(x) }

	app.ctx.frame(mut app)
}

fn main() {
	mut app := &App{}
	app.current_dir = os.getwd()
	app.entries = collect(app.current_dir, app.filter)
	sort(mut app.entries)

	app.tui = tui.init(
		user_data:   app
		event_fn:    input
		frame_fn:    frame
		hide_cursor: true
	)
	app.tui.run()!
}

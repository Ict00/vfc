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
	scripts          []Script       = []Script{}
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
		.f3, ._3 {
			app.ctx = ScriptContext{}
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

	path := os.config_dir() or { '' }

	if path != '' {
		config_dir := os.join_path(path, 'vfc')
		if !(os.exists(config_dir) && os.is_dir(config_dir)) {
			os.mkdir(config_dir) or {}
		}

		for i in os.ls(config_dir) or { [] } {
			if i.ends_with('.sh') {
				script_path := os.join_path(config_dir, i)
				script := os.read_file(script_path) or { '' }
				app.scripts << Script{
					name:     i.split('.')[0]
					scenario: script
				}
			}
		}
	}

	app.tui = tui.init(
		user_data:   app
		event_fn:    input
		frame_fn:    frame
		hide_cursor: true
	)
	app.tui.run()!
}

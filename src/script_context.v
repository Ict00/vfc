module main

import term.ui as tui
import os

pub struct ScriptContext {
pub mut:
	page             int
	cursor_index     int
	executing_script bool
}

pub fn (ctx ScriptContext) frame(mut app App) {
	if ctx.executing_script {
		return
	}

	app.tui.clear()

	app.tui.set_bg_color(tui.Color{ r: 219, g: 18, b: 34 })
	app.tui.draw_line(0, 0, app.tui.window_width - 1, 0)
	app.tui.set_cursor_position(0, 0)
	app.tui.draw_text(0, 0, 'Scripts')
	app.tui.reset_bg_color()

	if app.scripts.len == 0 {
		app.tui.draw_text(0, 2, 'No scripts yet. Go to ${os.config_dir() or { '' }}/vfc and add some scripts there.')
		app.tui.flush()
		return
	}

	scripts_per_page := app.tui.window_height - 2
	max_characters := (app.tui.window_width - 1) - 1

	for i in (scripts_per_page * ctx.page) .. ((ctx.page + 1) * scripts_per_page) {
		if i >= app.scripts.len {
			break
		}

		line := app.scripts[i]

		if i == ctx.cursor_index {
			app.tui.draw_text(0, i + 2, '>')
			app.tui.set_bg_color(tui.Color{255, 255, 255})
			app.tui.set_color(tui.Color{0, 0, 0})
			app.tui.draw_line(0, i + 2, app.tui.window_width - 1, i + 2)
		}

		if line.name.len < max_characters {
			app.tui.draw_text(2, i + 2, line.name)
		} else {
			changed := line.name[0..max_characters - 3] + '...'
			app.tui.draw_text(2, i + 2, changed)
		}

		app.tui.reset_color()
		app.tui.reset_bg_color()
	}

	app.tui.reset()
	app.tui.flush()
}

pub fn (mut ctx ScriptContext) input(e &tui.Event, mut app App) {
	if ctx.executing_script {
		return
	}

	if e.typ == .key_down {
		match e.code {
			.enter, .d {
				use_script(mut app, mut ctx)
			}
			.up, .w {
				script_up(mut app, mut ctx)
			}
			.down, .s {
				script_down(mut app, mut ctx)
			}
			else {}
		}
	}

	if e.typ == .mouse_scroll {
		if e.direction == .up {
			script_up(mut app, mut ctx)
		}
		if e.direction == .down {
			script_down(mut app, mut ctx)
		}
	}

	if e.typ == .mouse_down && e.button == .left {
		use_script(mut app, mut ctx)
	}
}

fn use_script(mut app App, mut ctx ScriptContext) {
	if app.scripts.len > 0 {
		app.tui.clear()
		app.tui.set_cursor_position(0, 0)
		app.tui.show_cursor()
		app.tui.flush()

		ctx.executing_script = true

		app.scripts[ctx.cursor_index].use(mut app)
		app.ctx = MainContext{}

		app.tui.hide_cursor()
		app.tui.flush()
	}
}

fn script_up(mut app App, mut ctx ScriptContext) {
	ctx.cursor_index -= 1
	if ctx.cursor_index < 0 {
		ctx.cursor_index = app.scripts.len - 1
		ctx.page = 0
	}

	if ctx.cursor_index < ctx.page * (app.tui.window_height - 2) {
		ctx.page -= 1
	}
}

fn script_down(mut app App, mut ctx ScriptContext) {
	ctx.cursor_index += 1
	if ctx.cursor_index >= app.scripts.len {
		ctx.cursor_index = 0
		ctx.page = app.scripts.len / (app.tui.window_height - 2)
	}

	if ctx.cursor_index >= (ctx.page + 1) * (app.tui.window_height - 2) {
		ctx.page += 1
	}
}

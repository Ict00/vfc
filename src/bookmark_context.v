module main

import term.ui as tui

pub struct BookmarkContext {
pub mut:
	cursor_index int
	page         int
}

pub fn (ctx BookmarkContext) frame(mut app App) {
	app.tui.clear()

	app.tui.set_bg_color(tui.Color{ r: 219, g: 18, b: 34 })
	app.tui.draw_line(0, 0, app.tui.window_width - 1, 0)
	app.tui.draw_text(0, 0, 'Bookmarks')
	app.tui.reset_bg_color()

	if app.bookmarks.len == 0 {
		app.tui.draw_text(0, 2, 'No bookmarks yet. Return to normal mode and press B to add current directory to bookmarks.')
		app.tui.flush()
		return
	}

	bookmarks_per_page := app.tui.window_height - 2
	max_characters := (app.tui.window_width - 1) - 1

	for i in (bookmarks_per_page * ctx.page) .. ((ctx.page + 1) * bookmarks_per_page) {
		if i >= app.bookmarks.len {
			break
		}

		line := app.bookmarks[i]

		if i == ctx.cursor_index {
			app.tui.draw_text(0, i + 2, '>')
			app.tui.set_bg_color(tui.Color{255, 255, 255})
			app.tui.set_color(tui.Color{0, 0, 0})
			app.tui.draw_line(0, i + 2, app.tui.window_width - 1, i + 2)
		}

		if line.path.len < max_characters {
			app.tui.draw_text(2, i + 2, line.path)
		} else {
			changed := line.path[0..max_characters - 3] + '...'
			app.tui.draw_text(2, i + 2, changed)
		}

		app.tui.reset_color()
		app.tui.reset_bg_color()
	}

	app.tui.flush()
}

pub fn (mut ctx BookmarkContext) input(e &tui.Event, mut app App) {
	if app.bookmarks.len == 0 {
		return
	}

	if e.typ == .key_down {
		match e.code {
			.w, .up {
				up(mut app, mut ctx)
			}
			.s, .down {
				down(mut app, mut ctx)
			}
			.enter, .d {
				goto_bookmark(mut app, mut ctx)
			}
			.r {
				app.bookmarks.delete(ctx.cursor_index)

				if ctx.cursor_index >= app.bookmarks.len {
					ctx.cursor_index = app.bookmarks.len - 1
				}
			}
			else {}
		}
	}
	if e.typ == .mouse_scroll {
		if e.direction == .up {
			up(mut app, mut ctx)
		} else if e.direction == .down {
			down(mut app, mut ctx)
		}
	}
	if e.typ == .mouse_down {
		if e.button == .left {
			goto_bookmark(mut app, mut ctx)
		}
	}

	return
}

fn goto_bookmark(mut app App, mut ctx BookmarkContext) {
	if app.bookmarks.len > 0 {
		update_change(mut app, app.bookmarks[ctx.cursor_index].path)
		app.ctx = MainContext{}
	}
}

fn up(mut app App, mut ctx BookmarkContext) {
	ctx.cursor_index -= 1
	if ctx.cursor_index < 0 {
		ctx.cursor_index = app.bookmarks.len - 1
		ctx.page = 0
	}

	if ctx.cursor_index < ctx.page * (app.tui.window_height - 2) {
		ctx.page -= 1
	}
}

fn down(mut app App, mut ctx BookmarkContext) {
	ctx.cursor_index += 1
	if ctx.cursor_index >= app.bookmarks.len {
		ctx.cursor_index = 0
		ctx.page = app.bookmarks.len / (app.tui.window_height - 2)
	}

	if ctx.cursor_index >= (ctx.page + 1) * (app.tui.window_height - 2) {
		ctx.page += 1
	}
}

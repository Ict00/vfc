module main

import os

pub fn move_up(mut app App) {
	if app.cursor_index - 1 >= 0 {
		app.cursor_index--
	}
	if app.cursor_index < app.page * page_size(app) {
		app.page--
	}

	if app.selection is RangeSelection {
		(app.selection as RangeSelection).start = app.cursor_index
	}
}

pub fn move_down(mut app App) {
	if app.cursor_index + 1 < app.entries.len {
		app.cursor_index++
	}
	if app.cursor_index >= (app.page + 1) * page_size(app) {
		app.page++
	}

	if app.selection is RangeSelection {
		(app.selection as RangeSelection).start = app.cursor_index
	}
}

pub fn go_next_dir(mut app App) {
	selected_dir := app.entries[app.cursor_index]

	if selected_dir.is_dir {
		update(mut app, selected_dir.path)
	}
}

pub fn go_back(mut app App) {
	update(mut app, '..')
}

pub fn process(mut app App, has_output bool) {
	command := get_input(mut app, '> ')

	if has_output {
		// TODO: Implement later (with Contexts)
	}

	mut x := os.start_new_command(command) or { os.Command{} }
	x.close() or {}
	update(mut app, '.')
}

pub fn move_to(mut app App) {
	go_dir := get_input(mut app, '> ')
	update_change(mut app, go_dir)
}

pub fn filter_search(mut app App) {
	expr := get_input(mut app, '> ')

	app.entries = app.entries.filter(fn [expr] (it Entry) bool {
		return matches(expr, it.base) || it.base == '..' || it.base == '.'
	})
}

pub fn jump_to_entry(mut app App) {
	expr := get_input(mut app, '> ')

	for i, entry in app.entries {
		if matches(expr, entry.base) {
			app.cursor_index = i
			app.page = i / page_size(app)
			break
		}
	}
}

pub fn move(mut app App) {
	if app.action_list.len == 0 {
		return
	}

	new_path := app.entries[app.cursor_index].path
	if !app.entries[app.cursor_index].is_dir {
		return
	}

	for i in app.action_list {
		base := i.base
		dest := os.join_path(new_path, base)
		os.mv(i.path, dest) or {}
	}

	clear_action_list(mut app)
	update(mut app, '.')
}

pub fn mass_select(mut app App) {
	expr := get_input(mut app, '')
	for i in app.entries {
		if matches(expr, i.base) {
			if i !in app.action_list {
				app.action_list << i
			}
		}
	}
}

pub fn copy_cmd(mut app App) {
	if app.action_list.len == 0 {
		return
	}

	new_path := app.entries[app.cursor_index].path
	if !app.entries[app.cursor_index].is_dir {
		return
	}

	for i in app.action_list {
		if !i.is_dir {
			os.cp(i.path, new_path, os.CopyParams{}) or {}
		} else {
			os.cp_all(i.path, os.join_path(new_path, i.base), true) or {}
		}
	}

	clear_action_list(mut app)
	update(mut app, '.')
}

pub fn rename(mut app App) {
	if app.action_list.len == 0 {
		return
	}

	new_name := get_input(mut app, 'New name: ')

	if app.action_list.len == 1 {
		old_path := app.action_list[0].path
		new_path := os.join_path(os.dir(old_path), new_name)
		os.mv(old_path, new_path) or {}
		clear_action_list(mut app)
		update(mut app, '.')
	} else {
		splt := new_name.split('.')
		name := splt[0..splt.len - 1].join('.')
		mut extension := ''
		if splt.len >= 2 {
			extension = splt.last()
		}
		mut b := 1
		for i in app.action_list {
			new_path := os.join_path(os.dir(i.path), '${name}${b}.${extension}')
			os.mv(i.path, new_path) or {}
			b++
		}
		clear_action_list(mut app)
		update(mut app, '.')
	}
}

pub fn add_current(mut app App) {
	x := app.entries[app.cursor_index]
	if x in app.action_list {
		app.action_list = app.action_list.filter(fn [x] (it Entry) bool {
			return it.path != x.path
		})
	} else {
		app.action_list << app.entries[app.cursor_index]
	}
}

pub fn end_range(mut app App) {
	if app.selection is RangeSelection {
		mut ranges := app.selection as RangeSelection
		app.selection = NoSelection{}

		if ranges.end < ranges.start {
			ranges.end, ranges.start = ranges.start, ranges.end
		}

		for i in ranges.get_selected_entries(app.entries) {
			if i !in app.action_list {
				app.action_list << i
			}
		}
	}
}

pub fn start_range(mut app App) {
	if app.selection is NoSelection {
		app.selection = RangeSelection{
			start: app.cursor_index
			end:   app.cursor_index
		}
	}
}

pub fn clear_action_list(mut app App) {
	app.action_list.clear()
}

pub fn next_page(mut app App) {
	size := page_size(app)
	max := app.entries.len / size
	if app.page + 1 <= max {
		if app.cursor_index + size < app.entries.len {
			app.cursor_index += size
		} else {
			app.cursor_index = app.entries.len - 1
		}
		app.page += 1
	}
}

pub fn previous_page(mut app App) {
	if app.page - 1 >= 0 {
		app.cursor_index -= page_size(app)
		app.page--
	}
}

pub fn remove(mut app App) {
	if app.action_list.len == 0 {
		return
	}

	answer := get_input(mut app, 'Are you sure? (yes/no) ')
	if answer == 'yes' {
		for i in app.action_list {
			if i.is_dir {
				os.rmdir_all(i.path) or {}
			} else {
				os.rm(i.path) or {}
			}
		}
		clear_action_list(mut app)
		update(mut app, '.')
	}
}

pub fn change_filter(mut app App) {
	new_filter_str := get_input(mut app, '')
	if new_filter_str.contains('H') {
		app.filter.hide_hidden = true
	}
	if new_filter_str.contains('h') {
		app.filter.hide_hidden = false
	}

	if new_filter_str.contains('d') {
		app.filter.hide_dirs = false
	}
	if new_filter_str.contains('D') {
		app.filter.hide_dirs = true
	}

	if new_filter_str.contains('f') {
		app.filter.hide_files = false
	}
	if new_filter_str.contains('F') {
		app.filter.hide_files = true
	}

	update(mut app, '.')
}

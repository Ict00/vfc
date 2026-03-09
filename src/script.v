module main

import os
import readline

pub struct Script {
pub:
	name     string
	scenario string
}

pub fn (script Script) use(mut app App) {
	if app.action_list.len > 0 {
		joined_list := app.action_list.map("\"${it.path.replace('"', '\\"')}\"").join(' ')

		for entry in app.action_list {
			escaped_entry := "\"${entry.path.replace('"', '\\"')}\""

			execute := script.scenario.replace('@{}', joined_list).replace('{}', escaped_entry)
			res := os.execute(execute)
			println(res.output)
		}
	} else {
		println(os.execute(script.scenario).output)
	}

	readline.read_line('Press ENTER to return...') or {}

	app.action_list.clear()
	update(mut app, '.')
}

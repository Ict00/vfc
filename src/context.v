module main

import term.ui as tui

pub interface ControlContext {
	frame(mut app App)
mut:
	input(e &tui.Event, mut app App)
}

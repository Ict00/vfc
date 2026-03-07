module main

import term.ui as tui

pub interface ControlContext {
	frame(mut app App)
	input(e &tui.Event, mut app App)
}

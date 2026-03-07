module main

pub interface Selection {
	get_selected_entries([]Entry) []Entry
}

pub struct NoSelection {}

pub struct RangeSelection {
pub mut:
	start int
	end   int
}

pub fn (r RangeSelection) get_selected_entries(entries []Entry) []Entry {
	if r.start < 0 || r.end >= entries.len || r.start > r.end {
		return []
	}
	return entries[r.start..r.end + 1]
}

pub fn (n NoSelection) get_selected_entries(_ []Entry) []Entry {
	return []
}

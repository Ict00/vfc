module main

import os

pub struct CollectFilter {
pub mut:
	hide_hidden bool
	hide_files  bool
	hide_dirs   bool
}

pub fn sort(mut entries []Entry) {
	entries.sort(a.path < b.path)
	entries.insert(0, entry('..'))
	entries.insert(0, entry('.'))
}

pub fn collect(path string, filter CollectFilter) []Entry {
	mut result := []Entry{}

	for str in os.ls(path) or { [] } {
		if filter.hide_hidden && str.starts_with('.') {
			// Skip
		} else if os.is_dir(str) && !filter.hide_dirs {
			result << entry(os.abs_path(str))
		} else if os.is_file(str) && !filter.hide_files {
			result << entry(os.abs_path(str))
		}
	}

	return result
}

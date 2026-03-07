module main

import os

pub struct CollectFilter {
pub mut:
	hide_hidden bool
	hide_files  bool
	hide_dirs   bool
}

pub fn sort(mut entries []string) {
	entries.sort(a < b)
	entries.insert(0, '..')
	entries.insert(0, '.')
}

pub fn collect(path string, filter CollectFilter) []string {
	mut result := []string{}

	for str in os.ls(path) or { [] } {
		if str == '.' || str == '..' {
			result << str
		} else if filter.hide_hidden && str.starts_with('.') {
			// Skip
		} else if os.is_dir(str) && !filter.hide_dirs {
			result << os.abs_path(str)
		} else if os.is_file(str) && !filter.hide_files {
			result << os.abs_path(str)
		}
	}

	return result
}

use fmt::*;
use os;
use fs;
use io;
use sort;
use strings;
use sort::cmp;

export fn run(files: []str) int = {
	for (let file .. files) {
		const f = match (os::open(file)) {
			case let f: io::file =>
				yield f;
			case let e: fs::error =>
				printfln("sort: {}: {}", file, fs::strerror(e))!;
				return 1;
			case nomem =>
				printfln("sort: {}: out of memory", file)!;
				return 1;
		};
		defer io::close(f)!;

		const raw: []u8 = io::drain(f)!;
		const text: str = strings::fromutf8(raw)!;
		const lines: []str = strings::split(text, "\n")!;

		let n = len(lines);
		if (n > 0 && len(lines[n - 1]) == 0) {
			n -= 1;
		};

		for (let i = 0z; i < n; i += 1) {
			lines[i] = strings::ltrim(lines[i]);
		};

		sort::sort(lines: []opaque, size(str), &cmp::strs)!;

		for (let i = 0z; i < n; i += 1) {
			println(lines[i])!;
		};
	};
	return 0;
};

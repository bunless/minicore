use fmt::*;
use fs;
use io;
use os;

export fn run(files: []str) int = {
	// flag byte per byte value: 1 = whitespace, 3 = newline
	let tbl: [256]u8 = [0...];
	tbl[0x20] = 1; // space
	for (let i = 0x09z; i <= 0x0d; i += 1) tbl[i] = 1; // tab, newline, vertical tab, form feed, carriage return
	tbl[0x0a] = 3; // newline: whitespace plus the newline bit

	let buf: [262144]u8 = [0...]; // 256 KiB chunks
	let status = 0;

	// no arguments means read stdin once, treated as "-"
	const inputs = if (len(files) == 0) 1z else len(files);

	for (let i = 0z; i < inputs; i += 1) {
		const name = if (len(files) == 0) "-" else files[i];

		let f: io::handle = os::stdin;
		if (name != "-") {
			f = match (os::open(name)) {
			case let opened: io::file => yield opened;
			case let e: fs::error =>
				errorfln("wc: {}: {}", name, fs::strerror(e))!;
				status = 1;
				continue;
			};
		};

		let l = 0z, w = 0z, total = 0z;
		let prev: u8 = 1; // start as "after whitespace" so a leading word counts
		let failed = false;

		for (true) {
			const n = match (io::read(f, buf[..])) {
				case let n: size => yield n;
				case io::EOF => break;
				case let e: io::error =>
					errorfln("wc: {}: {}", name, io::strerror(e))!;
					status = 1;
					failed = true;
					break;
			};

			total += n;
			for (let b .. buf[..n]) {
				const t = tbl[b: size];
				w += (prev & ~t & 1): size; // word starts: whitespace, then non-space
				l += (t >> 1): size;        // only the value 3 has this bit
				prev = t & 1;
			};
		};

		if (name != "-") io::close(f)!; // never close stdin
		if (failed) continue;

		// errorfln("DEBUG {} {} {} {} failed={}", l, w, total, name, failed)!;
		//if (len(files) == 0) printfln("{:7} {:7} {:7}", l, w, total)!;
		printfln("{:4} {:4} {} {}", l, w, total, name)!;
	};
	return status;
};
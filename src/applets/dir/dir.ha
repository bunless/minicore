use fmt::*;
use fs;
use os;
use strings;

export fn run(args: []str) int = {
	if (len(args) == 0 || args[0] == ".") {
		const cdir = os::getcwd();
		let dirs = match (os::readdir(cdir)) {
			case let dirs: []fs::dirent => yield dirs;
			case let e: fs::error =>
				printfln("ls: {}", fs::strerror(e))!;
				return 1;
			case nomem =>
				errorfln("ls: Could not allocate enough memory")!;
				return 1;
		};

		// insertion sort by name, ignoring case
		for (let i = 1z; i < len(dirs); i += 1) {
			let j = i;
			for (j > 0) {
				// should dirs[j] be listed before dirs[j - 1]?
				const x = strings::toutf8(dirs[j].name), y = strings::toutf8(dirs[j - 1].name);
				const n = if (len(x) < len(y)) len(x) else len(y);
				let less = false, decided = false;

				// first pass: compare lowercased bytes
				for (let k = 0z; k < n; k += 1) {
					let p = x[k], q = y[k];
					if (p >= 'A': u8 && p <= 'Z': u8) p += 32;
					if (q >= 'A': u8 && q <= 'Z': u8) q += 32;
					if (p != q) {
						less = p < q;
						decided = true;
						break;
					};
				};

				// same letters so far: shorter name goes first
				if (!decided && len(x) != len(y)) {
					less = len(x) < len(y);
					decided = true;
				};

				// same letters, different case: plain byte order
				if (!decided)
					for (let k = 0z; k < n; k += 1) if (x[k] != y[k]) {
						less = x[k] < y[k];
						break;
					};

				if (!less) break;

				const tmp = dirs[j];
				dirs[j] = dirs[j - 1];
				dirs[j - 1] = tmp;
				j -= 1;
			};
		};

		for (let dir .. dirs) {
			if (strings::hasprefix(dir.name, ".")) continue;
			printf("{}  ", dir.name)!;
		};
		printf("\n")!;
	};
	return 0;
};

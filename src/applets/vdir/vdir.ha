use fmt::*;
use fs;
use io;
use os;
use rt;
use strings;
use time::date;

export fn run(args: []str) int = {
	if (len(args) == 0 || args[0] == ".") {
		const cdir = os::getcwd();
		let dirs = match (os::readdir(cdir)) {
		case let dirs: []fs::dirent => yield dirs;
		case let e: fs::error =>
			printfln("vdir: {}", fs::strerror(e))!;
			return 1;
		case nomem =>
			errorfln("vdir: Could not allocate enough memory")!;
			return 1;
		};

		// insertion sort by name, ignoring case
		for (let i = 1z; i < len(dirs); i += 1) {
			let j = i;
			for (j > 0) {
				// should dirs[j] be listed before dirs[j - 1]?
				const x = strings::toutf8(dirs[j].name);
				const y = strings::toutf8(dirs[j - 1].name);
				const n = if (len(x) < len(y)) len(x) else len(y);
				let less = false;
				let decided = false;

				// first pass: compare lowercased bytes
				for (let k = 0z; k < n; k += 1) {
					let p = x[k];
					let q = y[k];
					if (p >= ('A': u8) && p <= ('Z': u8)) p += 32;
					if (q >= ('A': u8) && q <= ('Z': u8)) q += 32;
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
				if (!decided) {
					for (let k = 0z; k < n; k += 1) {
						if (x[k] != y[k]) {
							less = x[k] < y[k];
							break;
						};
					};
				};

				if (!less) break;

				const tmp = dirs[j];
				dirs[j] = dirs[j - 1];
				dirs[j - 1] = tmp;
				j -= 1;
			};
		};

		// read the name tables once; if one is unreadable, ids stay numbers
		let pwraw: []u8 = [];
		let pwlines: []str = [];
		match (os::open("/etc/passwd")) {
		case let f: io::file =>
			pwraw = io::drain(f)!;
			io::close(f)!;
			pwlines = strings::split(strings::fromutf8(pwraw)!, "\n")!;
		case let e: fs::error => yield;
		};
		defer free(pwraw);
		defer free(pwlines);

		let grraw: []u8 = [];
		let grlines: []str = [];
		match (os::open("/etc/group")) {
		case let f: io::file =>
			grraw = io::drain(f)!;
			io::close(f)!;
			grlines = strings::split(strings::fromutf8(grraw)!, "\n")!;
		case let e: fs::error => yield;
		};
		defer free(grraw);
		defer free(grlines);

		// current time, used to decide between "Oct  5 01:53" and "Oct  5  2024"
		let nowd = date::localnow();

		// first pass: total blocks and column widths (GNU ls style)
		let total_blocks: u64 = 0;
		let max_nlink: size = 0;
		let max_owner: size = 0;
		let max_group: size = 0;
		let max_size: size = 0;
		for (let dir .. dirs) {
			if (strings::hasprefix(dir.name, ".")) continue;

			const st = match (os::stat(dir.name)) {
			case let st: fs::filestat => yield st;
			case let e: fs::error => continue;
			};

			let rst = rt::st { ... };
			let nlink: u64 = 1;
			let blocks: u64 = 0;
			match (rt::lstat(dir.name, &rst)) {
			case void =>
				nlink = rst.nlink: u64;
				blocks = rst.blocks: u64;
			case let e: rt::errno => void;
			};
			total_blocks += blocks;

			const nlinkstr = asprintf("{}", nlink)!;
			defer free(nlinkstr);
			const sizestr = asprintf("{}", st.sz)!;
			defer free(sizestr);
			if (len(nlinkstr) > max_nlink) max_nlink = len(nlinkstr);
			if (len(sizestr) > max_size) max_size = len(sizestr);

			const uidstr = asprintf("{}", st.uid)!;
			defer free(uidstr);
			const gidstr = asprintf("{}", st.gid)!;
			defer free(gidstr);
			let owner = uidstr;
			let group = gidstr;

			// passwd format: name:x:uid:...  group format: name:x:gid:...
			for (let line .. pwlines) {
				const fields = match (strings::split(line, ":")) {
				case let xs: []str => yield xs;
				case nomem => break;
				};
				defer free(fields);
				if (len(fields) > 2 && fields[2] == uidstr) {
					owner = fields[0];
					break;
				};
			};
			for (let line .. grlines) {
				const fields = match (strings::split(line, ":")) {
				case let xs: []str => yield xs;
				case nomem => break;
				};
				defer free(fields);
				if (len(fields) > 2 && fields[2] == gidstr) {
					group = fields[0];
					break;
				};
			};

			if (len(owner) > max_owner) max_owner = len(owner);
			if (len(group) > max_group) max_group = len(group);
		};

		printfln("total {}", total_blocks / 2)!;

		for (let dir .. dirs) {
			if (strings::hasprefix(dir.name, ".")) continue;

			const st = match (os::stat(dir.name)) {
			case let st: fs::filestat => yield st;
			case let e: fs::error =>
				errorfln("vdir: {}: {}", dir.name, fs::strerror(e))!;
				continue;
			};

			let rst = rt::st { ... };
			let nlink: u64 = 1;
			match (rt::lstat(dir.name, &rst)) {
			case void =>
				nlink = rst.nlink: u64;
			case let e: rt::errno => void;
			};

			// owner and group start as the numeric ids, replaced by names if found
			const uidstr = asprintf("{}", st.uid)!;
			defer free(uidstr);
			const gidstr = asprintf("{}", st.gid)!;
			defer free(gidstr);
			let owner = uidstr;
			let group = gidstr;

			// passwd format: name:x:uid:...  group format: name:x:gid:...
			for (let line .. pwlines) {
				const fields = match (strings::split(line, ":")) {
				case let xs: []str => yield xs;
				case nomem => break;
				};
				defer free(fields);
				if (len(fields) > 2 && fields[2] == uidstr) {
					owner = fields[0];
					break;
				};
			};
			for (let line .. grlines) {
				const fields = match (strings::split(line, ":")) {
				case let xs: []str => yield xs;
				case nomem => break;
				};
				defer free(fields);
				if (len(fields) > 2 && fields[2] == gidstr) {
					group = fields[0];
					break;
				};
			};

			const nlinkstr = asprintf("{}", nlink)!;
			defer free(nlinkstr);
			const sizestr = asprintf("{}", st.sz)!;
			defer free(sizestr);
			const nlinkpad = strings::lpad(nlinkstr, ' ', max_nlink)!;
			defer free(nlinkpad);
			const ownerpad = strings::rpad(owner, ' ', max_owner)!;
			defer free(ownerpad);
			const grouppad = strings::rpad(group, ' ', max_group)!;
			defer free(grouppad);
			const sizepad = strings::lpad(sizestr, ' ', max_size)!;
			defer free(sizepad);

			let d = date::from_instant(date::LOCAL, st.mtime);
			const month = date::asformat("%b", &d)!;
			defer free(month);
			const daypad = asprintf("{:2}", date::day(&d))!;
			defer free(daypad);
			let when: str = "";
			let freewhen = false;
			if (date::year(&d) == date::year(&nowd)) {
				const hm = date::asformat("%H:%M", &d)!;
				defer free(hm);
				when = asprintf("{} {} {}", month, daypad, hm)!;
				freewhen = true;
			} else {
				const yr = date::asformat("%Y", &d)!;
				defer free(yr);
				when = asprintf("{} {}  {}", month, daypad, yr)!;
				freewhen = true;
			};
			defer if (freewhen) free(when);

			let dispname = dir.name;
			let freename = false;
			if (fs::islink(st.mode)) {
				match (os::readlink(dir.name)) {
				case let target: str =>
					dispname = asprintf("{} -> {}", dir.name, target)!;
					freename = true;
				case let e: fs::error => void;
				};
			};
			defer if (freename) free(dispname);

			printfln("{} {} {} {} {} {} {}",
				fs::mode_str(st.mode),
				nlinkpad, ownerpad, grouppad, sizepad,
				when, dispname)!;
		};
	};

	return 0;
};
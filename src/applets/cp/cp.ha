use fmt::*;
use os;
use fs;
use io;

def BUFSZ = 32768z;

export fn run(args: []str) int = {
	let buf: *[BUFSZ]u8 = alloc([0...])!;
	defer free(buf);

	const st = match (os::stat(args[0])) {
		case let st: fs::filestat =>
			yield st;
		case let e: fs::error =>
			errorfln("cp: {}: {}", args[0], fs::strerror(e))!;
			return 1;
	};

	if (fs::isdir(st.mode)) {
		errorfln("cp: {}: is a directory, can't do that yet", args[0])!;
		return 1;
	};

	const f = match (os::open(args[0])) {
		case let f: io::file =>
			yield f;
		case let e: fs::error =>
			errorfln("cp: {}: {}", args[0], fs::strerror(e))!;
			return 1;
		case nomem =>
			errorfln("cp: {}: out of memory", args[0])!;
			return 1;
	};
	defer io::close(f)!;

	const perm = (st.mode: u32 & 0o7777): fs::mode;
	const dest = match (os::create(args[1], perm)) {
		case let d: io::file =>
			yield d;
		case let e: fs::error =>
			errorfln("cp: {}: {}", args[1], fs::strerror(e))!;
			return 1;
	};

	defer io::close(dest)!;

	for (true) {
		let n = match (io::read(f, buf)) {
			case let n: size =>
				yield n;
			case io::EOF =>
				break;
			case let e: io::error =>
				printfln("cp: {}: {}", args[0], io::strerror(e))!;
				break;
		};

		match (io::writeall(dest, buf[..n])) {
			case size => void;
			case let e: io::error =>
				errorfln("cp: {}: {}", args[1], io::strerror(e))!;
				return 1;
		};
	};
	return 0;
};

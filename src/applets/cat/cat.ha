use fmt;
use os;
use fs;
use io;

def BUFSZ = 32768z;

export fn run(files: []str) void = {
	let buf: *[BUFSZ]u8 = alloc([0...])!;
	defer free(buf);
	for (let file .. files) {
		const f = match (os::open(file)) {
		case let f: io::file =>
			yield f;
		case let e: fs::error =>
			fmt::printfln("cat: {}: {}", file, fs::strerror(e))!;
			continue;
		case nomem =>
			fmt::printfln("cat: {}: out of memory", file)!;
			continue;
		};

		for (true) {
			let n = match (io::read(f, buf)) {
			case let n: size =>
				yield n;
			case io::EOF =>
				break;
			case let e: io::error =>
				fmt::printfln("cat: {}: {}", file, io::strerror(e))!;
				break;
			};

			io::writeall(os::stdout, buf[..n])!;
		};

		io::close(f)!;
	};
};
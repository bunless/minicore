use fmt::*;
use os;
use fs;
use io;
use encoding::base32;

def BUFSZ = 57 * 1024z;

def LINESZ = 76z;

export fn run(args: []str) int = {
	if (len(args) == 0) {
		println("usage: minicore base32 <file>")!;
		return 1;
	};

	if (len(args) > 1) {
		errorfln("base32: extra operand '{}'", args[1])!;
		return 1;
	};

	let buf: *[BUFSZ]u8 = alloc([0...])!, line: *[LINESZ + 1]u8 = alloc([0...])!;
	let col: size = 0;
	defer free(buf);
	defer free(line);

	for (let a .. args) {
		const f = match (os::open(a)) {
			case let f: io::file => yield f;
			case let e: fs::error =>
				printfln("base32: {}: {}", a, fs::strerror(e))!;
				continue;
			case nomem =>
				printfln("base32: {}: out of memory", a)!;
				continue;
		};

		for (true) {
			let n = match (io::read(f, buf)) {
				case let n: size => yield n;
				case io::EOF => break;
				case let e: io::error =>
					printfln("base32: {}: {}", a, io::strerror(e))!;
					return 1;
			};

			let out: []u8 = match (base32::encodeslice(&base32::std_encoding, buf[..n])) {
				case let out: []u8 => yield out;
				case nomem =>
					printfln("base32: {}: out of memory", a)!;
					return 1;
			};

			for (let i = 0z; i < len(out); i += 1) {
				line[col] = out[i];
				col += 1;
				if (col == LINESZ) {
					io::writeall(os::stdout, line[..LINESZ])!;
					println("")!;
					col = 0;
				};
			};

			free(out);
		};
		io::close(f)!;
	};

	if (col > 0) {
		io::writeall(os::stdout, line[..col])!;
		println("")!;
	};
	return 0;
};

use crypto::blake2b;
use encoding::hex;
use fmt::*;
use fs;
use hash;
use io;
use os;

export fn run(files: []str) int = {
	let buf: [65536]u8 = [0...], digest: [64]u8 = [0...];

	// no arguments means read stdin once, treated as "-"
	const inputs = if (len(files) == 0) 1z else len(files);

	for (let i = 0z; i < inputs; i += 1) {
		const name = if (len(files) == 0) "-" else files[i];

		let f: io::handle = os::stdin;
		if (name != "-") {
			f = match (os::open(name)) {
				case let opened: io::file => yield opened;
				case let e: fs::error =>
					errorfln("b2sum: {}: {}", name, fs::strerror(e))!;
					return 1;
			};
		};

		// blake2b can't be reset, so make a fresh state per file
		let b2 = blake2b::blake2b([], 64);

		for (true) {
			const n = match (io::read(f, buf[..])) {
				case let n: size => yield n;
				case io::EOF => break;
				case let e: io::error =>
					errorfln("b2sum: {}: {}", name, io::strerror(e))!;
					return 1;
			};
			hash::write(&b2, buf[..n]);
		};

		if (name != "-") io::close(f)!;

		hash::sum(&b2, digest[..]);
		const hexstr = hex::encodestr(digest[..])!;
		defer free(hexstr);
		printfln("{}  {}", hexstr, name)!;
	};
	return 0;
};

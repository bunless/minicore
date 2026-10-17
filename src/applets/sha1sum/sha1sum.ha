use crypto::sha1;
use encoding::hex;
use fmt::*;
use fs;
use hash;
use io;
use os;

export fn run(files: []str) int = {
	let buf: [65536]u8 = [0...];
	let digest: [20]u8 = [0...];
	let sha = sha1::sha1();

	// no arguments means read stdin once, treated as "-"
	const inputs = if (len(files) == 0) 1z else len(files);

	for (let i = 0z; i < inputs; i += 1) {
		const name = if (len(files) == 0) "-" else files[i];

		let f: io::handle = os::stdin;
		if (name != "-") {
			f = match (os::open(name)) {
				case let opened: io::file => yield opened;
				case let e: fs::error =>
					errorfln("sha1sum: {}: {}", name, fs::strerror(e))!;
					return 1;
			};
		};

		hash::reset(&sha);
		let failed = false;

		for (true) {
			const n = match (io::read(f, buf[..])) {
				case let n: size => yield n;
				case io::EOF => break;
				case let e: io::error =>
					errorfln("sha1sum: {}: {}", name, io::strerror(e))!;
					return 1;
			};
			hash::write(&sha, buf[..n]);
		};

		if (name != "-") io::close(f)!;

		hash::sum(&sha, digest[..]);
		const hexstr = hex::encodestr(digest[..])!;
		defer free(hexstr);
		printfln("{}  {}", hexstr, name)!;
	};
	return 1;
};
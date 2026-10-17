use fmt::*;
use fs;
use hash;
use io;
use os;

// Algorithm in python
//  s = 0
//  for b in data:
//      s = (s >> 1) + ((s & 1) << 15) + b
//      s &= 0xFFFF 

export fn run(files: []str) int = {
	let buf: [65536]u8 = [0...];

	// no arguments means read stdin once, treated as "-"
	const inputs = if (len(files) == 0) 1z else len(files);

	for (let i = 0z; i < inputs; i += 1) {
		const name = if (len(files) == 0) "-" else files[i];

		let f: io::handle = os::stdin;
		if (name != "-") {
			f = match (os::open(name)) {
				case let opened: io::file => yield opened;
				case let e: fs::error =>
					errorfln("sum: {}: {}", name, fs::strerror(e))!;
					return 1;
			};
		};

    let checksum: uint = 0;
		let total: size = 0;

		for (true) {
			const n = match (io::read(f, buf[..])) {
				case let n: size => yield n;
				case io::EOF => break;
				case let e: io::error =>
					errorfln("sum: {}: {}", name, io::strerror(e))!;
					return 1;
			};
			for (let j = 0z; j < n; j += 1) {
				checksum = (checksum >> 1) + ((checksum & 1) << 15) + (buf[j]: uint);
				checksum &= 0xFFFF;
			};
			total += n;
		};

		if (name != "-") io::close(f)!;

		const blocks = (total + 1023z) / 1024z;
		if (len(files) == 0) printfln("{} {}", checksum, blocks)!;
		if (len(files) != 0) printfln("{} {} {}", checksum, blocks, name)!;

	};
	return 0;
};

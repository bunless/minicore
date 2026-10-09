use fmt;
use io;
use os;
use strings;
use strconv;

def CHUNKSZ = 65536z;

export fn run(args: []str) void = {
	let yes: str = "y";
	if (len(args) == 1) {
		yes = args[0];
	};

	let line = strings::concat(yes, "\n")!;
	defer free(line);
	const line8 = strings::toutf8(line);

	let buf: [CHUNKSZ]u8 = [0...];
	let n = len(buf) - (len(buf) % len(line8));

	for (true) {
		for (let i = 0z; i < n; i += 1) {
			buf[i] = line8[i % len(line8)];
		};
		io::writeall(os::stdout, buf[..n])!;
	};
};


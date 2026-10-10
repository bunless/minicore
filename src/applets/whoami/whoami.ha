use fmt::*;
use fs;
use io;
use os;
use strconv;
use strings;
use unix;

export fn run(args: []str) int = {
	const f = match (os::open("/etc/passwd")) {
	case let f: io::file => yield f;
	case let e: fs::error =>
		errorfln("whoami: /etc/passwd: {}", fs::strerror(e))!;
		return 1;
	};
	defer io::close(f)!;

	const raw: []u8 = io::drain(f)!;
	const text: str = strings::fromutf8(raw)!;
	const lines: []str = strings::split(text, "\n")!;
	defer free(raw);
	defer free(lines);

	const uid = strconv::utos(unix::geteuid());

	for (let line .. lines) {
		const fields: []str = match(strings::split(line, ":")) {
			case let xs: []str => yield xs;
			case nomem => 
				errorfln("whoami: couldn't allocate enough memory")!;
				return 1;
		};
		defer free(fields);
		// passwd format: name:x:uid:gid:comment:home:shell
		if (len(fields) > 2 && fields[2] == uid) {
			printfln("{}", fields[0])!;
			return 0;
		};
	};
	errorfln("whoami: cannot find name for user ID {}", uid)!;
	return 1;
};
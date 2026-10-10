use fmt::*;
use fs;
use os;
use path;

export fn run(args: []str) int = {
	if (len(args) < 2) {
		errorln("usage: mv source... dest")!;
		return 1;
	};

	const dest = args[len(args) - 1];
	const srcs = args[..len(args) - 1];

	const dest_is_dir = match (os::stat(dest)) {
		case let st: fs::filestat =>
			yield fs::isdir(st.mode);
		case fs::error =>
			yield false;
	};

	if (len(srcs) > 1 && !dest_is_dir) {
		errorfln("mv: target '{}' is not a directory", dest)!;
		return 1;
	};

	for (let src .. srcs) {
		let target = dest;
		if (dest_is_dir) {
			target = asprintf("{}/{}", dest, path::basename(src))!;
		};
		defer if (dest_is_dir) free(target);

		match (fs::move(os::cwd, src, target)) {
			case void =>
				yield;
			case let e: fs::error =>
				errorfln("mv: {}: {}", src, fs::strerror(e))!;
		};
	};
	return 0;
};

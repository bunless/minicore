use fmt;
use fs;
use os;
use path;

export fn run(args: []str) void = {
	if (len(args) < 2) {
		fmt::errorln("usage: mv source... dest")!;
		return;
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
		fmt::errorfln("mv: target '{}' is not a directory", dest)!;
		return;
	};

	for (let src .. srcs) {
		let target = dest;
		if (dest_is_dir) {
			target = fmt::asprintf("{}/{}", dest, path::basename(src))!;
		};
		defer if (dest_is_dir) free(target);

		match (fs::move(os::cwd, src, target)) {
		case void => yield;
		case let e: fs::error =>
			fmt::errorfln("mv: {}: {}", src, fs::strerror(e))!;
		};
	};
};
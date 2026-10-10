use fmt::*;
use fs;
use os;

export fn run(files: []str) int = {
	for (let file .. files) {
		match (os::stat(file)) {
			case let st: fs::filestat =>
				if (fs::isdir(st.mode)) {
					errorfln("rm: {}: is a directory, use rmdir", file)!;
				} else {
					match (os::remove(file)) {
						case void =>
							yield;
						case let e: fs::error =>
							errorfln("rm: {}: {}", file, fs::strerror(e))!;
					};
				};
			case let e: fs::error =>
				errorfln("rm: {}: {}", file, fs::strerror(e))!;
		};
	};
	return 0;
};

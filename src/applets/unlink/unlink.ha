use fmt::*;
use rt;

export fn run(files: []str) int = {
	for (let file .. files) {
		match (rt::unlink(file)) {
			case void =>
				yield;
			case let e: rt::errno =>
				errorfln("unlink: {}: {}", file, rt::strerror(e))!;
				return 1;
		};
	};
	return 0;
};

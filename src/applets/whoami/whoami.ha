use fmt::*;
use os;

export fn run(args: []str) int = {
	const user: str = match (os::getenv("USER")) {
		case let u: str =>
			yield u;
		case void =>
			return 1;
	};
	printf("{}", user)!;
	return 0;
};

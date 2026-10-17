use fmt::*;
use strconv::*;

fn parse(s: str) (int | void) = {
	match (stoi(s)) {
		case let n: int => return n;
		case invalid => void;
		case overflow => void;
	};
	return;
};

fn badnum(s: str) int = {
	errorf("seq: invalid number '{}'\n", s)!;
	return 1;
};

export fn run(args: []str) int = {
	let first = 1, step = 1, last = 0;
	if (len(args) == 1) {
		match (parse(args[0])) {
			case let n: int => last = n;
			case void => return badnum(args[0]);
		};
	} else if (len(args) == 2) {
		match (parse(args[0])) {
			case let n: int => first = n;
			case void => return badnum(args[0]);
		};
		match (parse(args[1])) {
			case let n: int => last = n;
			case void => return badnum(args[1]);
		};
	} else if (len(args) == 3) {
		match (parse(args[0])) {
			case let n: int => first = n;
			case void => return badnum(args[0]);
		};
		match (parse(args[1])) {
			case let n: int => step = n;
			case void => return badnum(args[1]);
		};
		match (parse(args[2])) {
			case let n: int => last = n;
			case void => return badnum(args[2]);
		};
		if (step == 0) {
			errorf("seq: zero increment\n")!;
			return 1;
		};
	} else {
		printfln("Usage: seq [FIRST [STEP]] LAST")!;
		return 1;
	};

	if (step > 0) for (let i = first; i <= last; i += step) printf("{}\n", i)!;
	if (step <= 0) for (let i = first; i >= last; i += step) printf("{}\n", i)!;
	return 0;
};

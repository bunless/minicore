use fmt;
use time::date;
use time::chrono;

export fn run(args: []str) void = {
	const utc = date::now();
	const local = match (date::in(date::LOCAL, utc)) {
    case let d: date::date => yield d;
    case chrono::tscmismatch => yield utc;
	};

	const s = match (date::asformat("%a %e %b %H:%M:%S %Z %Y", &local)) {
    case let f: str => yield f;
    case nomem => fmt::fatal("date: out of memory");
	};
	defer free(s);
	fmt::println(s)!;
};
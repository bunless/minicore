use os;
use src::dispatcher;
use src::applets::base32;
use src::applets::base64;
use src::applets::cat;
use src::applets::cp;
use src::applets::date;
use src::applets::untrue;
use src::applets::less;
use src::applets::mv;
use src::applets::rm;
use src::applets::rmdir;
use src::applets::sha1sum;
use src::applets::sort;
use src::applets::unlink;
use src::applets::wc;
use src::applets::whoami;
use src::applets::yes;

export fn main() void = {
	const applets: []dispatcher::entry = [
		dispatcher::entry {
			name = "base32",
			run = &base32::run,
		},
		dispatcher::entry {
			name = "base64",
			run = &base64::run,
		},
		dispatcher::entry {
			name = "cat",
			run = &cat::run,
		},
		dispatcher::entry {
			name = "cp",
			run = &cp::run,
		},
		dispatcher::entry {
			name = "date",
			run = &date::run,
		},
		dispatcher::entry {
			name = "false",
			run = &untrue::run,
		},
		dispatcher::entry {
			name = "less",
			run = &less::run,
		},
		dispatcher::entry {
			name = "mv",
			run = &mv::run,
		},
		dispatcher::entry {
			name = "rm",
			run = &rm::run,
		},
		dispatcher::entry {
			name = "rmdir",
			run = &rmdir::run,
		},
		dispatcher::entry {
			name = "sha1sum",
			run = &sha1sum::run,
		},
		dispatcher::entry {
			name = "sort",
			run = &sort::run,
		},
		dispatcher::entry {
			name = "unlink",
			run = &unlink::run,
		},
		dispatcher::entry {
			name = "wc",
			run = &wc::run,
		},
		dispatcher::entry {
			name = "whoami",
			run = &whoami::run,
		},
		dispatcher::entry {
			name = "yes",
			run = &yes::run,
		},
	];

	os::exit(dispatcher::dispatch(applets, os::args[1..]));
};

use os;
use src::dispatcher;
use src::applets::base64;
use src::applets::cat;
use src::applets::cp;
use src::applets::date;
use src::applets::less;
use src::applets::mv;
use src::applets::rm;
use src::applets::rmdir;
use src::applets::sort;

export fn main() void = {
  const applets: []dispatcher::entry = [
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
      name = "sort",
      run = &sort::run,
    },
  ];

  dispatcher::dispatch(applets, os::args[1..]);
};

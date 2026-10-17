use fmt::*;
use os;

export fn run(args: []str) int = {
  printf("{}", os::getcwd())!;
  return 0;
};
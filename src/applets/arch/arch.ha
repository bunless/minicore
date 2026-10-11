use fmt::*;
use os;

export fn run(args: []str) int = {
    printf("{}", os::machine())!;
    return 0;
};
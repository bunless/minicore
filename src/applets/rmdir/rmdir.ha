use fmt;
use fs;
use os;

export fn run(dirs: []str) void = {
  for (let dir .. dirs) {
    match (os::stat(dir)) {
      case let st: fs::filestat =>
        if (fs::isfile(st.mode)) {
        fmt::errorfln("rmdir: {}: is a file, use rm", dir)!;
      } else {
        match (os::rmdir(dir)) {
          case void => yield;
          case let e: fs::error => fmt::errorfln("rmdir: {}: {}", dir, fs::strerror(e))!;
        };
      };
      case let e: fs::error => fmt::errorfln("rmdir: {}: {}", dir, fs::strerror(e))!;
    };
  };
};

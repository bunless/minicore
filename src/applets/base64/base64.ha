use fmt;
use os;
use fs;
use io;
use encoding::base64;

def BUFSZ = 57 * 1024z;
def LINESZ = 76z;

export fn run(args: []str) void = {
  if (len(args) == 0) {
    fmt::println("usage: minicore base64 <file>")!;
    return;
  };

  if (len(args) > 1) {
    fmt::errorfln("base64: extra operand '{}'", args[1])!;
    return;
  };  

  let buf: *[BUFSZ]u8 = alloc([0...])!;
  defer free(buf);
  let line: *[LINESZ + 1]u8 = alloc([0...])!;
  defer free(line);
  let col: size = 0;

  for (let a .. args) {
    const f = match (os::open(a)) {
    case let f: io::file =>
      yield f;
    case let e: fs::error =>
      fmt::printfln("base64: {}: {}", a, fs::strerror(e))!;
      continue;
    case nomem =>
      fmt::printfln("base64: {}: out of memory", a)!;
      continue;
    };

    for (true) {
      let n = match (io::read(f, buf)) {
      case let n: size =>
        yield n;
      case io::EOF =>
        break;
      case let e: io::error =>
        fmt::printfln("base64: {}: {}", a, io::strerror(e))!;
        break;
      };

      let out: []u8 = match (base64::encodeslice(&base64::std_encoding, buf[..n])) {
      case let out: []u8 =>
        yield out;
      case nomem =>
        fmt::printfln("base64: {}: out of memory", a)!;
        break;
      };

      for (let i = 0z; i < len(out); i += 1) {
        line[col] = out[i];
        col += 1;
        if (col == LINESZ) {
          io::writeall(os::stdout, line[..LINESZ])!;
          fmt::println("")!;
          col = 0;
        };
      };

      free(out);
    };

    io::close(f)!;
  };

  if (col > 0) {
    io::writeall(os::stdout, line[..col])!;
    fmt::println("")!;
  };
};
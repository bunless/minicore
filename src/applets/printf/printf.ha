
use fmt::*;
use strings;

fn write(s: str) void = {
  print(s)!;
};

fn digit(c: u8) u32 = {
  if (c >= '0' && c <= '9') return (c - '0': u32);
  if (c >= 'a' && c <= 'f') return (c - 'a' + 10: u32);
  if (c >= 'A' && c <= 'F') return (c - 'A' + 10: u32);
  return 255;
};

fn number(s: str, base: u32) (u64 | void) = {
  let bytes = strings::toutf8(s);
  if (len(bytes) == 0 || base < 2 || base > 16) return;

  let n: u64 = 0;
  for (let i = 0z; i < len(bytes); i += 1) {
    let d = digit(bytes[i]);
    if (d >= base) return;
    n = n * (base: u64) + (d: u64);
  };
  return n;
};

fn write_number(n: u64, base: u32, upper: bool) void = {
  let digits: [64]u8 = [0...];
  let count = 0z;
  let v = n;

  if (v == 0) {
    write("0");
    return;
  };

  for (v > 0) {
    let d = (v % base): u8;
    digits[count] = if (d < 10) '0' + d else if (upper) 'A' + d - 10 else 'a' + d - 10;
    count += 1;
    v /= base;
  };

  for (count > 0) {
    count -= 1;
    write(strings::fromutf8([digits[count]])!);
  };
};

export fn run(args: []str) int = {
  if (len(args) == 0) {
    errorln("printf: missing format string")!;
    return 1;
  };

  let format = strings::toutf8(args[0]);
  let arg = 1z;
  let i = 0z;

  for (i < len(format); i += 1) {
    if (format[i] == '\\' && i + 1 < len(format)) {
      i += 1;
      if (format[i] == 'n') write("\n")
      else if (format[i] == 't') write("\t")
      else if (format[i] == 'r') write("\r")
      else if (format[i] == '\\') write("\\")
      else if (format[i] == 'a') write("\x07")
      else if (format[i] == 'b') write("\x08")
      else if (format[i] == 'f') write("\x0c")
      else if (format[i] == 'v') write("\x0b")
      else if (format[i] == 'c') return 0
      else {
        write("\\");
        write(strings::fromutf8([format[i]])!);
      };
      continue;
    };

    if (format[i] != '%') {
      write(strings::fromutf8([format[i]])!);
      continue;
    };

    i += 1;
    if (i >= len(format)) {
      write("%");
      break;
    };

    if (format[i] == '%') {
      write("%");
      continue;
    };

    let left = false;
    let zero = false;

    for (i < len(format)) {
      if (format[i] == '-') left = true
      else if (format[i] == '0') zero = true
      else break;
      i += 1;
    };

    let start = i;
    for (i < len(format) && format[i] >= '0' && format[i] <= '9'; i += 1) continue;

    let width = 0z;
    if (i > start) {
      match (number(strings::fromutf8(format[start..i])!, 10)) {
        case let n: u64 => width = (n: size);
        case void => width = 0z;
      };
    };

    if (i >= len(format)) {
      write("%");
      break;
    };

    let spec = format[i];
    if (arg >= len(args)) {
      errorln("printf: missing argument")!;
      return 1;
    };

    let value = args[arg];
    let bytes = strings::toutf8(value);

    if (spec == 's') {
      if (!left) for (let p = len(value); p < width; p += 1) write(" ");
      write(value);
      if (left) for (let p = len(value); p < width; p += 1) write(" ");
      continue;
    };

    if (spec == 'c') {
      if (len(bytes) > 0) write(strings::fromutf8(bytes[..1])!);
      continue;
    };

    if (spec == 'd' || spec == 'i' || spec == 'u') {
      let negative = spec != 'u' && len(bytes) > 0 && bytes[0] == '-';
      let digits = if (negative) strings::fromutf8(bytes[1..])! else value;
      match (number(digits, 10)) {
        case let n: u64 => {
          if (negative) write("-");
          write_number(n, 10, false);
        };
        case void => {
          errorln("printf: invalid integer")!;
          return 1;
        };
      };
      continue;
    };

    if (spec == 'x' || spec == 'X' || spec == 'o') {
      let base: u32 = if (spec == 'o') 8 else 16;
      match (number(value, 10)) {
        case let n: u64 => write_number(n, base, spec == 'X');
        case void => {
          errorln("printf: invalid integer")!;
          return 1;
        };
      };
      continue;
    };

    write("%");
    write(strings::fromutf8([spec])!);
  };
  return 0;
};

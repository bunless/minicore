use fmt;

export type entry = struct {
  name: str,
  run: *applet,
};
export type applet = fn(args: []str) void;


export fn dispatch(applets: []entry, args: []str) void = {
  if (len(args) == 0) {
    fmt::printfln("Usage: minicore <applet> [args...]",)!;
    fmt::printfln("Available applets:",)!;
    for (let i: size = 0; i < len(applets); i += 1) {
      fmt::printfln("  {}", applets[i].name)!;
    };
    return;
  };

  // fmt::printfln("applets: {}, first arg: '{}'", len(applets), args[0])!;

  for (let i: size = 0; i < len(applets); i += 1) {
    if (applets[i].name == args[0]) {
      applets[i].run(args[1..]);
      return;
    };
  };

  fmt::printfln("minicore: {}: applet not found", args[0])!;
};

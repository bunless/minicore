use fmt::*;

export type entry = struct {
	name: str,
	run: *applet,
};

export type applet = fn(args: []str) int;

export fn dispatch(applets: []entry, args: []str) int = {
	if (len(args) == 0) {
		printfln("Usage: minicore <applet> [args...]")!;
		printfln("Available applets:")!;
		for (let i: size = 0; i < len(applets); i += 1) {
			printfln("  {}", applets[i].name)!;
		};
		return 0;
	};

	// printfln("applets: {}, first arg: '{}'", len(applets), args[0])!;
	for (let i: size = 0; i < len(applets); i += 1) {
		if (applets[i].name == args[0]) {
			return applets[i].run(args[1..]);
		};
	};

	printfln("minicore: {}: applet not found", args[0])!;
	return 1;
};

use fmt;
use os;
use fs;
use io;
use strings;
use unix::tty;
use errors;
use encoding::utf8;

def BUFSZ = 32768z;

fn read_key(fd: io::file) u8 = {
	let key: [1]u8 = [0...];
	const n = io::read(fd, key[..])!;

	if (n == 0) {
		return 0;
	};

	return key[0];
};

fn terminal_size(fd: io::file) tty::ttysize = {
	match (tty::winsize(fd)) {
	case let ws: tty::ttysize =>
		return ws;

	case let e: tty::error =>
		fmt::printfln("less: {}", tty::strerror(e))!;
		return tty::ttysize {
			rows = 24,
			columns = 80,
		};
	};
};

fn draw(
	lines: []str,
	top: size,
	height: size,
	file: str,
	fd: io::file,
) void = {
	const ws = terminal_size(fd);

	let page_height = height;

	if (page_height < 1) {
		page_height = 1;
	};

	// Clear screen and move cursor to the top-left.
	fmt::print("\x1b[2J\x1b[H")!;

	for (let i = 0z; i < page_height; i += 1) {
		const line = top + i;

		if (line < len(lines)) {
			fmt::printfln("{}", lines[line])!;
		} else {
			fmt::println("~")!;
		};
	};

	// Status bar.
	fmt::print("\x1b[7m")!;

	if (len(lines) == 0) {
		fmt::printf(" less - {} | empty ", file)!;
	} else {
		let percent = 100z;

		if (len(lines) > page_height) {
			const max_top = len(lines) - page_height;

			if (max_top > 0) {
				percent = (top * 100z) / max_top;
			};

			if (percent > 100) {
				percent = 100;
			};
		};

		let last = top + page_height;

		if (last > len(lines)) {
			last = len(lines);
		};

		fmt::printf(
			" less - {} | {}% | {}-{} of {} ",
			file,
			percent,
			top + 1,
			last,
			len(lines),
		)!;
	};

	fmt::print("\x1b[0m")!;

	// Move cursor to the bottom row.
	fmt::printf("\x1b[{};1H", ws.rows)!;
};

fn page(lines: []str, file: str, fd: io::file) void = {
	let top = 0z;

	for (true) {
		const ws = terminal_size(fd);

		let height = ws.rows: size;

		if (height < 2) {
			height = 2;
		};

		// Reserve one terminal row for the status bar.
		height -= 1;

		draw(lines, top, height, file, fd);

		const key = read_key(fd);

		switch (key) {
		case 'q', 'Q' =>
			return;

		// One line down.
		case 'j' =>
			if (top + 1 < len(lines)) {
				top += 1;
			};

		// One line up.
		case 'k' =>
			if (top > 0) {
				top -= 1;
			};

		// Half page down.
		case 'd' =>
			let amount = height / 2;

			if (amount < 1) {
				amount = 1;
			};

			if (top + amount < len(lines)) {
				top += amount;
			};

		// Half page up.
		case 'u' =>
			let amount = height / 2;

			if (top > amount) {
				top -= amount;
			} else {
				top = 0;
			};

		// Full page down.
		case ' ', 'f' =>
			if (len(lines) > height) {
				if (top + height < len(lines) - height) {
					top += height;
				} else {
					top = len(lines) - height;
				};
			};

		// Full page up.
		case 'b' =>
			if (top > height) {
				top -= height;
			} else {
				top = 0;
			};

		// Beginning of file.
		case 'g' =>
			top = 0;

		// End of file.
		case 'G' =>
			if (len(lines) > height) {
				top = len(lines) - height;
			};

		// Escape sequence, primarily arrow keys.
		case '\x1b' =>
			const a = read_key(fd);

			if (a == '[') {
				const arrow = read_key(fd);

				switch (arrow) {
				// Up.
				case 'A' =>
					if (top > 0) {
						top -= 1;
					};

				// Down.
				case 'B' =>
					if (top + 1 < len(lines)) {
						top += 1;
					};

				// Left.
				case 'D' =>
					void;

				// Right.
				case 'C' =>
					void;

				case =>
					void;
				};
			};

		// Ctrl-D: half page down.
		case '\x04' =>
			let amount = height / 2;

			if (amount < 1) {
				amount = 1;
			};

			if (top + amount < len(lines)) {
				top += amount;
			};

		// Ctrl-U: half page up.
		case '\x15' =>
			let amount = height / 2;

			if (top > amount) {
				top -= amount;
			} else {
				top = 0;
			};

		// Ctrl-F: full page down.
		case '\x06' =>
			if (len(lines) > height) {
				if (top + height < len(lines) - height) {
					top += height;
				} else {
					top = len(lines) - height;
				};
			};

		// Ctrl-B: full page up.
		case '\x02' =>
			if (top > height) {
				top -= height;
			} else {
				top = 0;
			};

		// Ctrl-A: beginning.
		case '\x01' =>
			top = 0;

		// Ctrl-E: end.
		case '\x05' =>
			if (len(lines) > height) {
				top = len(lines) - height;
			};

		case =>
			void;
		};
	};
};

export fn run(files: []str) void = {
	let buf: *[BUFSZ]u8 = alloc([0...])!;
	defer free(buf);

	const ttyfd = match (tty::open()) {
	case let f: io::file =>
		yield f;

	case let e: tty::error =>
		fmt::printfln(
			"less: cannot open terminal: {}",
			tty::strerror(e),
		)!;
		return;
	};

	defer io::close(ttyfd)!;

	if (!tty::isatty(ttyfd)) {
		fmt::println("less: terminal is not available")!;
		return;
	};

	const settings = match (tty::termios_query(ttyfd)) {
	case let settings: tty::termios =>
		yield settings;

	case let e: errors::error =>
		fmt::printfln(
			"less: {}",
			errors::strerror(e),
		)!;
		return;
	};

	match (tty::noncanonical(&settings)) {
	case void =>
		void;

	case let e: errors::error =>
		fmt::printfln(
			"less: {}",
			errors::strerror(e),
		)!;
		return;
	};

	match (tty::noecho(&settings)) {
	case void =>
		void;

	case let e: errors::error =>
		fmt::printfln(
			"less: {}",
			errors::strerror(e),
		)!;
		return;
	};

	match (tty::termios_set(&settings)) {
	case void =>
		void;

	case let e: errors::error =>
		fmt::printfln(
			"less: {}",
			errors::strerror(e),
		)!;
		return;
	};

	defer tty::termios_restore(&settings);

	// Enter alternate screen.
	fmt::print("\x1b[?1049h")!;
	defer fmt::print("\x1b[?1049l")!;

	// Hide cursor.
	fmt::print("\x1b[?25l")!;
	defer fmt::print("\x1b[?25h")!;

	for (let file .. files) {
		const f = match (os::open(file)) {
		case let f: io::file =>
			yield f;

		case let e: fs::error =>
			fmt::printfln(
				"less: {}: {}",
				file,
				fs::strerror(e),
			)!;
			continue;

		case nomem =>
			fmt::printfln(
				"less: {}: out of memory",
				file,
			)!;
			continue;
		};

		const raw: []u8 = io::drain(f)!;

		const text_result = strings::fromutf8(raw);

		match (text_result) {
		case let text: str =>
			const lines: []str = strings::split(text, "\n")!;

			let n = len(lines);

			// Drop the final empty line caused by a trailing newline.
			if (n > 0 && len(lines[n - 1]) == 0) {
				n -= 1;
			};

			const visible = lines[..n];

			for (let i = 0z; i < n; i += 1) {
				visible[i] = strings::ltrim(visible[i]);
			};

			page(visible, file, ttyfd);

		case let e: utf8::invalid =>
			fmt::printfln(
				"less: {}: binary data is not UTF-8",
				file,
			)!;
		};

		io::close(f)!;
	};
};
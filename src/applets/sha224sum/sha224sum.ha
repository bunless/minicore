use encoding::hex;
use fmt::*;
use fs;
use io;
use os;

const ktab: [64]u32 = [
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

fn rotr(x: u32, n: u32) u32 = (x >> n) | (x << (32 - n));

fn block(h: *[8]u32, p: []u8) void = {
	let w: [64]u32 = [0...];
	for (let i = 0z; i < 16; i += 1) {
		w[i] = ((p[i * 4]: u32) << 24) | ((p[i * 4 + 1]: u32) << 16)
			| ((p[i * 4 + 2]: u32) << 8) | (p[i * 4 + 3]: u32);
	};
	for (let i = 16z; i < 64; i += 1) {
		const s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
		const s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
		w[i] = w[i - 16] + s0 + w[i - 7] + s1;
	};

	let a = h[0], b = h[1], c = h[2], d = h[3];
	let e = h[4], f = h[5], g = h[6], hh = h[7];
	for (let i = 0z; i < 64; i += 1) {
		const big1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
		const ch = (e & f) ^ (~e & g);
		const t1 = hh + big1 + ch + ktab[i] + w[i];
		const big0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
		const maj = (a & b) ^ (a & c) ^ (b & c);
		const t2 = big0 + maj;
		hh = g; g = f; f = e; e = d + t1;
		d = c; c = b; b = a; a = t1 + t2;
	};
	h[0] += a; h[1] += b; h[2] += c; h[3] += d;
	h[4] += e; h[5] += f; h[6] += g; h[7] += hh;
};

export fn run(files: []str) int = {
	let buf: [65536]u8 = [0...];
	let blk: [64]u8 = [0...];
	let digest: [28]u8 = [0...]; // SHA-224 is the first 28 bytes
	let status = 0;

	// no arguments means read stdin once, treated as "-"
	const inputs = if (len(files) == 0) 1z else len(files);

	for (let i = 0z; i < inputs; i += 1) {
		const name = if (len(files) == 0) "-" else files[i];

		let f: io::handle = os::stdin;
		if (name != "-") {
			f = match (os::open(name)) {
			case let opened: io::file => yield opened;
			case let e: fs::error =>
				errorfln("sha224sum: {}: {}", name, fs::strerror(e))!;
				status = 1;
				continue;
			};
		};

		let h: [8]u32 = [
			0xc1059ed8, 0x367cd507, 0x3070dd17, 0xf70e5939,
			0xffc00b31, 0x68581511, 0x64f98fa7, 0xbefa4fa4,
		];
		let fill = 0z, total = 0u64;
		let failed = false;

		for (true) {
			const n = match (io::read(f, buf[..])) {
			case let n: size => yield n;
			case io::EOF => break;
			case let e: io::error =>
				errorfln("sha224sum: {}: {}", name, io::strerror(e))!;
				status = 1;
				failed = true;
				break;
			};

			total += n: u64;
			for (let b .. buf[..n]) {
				blk[fill] = b;
				fill += 1;
				if (fill == 64) {
					block(&h, blk[..]);
					fill = 0;
				};
			};
		};

		if (name != "-") io::close(f)!; // never close stdin
		if (failed) continue;

		blk[fill] = 0x80;
		fill += 1;
		if (fill > 56) {
			for (fill < 64) {
				blk[fill] = 0;
				fill += 1;
			};
			block(&h, blk[..]);
			fill = 0;
		};
		for (fill < 56) {
			blk[fill] = 0;
			fill += 1;
		};
		const bits = total * 8;
		for (let j = 0z; j < 8; j += 1) {
			blk[56 + j] = (bits >> (((7 - j) * 8): u64)): u8;
		};
		block(&h, blk[..]);

		for (let j = 0z; j < 7; j += 1) {
			for (let m = 0z; m < 4; m += 1) {
				digest[j * 4 + m] = (h[j] >> ((3 - m) * 8)): u8;
			};
		};

		const hexstr = hex::encodestr(digest[..])!;
		defer free(hexstr);
		printfln("{}  {}", hexstr, name)!;
	};
	return status;
};
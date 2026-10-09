bin := "result/minicore"
srcdir := "src"
upx := "result/minicore.upx"

default: build

build:
	mkdir -p result
	hare build -R -o {{bin}} {{srcdir}}

build-o1:
	mkdir -p result
	hare build -R -o {{bin}} {{srcdir}}
	strip {{bin}} 2>/dev/null || true

build-o2:
	mkdir -p result
	hare build -R -o {{bin}} {{srcdir}}
	strip --strip-unneeded --remove-section=.comment --remove-section=.note --remove-section=.gnu.version {{bin}} 2>/dev/null || true

build-o3:
	mkdir -p result
	hare build -R -o {{bin}} {{srcdir}}
	strip --strip-unneeded --remove-section=.comment --remove-section=.note --remove-section=.gnu.version {{bin}} 2>/dev/null || true
	upx --best --lzma -o {{bin}}.upx {{bin}} 2>/dev/null || true
	rm -rf {{bin}} && mv {{upx}} {{bin}} 

build-o4:
	mkdir -p result
	hare build -R -o {{bin}} {{srcdir}}
	strip --strip-unneeded --remove-section=.comment --remove-section=.note --remove-section=.gnu.version {{bin}} 2>/dev/null || true
	upx --best --lzma -o {{bin}}.upx {{bin}} 2>/dev/null || true
	rm -rf {{bin}} && mv {{upx}} {{bin}} 
	strip --strip-unneeded --remove-section=.comment --remove-section=.note --remove-section=.gnu.version {{bin}} 2>/dev/null || true

run *args: build
	./{{bin}} {{args}}

clean:
	rm -rf result
	

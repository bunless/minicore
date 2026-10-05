bin := "result/minicore"
srcdir := "src"

default: build

build:
	mkdir -p result
	hare build -R -o {{bin}} {{srcdir}}
	strip {{bin}}

run *args: build
	./{{bin}} {{args}}

clean:
	rm -rf result
	

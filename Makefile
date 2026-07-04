.PHONY: all
all: monitor.com montest.com test.woz

monitor.com: monitor.hex
	zxcpm load monitor

montest.com: montest.hex
	zxcpm load montest

montest.hex: monitor.hex test.hex
	./hexcat $^ > $@

monitor.hex: monitor.z80
	zx80asm monitor/hfs

test.hex: test.z80
	zx80asm test/hfs

test.woz: test.hex
	iload -w -s $< > $@

.PHONY: clean
clean:
	rm -f monitor.com montest.com test.woz *.hex *.lst *~

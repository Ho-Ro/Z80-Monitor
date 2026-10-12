.PHONY: all
all: monitor.com montest.com test.woz monmbc2.hex

monitor.com: monitor.hex
	zxcpm load monitor

monmbc2.hex: monmbc2.z80 monitor.z80
	zx80asm monmbc2/hfs

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

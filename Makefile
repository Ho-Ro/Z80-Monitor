.PHONY: all
all: monitor.com montest.woz

monitor.com: monitor.z80
	zx80asm monitor/afs

montest.hex: montest.z80
	zx80asm montest/hfs

montest.woz: montest.hex
	iload -w -s montest.hex > montest.woz

.PHONY: clean
clean:
	rm -f monitor.lst monitor.com montest.lst montest.hex montest.woz *~

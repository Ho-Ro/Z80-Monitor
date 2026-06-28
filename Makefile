.PHONY: all
all: monitor.com

monitor.com: monitor.z80
	zx80asm monitor/afs

.PHONY: clean
clean:
	rm -f monitor.lst monitor.com *~

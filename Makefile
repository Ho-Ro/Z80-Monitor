PRJ1 = monitor
PRJ2 = mbc2mon

SRC1 = $(PRJ1).z80
HEX1 = $(PRJ1).hex
COM1 = $(PRJ1).com

SRC2 = $(PRJ2).z80
HEX2 = $(PRJ2).hex


.PHONY: all
all: $(COM1) $(HEX1) $(HEX2) montest.com test.woz

$(COM1): $(SRC1)
	zx80asm $(PRJ1)/afs

$(HEX1): $(SRC1)
	zx80asm $(PRJ1)/hfs


$(HEX2): $(SRC2)
	zx80asm $(PRJ2)/hfs

montest.hex: monitor.hex test.hex
	./hexcat $^ > $@

montest.com: montest.hex
	zxcpm load montest

$(SRC2): $(SRC1)
	sed -e 's/^\([[:space:]]*MBC2[[:space:]]\+equ[[:space:]]\+\)FALSE\>/\1TRUE/' $< > $@


test.hex: test.z80
	zx80asm test/hfs

test.woz: test.hex
	iload -w -s $< > $@

.PHONY: clean
clean:
	rm -f $(COM1) montest.com test.woz *.hex *.lst *~

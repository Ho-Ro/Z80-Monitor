# Z80 Monitor From Scratch
This repo documents the evolution of a simple Z80 monitor for single board computer
like [Z80-MBC2](https://github.com/Ho-Ro/Z80-MBC2).

## Z80-MBC2
This little computer already uses the Z80 version of
[WozMon](https://github.com/Ho-Ro/Z80-MBC2/blob/main/WozMon),
the tiny Apple ][ ROM monitor. Due to the reduced commands I decided to start a new
monitor with extended command set.

## The Monitor

### Setup
80s-like this monitor is written in assembler with the SLR `z80asm.com` format. Development
happens on my Linux machine using [zxcc](https://github.com/Ho-Ro/ZXCC) or alternatively
[tnylpo](https://github.com/Ho-Ro/tnylpo) as CP/M emulator. During development the monitor
is an CP/M program to simplify the testing - it can easily switched to a standalone program
in ROM. The only two HW-related functions are conin (wait for char and return it in register A)
and conout (output char in register A). 
The typical use case for Z80 SBCs is the combination with a terminal program running on the PC
that connects to the serial port of the SBC. So the simplest way of program storage is to copy
it from or to the terminal screen and store it on the PC. Therefore I decided to support the
[WozMon format](https://github.com/Ho-Ro/Z80-MBC2/blob/main/WozMon/README.md) for simple data storage.

### Commands
I started with the command line parser and some standard functions, with this syntax:

    <CMD><ADDRESS>[ <ARG> <ARG> ...]<RETURN>

- **SHOW** memory content
  - `SAAAA` - show 16 bytes at `AAAA` as hex and ASCII (`AAAA  DD DD ...  CC ..`).
  - `S` - (or CR alone) show the next 16 bytes after previous dump.
  - `WAAAA` - dump 16 bytes at `AAAA` in WozMon fmt (`AAAA: DD DD ...`).
  - `W` - (or CR alone) dump the next 16 bytes after previous dump in WozMon fmt.

- **MODIFY** memory content

  - `MAAAA DD DD ...` - modify mem at `AAAA`, **no space between `'M'` and the address!**.
  - `M DD DD ...` - modify next mem bytes.
  - `AAAA: DD DD ...` - modify mem at `AAAA` using WozMon fmt (see SHOW).

- **GOTO** program location

  - `GAAAA` - goto program at `AAAA`.
  - `GAAAA BBBB` - goto program at `AAAA` and set a breakpoint at `BBBB`.
  - `G` - resume execution from last breakpoint.

- **REGISTER** display

  - `R` - show the user register including the 2nd register set `AF'`, `BC'`, `DE'`, `HL'`

- **SET REGISTER** for following `G` command

  - `A dd` - set register `A`
  - `F dd` - set register `F`
  - `B dd` - set register `B`
  - `C dd` - set register `C`
  - `D dd` - set register `D`
  - `E dd` - set register `E`
  - `H dd` - set register `H`
  - `L dd` - set register `L`
  - `X dddd` - set register `IX`
  - `Y dddd` - set register `IY`


The command line input uses `BS` or `RUB` to delete to the left. `^C` returns to CP/M.

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
in ROM. The only two HW-related functions are

- **conin** (wait for char and return it in register A)
- **conout** (output char in register A)

The typical use case for Z80 SBCs is the combination with a terminal program running on the PC
that connects to the serial port of the SBC. So the simplest way of program storage is to copy
it from or to the terminal screen and store it on the PC. Therefore I decided to support the
[WozMon format](https://github.com/Ho-Ro/Z80-MBC2/blob/main/WozMon/README.md) for simple data storage.

### Commands
The monitor program offers these functions with the following syntax:

    <CMD><ADDRESS>[ <ARG> <ARG> ...]<RETURN>

- **VIEW** memory content
  - `VAAAA` - View 16 bytes at `AAAA` as hex and ASCII (`AAAA  DD DD ...  CC ..`).
  - `V` (or CR alone) - View the next 16 bytes after previous dump.
  - `WAAAA` - Dump 16 bytes at `AAAA` in WozMon fmt (`AAAA: DD DD ...`).
  - `W` (or CR alone) - Dump the next 16 bytes after previous dump in WozMon fmt.

- **MODIFY** memory content
  - `MAAAA DD DD ...` - Modify mem at `AAAA`, **no space between `'M'` and the address!**.
  - `M DD DD ...` - Modify next mem bytes.
  - `AAAA: DD DD ...` - Modify mem at `AAAA` using WozMon fmt (see SHOW).

- **GOTO** program location
  - `GAAAA` - Goto program at `AAAA`.
  - `G` - Goto program counter of user context, e.g. resume from last breakpoint.
  - `G0` - Exit to CP/M or restart the Z80-MBC2 monitor.

- **BREAKPOINT** set or clear
  - `K` - clear breaKpoint.
  - `K0` - clear breaKpoint.
  - `KAAAA` - set breaKpoint at `AAAA`.
  - `KAAAA BBBB` - set breaKpoint at `AAAA` and reactivate it at `BBBB`.
    Breakpoints and reactivation points are implemented by replacing the opcode at `AAAA` and `BBBB` with `RST` instructions.  
    This only works if the addresses `AAAA` and `BBBB` point to the first byte of the opcode (M1).

- **REGISTER** display
  - `R` - show the user register including the 2nd register set `AF'`, `BC'`, `DE'`, `HL'` and, if applicable, the address of the breakpoint and its recovery.

```
           A  F  BC   DE   HL  A' F'  BC'  DE'  HL'  IX   IY   I  R  PC   SP
          DE 8B 0600 0003 C504 55 00 0000 0000 0000 0000 0000 00 1B 100C 0740
          Sz...p.C             sz...p.c                      BrkPt: 100C/100D
```

- **SET REGISTER** prepare user context for the following `G` command
  - `A dd` - set register `A`
  - `B dd` - set register `B`
  - `C dd` - set register `C`
  - `D dd` - set register `D`
  - `E dd` - set register `E`
  - `H dd` - set register `H`
  - `L dd` - set register `L`
  - `F dd` - set flags
  - `I dd` - set interrupt vector register
  - `P dddd` - set program counter
  - `S dddd` - set stack pointer
  - `X dddd` - set register `IX`
  - `Y dddd` - set register `IY`


The command line input uses `BS` or `RUB` to delete to the left. `^C` returns to CP/M.

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
  - `M DD DD ...` - Modify next mem bytes, continuing from the address of a
    previous `MAAAA ...` or `AAAA: ...` line. `?` if no address has been entered yet.
  - `AAAA: DD DD ...` - Modify mem at `AAAA` using WozMon fmt (as shown by `WAAAA`).
    The address may be any 1-4 hex digits (`A:`, `12:`, `123:`, `1234:`); it also
    sets the address for a following `M DD DD ...` line.

- **GOTO** program location
  - `GAAAA` - Goto program at `AAAA`.
  - `GAAAA BBBB` - Goto program at `AAAA` and set a breakpoint at `BBBB`.
  - `G` - Goto program counter of user context, e.g. resume from last breakpoint.
  - `G0` - Exit to CP/M or restart the Z80-MBC2 monitor.

- **BREAKPOINT** set or clear
  - `K` - clear breaKpoint.
  - `K0` - clear breaKpoint.
  - `KAAAA` - set breaKpoint at `AAAA`.
  - `KAAAA BBBB` - set breaKpoint at `AAAA` and reactivate it at `BBBB`.
    Breakpoints and reactivation points are implemented by replacing the opcode at `AAAA` and `BBBB` with `RST` instructions.  
    This only works if the addresses `AAAA` and `BBBB` point to the first byte of the opcode (M1).

- **IOS** I/O commands (Z80-MBC2 build only)
  - `O CMD DD` - store IOS output opcode `CMD` and write a data byte `DD` to it.
    Examples: `O 00 01` (USER LED on), `O 00 00` (USER LED off), `O 03 FF` (GPIOA all high).  
    Same port sequence as `CONOUT` (`STO_OPC` store, `EX_OPC` execute write).
  - `Q CMD [NN]` - store IOS input opcode `CMD` and read `NN` bytes (default 1);
    multi-byte reads (e.g. `Q 84 7` DATETIME) are read sequentially without re-store.
  - The commands are only compiled in the `MBC2` build; in the `CP/M` (`zxcc`)
    build they report `?`. `CMD`, `DD` and `NN` are 1-2 hex digits.
  - Useful opcodes (see `IOS-Z80-MBC2-NG`):

    | `CMD` | Dir | Function |
    |---|---|---|
    | `00` | W | USER LED (bit 0: 0 = off, 1 = on) |
    | `01` | W | Serial TX |
    | `03`/`04` | W | GPIOA / GPIOB |
    | `05`/`06` | W | IODIRA / IODIRB (direction) |
    | `07`/`08` | W | GPPUA / GPPUB (pull-ups) |
    | `80` | R | USER KEY |
    | `81`/`82` | R | GPIOA / GPIOB |
    | `83` | R | SYSFLAGS |
    | `84` | R | DATETIME (7 bytes: s min h d mon y temp) |
    | `85` | R | ERRDISK |
    | `89` | R | SYSIRQ |

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

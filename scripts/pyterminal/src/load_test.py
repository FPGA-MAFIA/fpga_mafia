#!/usr/bin/env python
"""Bulk-load a test image over the UART debug port.

The LOTR / big_core debug UART exposes WB (burst write) transactions that copy
a ``*.sv`` memory-initialization file into I-MEM / D-MEM. This wrapper does the
full sequence in one shot:

1. Freeze the target core(s).
2. Burst-write ``inst_mem.sv`` to the I-MEM base address.
3. Burst-write ``data_mem.sv`` to the D-MEM base address (if present).
4. Release the core(s) so they start executing.

Usage (typical):

    # Compile the SW once per build.py run (produces gcc_files/*.sv)
    python ../../build.py -dut lotr -tests alive -app

    # Load it onto the board via the UART debug port
    python load_test.py -dut lotr -test alive -com COM3

Add ``--dry-run`` to print the transactions without touching the port.
"""

from __future__ import annotations

import argparse
import os
import sys
import time

import uart_term  # reuses open_serial_port / config_serial_port / burst helpers
import file_parser


# Freeze/release register addresses per DUT (matches existing sequence_abd/*.txt).
# LOTR has 4 cores; writing 1 freezes that core, 0 releases it.
FREEZE_ADDRS = {
    "lotr":     ["01C00150", "01C00154", "01C00158", "01C0015C"],
    # big_core uses a single 0xFFFFFFFF freeze-all alias (see load_draw_tree.txt).
    "big_core": ["FFFFFFFF"],
}

DEFAULT_IMEM_BASE = "00000000"
DEFAULT_DMEM_BASE = "00000000"  # LOTR d_mem shares I-MEM base; for big_core use 0x00010000


def _pad8(hex_str: str) -> str:
    """Normalize a user-supplied hex string into a zero-padded 8-digit lowercase form."""
    s = hex_str.strip().lower()
    if s.startswith("0x"):
        s = s[2:]
    if len(s) > 8 or any(c not in "0123456789abcdef" for c in s):
        raise ValueError("Invalid 32-bit hex value: {}".format(hex_str))
    return s.rjust(8, "0")


def _repo_root():
    here = os.path.abspath(os.path.dirname(__file__))
    return os.path.abspath(os.path.join(here, "..", "..", ".."))


def _resolve_mem_files(dut: str, test: str):
    root = _repo_root()
    gcc_dir = os.path.join(root, "target", dut, "tests", test, "gcc_files")
    inst_mem = os.path.join(gcc_dir, "inst_mem.sv")
    data_mem = os.path.join(gcc_dir, "data_mem.sv")
    if not os.path.isfile(inst_mem):
        raise FileNotFoundError(
            "inst_mem.sv not found at {} — run: python build.py -dut {} -tests {} -app".format(
                inst_mem, dut, test
            )
        )
    return inst_mem, (data_mem if os.path.isfile(data_mem) else None)


def _section_starting_addr(base_hex8: str, section_offset_hex: str) -> str:
    """Add base + section's @address prefix and return 8-digit hex."""
    combined = int(base_hex8, 16) + int(section_offset_hex, 16)
    return "{:08x}".format(combined)


# ----------------------------------------------------------------------
# Dry-run helpers (print what *would* happen) -- avoid shadowing uart_term.
# ----------------------------------------------------------------------

class _DryPort:
    """Fake serial port that records transactions instead of sending them."""

    def __init__(self, log):
        self._log = log

    def write(self, data):
        self._log.append(bytes(data))

    def read(self, n):
        # Pretend every ack / data read succeeded with a fixed byte.
        return b"A" * n

    def reset_input_buffer(self):
        pass

    def close(self):
        pass


def _print_single_write(port, addr_hex8, data_hex8, dry):
    if dry:
        print("-DRY- W addr=0x{} data=0x{}".format(addr_hex8, data_hex8))
        return
    uart_term.serial_port_write(port, addr_hex8, data_hex8)


def _print_burst_write(port, addr_hex8, size_hex8, data_list, dry):
    if dry:
        print("-DRY- WB addr=0x{} size=0x{} words={}".format(addr_hex8, size_hex8, len(data_list)))
        return
    uart_term.serial_port_write_burst(port, addr_hex8, size_hex8, data_list)


# ----------------------------------------------------------------------
# Main flow
# ----------------------------------------------------------------------

def freeze_or_release(port, dut, value, dry):
    addrs = FREEZE_ADDRS.get(dut)
    if addrs is None:
        raise KeyError(
            "No freeze-register map for dut='{}'. Add it to FREEZE_ADDRS in load_test.py.".format(dut)
        )
    for a in addrs:
        _print_single_write(port, _pad8(a), _pad8(value), dry)


def load_mem_sv(port, sv_path, base_hex8, dry):
    print("-I- Parsing {}".format(sv_path))
    sections = file_parser.parse_sv_file(sv_path)
    if not sections:
        print("-W- No sections parsed from {}".format(sv_path))
        return
    total_words = sum(len(s[2]) for s in sections)
    print("-I- {} section(s), {} total 32-bit words".format(len(sections), total_words))
    for offset_hex, size_hex8, data_list in sections:
        dest = _section_starting_addr(base_hex8, offset_hex)
        _print_burst_write(port, dest, size_hex8, data_list, dry)


def run(args):
    inst_mem, data_mem = _resolve_mem_files(args.dut, args.test)
    base_imem = _pad8(args.base_imem)
    base_dmem = _pad8(args.base_dmem)

    if args.dry_run:
        port = _DryPort([])
        print("-DRY- (dry run: no COM port opened)")
    else:
        port = uart_term.open_serial_port(args.com)
        uart_term.config_serial_port(port)
        if args.timeout is not None:
            port.timeout = args.timeout

    try:
        if not args.no_freeze:
            print("-I- Freezing {} cores".format(args.dut))
            freeze_or_release(port, args.dut, "1", args.dry_run)

        print("-I- Loading I-MEM from {}".format(inst_mem))
        load_mem_sv(port, inst_mem, base_imem, args.dry_run)

        if data_mem is not None:
            print("-I- Loading D-MEM from {}".format(data_mem))
            load_mem_sv(port, data_mem, base_dmem, args.dry_run)
        else:
            print("-I- No data_mem.sv found; skipping D-MEM load")

        if not args.no_release:
            print("-I- Releasing {} cores".format(args.dut))
            freeze_or_release(port, args.dut, "0", args.dry_run)

        if not args.dry_run:
            time.sleep(0.2)  # let the final ack drain
    finally:
        if not args.dry_run:
            port.close()
            print("-I- Closed {}".format(args.com))


def main():
    p = argparse.ArgumentParser(
        description="Freeze -> burst-load inst_mem.sv/data_mem.sv -> release, via UART debug port.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  python load_test.py -dut lotr -test alive -com COM3\n"
            "  python load_test.py -dut big_core -test draw_tree -com COM4 "
            "-base_dmem 0x00010000\n"
            "  python load_test.py -dut lotr -test alive --dry-run\n"
        ),
    )
    p.add_argument("-dut", required=True, help="DUT name: lotr, big_core, ...")
    p.add_argument("-test", required=True, help="Test name (under target/<dut>/tests/<test>/gcc_files/)")
    p.add_argument("-com", default=None, help="Serial port (required unless --dry-run)")
    p.add_argument("-base_imem", default=DEFAULT_IMEM_BASE, help="I-MEM base (default 0x00000000)")
    p.add_argument("-base_dmem", default=DEFAULT_DMEM_BASE, help="D-MEM base (default 0x00000000)")
    p.add_argument("--timeout", type=float, default=None, help="Override serial read timeout in seconds")
    p.add_argument("--no-freeze", action="store_true", help="Skip the initial freeze writes")
    p.add_argument("--no-release", action="store_true", help="Skip the final release writes")
    p.add_argument("--dry-run", action="store_true", help="Print transactions without touching the board")
    args = p.parse_args()

    if not args.dry_run and not args.com:
        p.error("-com is required unless --dry-run is set")

    try:
        run(args)
    except FileNotFoundError as e:
        print("-E- {}".format(e))
        sys.exit(2)
    except Exception as e:
        print("-E- {}: {}".format(type(e).__name__, e))
        sys.exit(1)


if __name__ == "__main__":
    main()

# AGENTS

Short, copy-pasteable recipes for the `fpga_mafia` repo. Focus is **LOTR**
(multi-tile RISC-V demo on the DE10-Lite); big_core notes at the bottom.

All commands assume Git Bash on Windows with the PATH/license bits from
`~/.bashrc` already in place:

```bash
# From ~/.bashrc (one-time; already done on the dev box)
export PATH="/c/altera_lite/25.1std/quartus/bin64:/c/altera_lite/25.1std/questa_fse/win64:$PATH"
export PATH="/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin:$PATH"
export SALT_LICENSE_SERVER="C:/altera_lite/LR-161694_License.dat"
export LM_LICENSE_FILE="C:/altera_lite/LR-161694_License.dat"
```

Sanity:

```bash
which quartus_sh vsim riscv-none-embed-gcc
quartus_sh --version | head -1   # 25.1std
```

---

## Repository layout (LOTR-relevant)

```
source/lotr/                 # RTL (gpc_4t cores, ring, UART, VGA, MMIO, packages)
verif/lotr/                  # testbenches, post-process scripts, golden logs
  tb/lotr_tb.sv              # main multi-tile TB (force-loaded I/D-MEMs)
  file_list/lotr_list.f      # sim file list (used by vlog)
  tests/*.c                  # SW tests (alive.c, sorting_VGA.c, …)
app/                         # crt0, linker, defines, JSON test configs
FPGA/lotr/                   # Quartus project (CPU_GARAGE)
  CPU_GARAGE.qsf             # project + pins + fast-compile block
  de10lite_lotr.sdc          # SDC constraints
  sv/, mem_hex/              # FPGA-only sources & mem inits
  output_files/              # built reports + CPU_GARAGE.sof
target/lotr/                 # generated: SW artifacts, modelsim work, transcripts
build.py                     # single entry point for SW/HW/sim/FPGA/prog
```

---

## build.py — one entry point

```bash
python build.py -h
```

Flags used most:

| Flag                          | What it does                                                     |
| ----------------------------- | ---------------------------------------------------------------- |
| `-dut lotr`                   | Select DUT (also `big_core`, `mini_core`, `fabric`, ...)        |
| `-tests "alive sorting_VGA"`  | Pick one or more tests from `verif/<dut>/tests/`                 |
| `-regress <name>`             | Use a regress list file from `verif/<dut>/regress/`              |
| `-app`                        | Compile RISC-V SW (produces `gcc_files/inst_mem.sv`, etc.)       |
| `-hw`                         | Compile RTL with `vlog` (into `target/<dut>/modelsim/work`)      |
| `-sim`                        | Run Questa (`vsim`) batch; copies transcript to the test dir     |
| `-gui`                        | Open Questa GUI (auto-loads `verif/<dut>/tb/wave.do` if present) |
| `-full_run`                   | `-app -hw -sim` in one go                                        |
| `-fpga`                       | Quartus full compile (A&S + Fit + Asm + STA)                     |
| `-reload`                     | **Fast FPGA refresh:** regen MIFs from SW, `quartus_cdb --update_mif`, `quartus_asm` only (no Map/Fit; needs a prior successful `-fpga`) |
| `-fpga_project CPU_GARAGE`    | Override project name (LOTR uses `CPU_GARAGE`, not `de10_lite_lotr`) |
| `-prog`                       | Program the DE10-Lite over JTAG (`quartus_pgm`)                  |
| `-keep_going`                 | Keep running the list on first failure                           |
| `-cfg lotr_rv32i`             | Pick JSON config from `app/cfg/`                                 |
| `-cmd` / `-v`                 | Print commands / verbose                                         |
| `-clean`                      | Wipe `target/<dut>/tests/` before the run                        |

Pass/fail is parsed from Questa's final `Errors: N, Warnings: M` line.
Missing `inst_mem.sv` is detected and triggers SW build automatically.

---

## LOTR — authoring a C program

End-to-end: add source → compile with `build.py` → (optional) simulate → push
to the FPGA with either a **full** Quartus compile or a **fast MIF reload**.

### 1. Add the test source

- Put the program at **`verif/lotr/tests/<test_name>.c`** (e.g. `my_demo.c`).
- Pass it to `build.py` as **`-tests <test_name>`** with no extension (e.g.
  `-tests my_demo`).
- Includes: the build adds `-I app/defines` and `-I verif/lotr/tests/<test_name>/`
  for local headers. Typical LOTR tests use `#include "LOTR_defines.h"` (and
  friends from `app/defines/`).

### 2. Memory layout and startup (do not skip for hardware)

- With `-dut lotr`, `build.py` **auto-selects** `app/cfg/lotr_rv32i.json` if
  present. That file sets **`D_MEM_OFFSET` to `0x400000`**, **`crt0_file` to
  `crt0_lotr.s`**, and `rv32i` GCC flags — matching the LOTR FPGA memory map.
- You can pin this explicitly: **`-cfg lotr_rv32i`**.
- **Wrong config** (e.g. `default.json` with a small `D_MEM_OFFSET`) produces
  binaries that can look fine in some flows but **fail silently on the board**.

### 3. Build software (always the first step for a new or edited `.c`)

```bash
python build.py -dut lotr -tests my_demo -app -cfg lotr_rv32i
```

Outputs land under:

- `target/lotr/tests/my_demo/gcc_files/inst_mem.sv` — instruction ROM init
- `target/lotr/tests/my_demo/gcc_files/data_mem.sv` — data RAM init (if used)

Use **`-app -hw -sim`** when you want to verify in Questa before touching the
FPGA.

### 4. Fast MIF update vs full FPGA compile

| Goal | Command sketch |
| ---- | ---------------- |
| **Only recompile C and regenerate SIM/hex artifacts** | `-dut lotr -tests my_demo -app` |
| **Fast board update** (bitstream already built once) | `-app -reload -prog -fpga_project CPU_GARAGE` |
| **First bring-up or QSF/RTL change** | `-app -fpga -prog -fpga_project CPU_GARAGE` |

**Fast reload** (`-reload`) assumes you already ran a successful **`-fpga`**
so `db/` / fit results exist. It:

1. Runs **`mif_gen.py`** on the new `inst_mem.sv` / `data_mem.sv` → writes
   `FPGA/lotr/mem_hex/i_mem.mif` and `d_mem.mif` (uses `D_MEM_OFFSET` from the
   active JSON for data).
2. Runs **`quartus_cdb --update_mif CPU_GARAGE`** then **`quartus_asm`**.
3. Produces an updated **`FPGA/lotr/output_files/CPU_GARAGE.sof`** without
   re-running Analysis & Synthesis or the Fitter (typically ~10s on a 10M50).

**Copy-paste (iterate on C only):**

```bash
python build.py -dut lotr -tests my_demo -app -reload -prog -fpga_project CPU_GARAGE -cfg lotr_rv32i
```

Omit **`-prog`** if you only want the new SOF on disk and will load it yourself.
If **`update_mif` / assembler** fails, run a full **`-fpga`** once, then return
to `-reload`.

---

## LOTR — simulation

### Single test, batch

```bash
python build.py -dut lotr -tests alive -app -hw -sim
# -> target/lotr/tests/alive/alive_transcript
```

### Single test, interactive (waves)

```bash
python build.py -dut lotr -tests alive -app -hw -sim -gui
# Questa GUI opens; close it when done so the node-locked license is released.
```

### Multiple tests in one invocation

```bash
python build.py -dut lotr -tests "alive sorting_VGA print_int_test" -app -hw -sim -keep_going
```

### Re-run faster (skip SW rebuild when not needed)

```bash
python build.py -dut lotr -tests alive -hw -sim     # reuses existing inst_mem.sv
```

### Direct Questa (when scripting outside build.py)

```bash
cd target/lotr/modelsim
vsim.exe -voptargs=+acc work.lotr_tb -c -do "run -all; quit -f" +STRING=alive
```

### Tips / gotchas

- TB backdoor-loads I/D-MEMs with `force` / `release` (Questa 2025+ rejects
  procedural writes to `always_ff` targets; see
  `verif/lotr/tb/lotr_tb.sv` around the I/D-MEM force block).
- Benign sim warnings you can ignore while iterating:
  - `vsim-PLI-3412`: `data_mem.sv` starts below the backdoor range — harmless
    for tests that don't touch those addresses.
  - `vsim-3015`: Counter port-width mismatches in `transfer_handler_engine`.
- License: LOTR is Questa Altera Starter (node-locked, **one** session).
  If a run says *"only one session is allowed ... an instance of QuestaSim
  is already running"*, kill stray processes:
  ```bash
  taskkill //F //IM vsim.exe //IM vsimk.exe 2>/dev/null
  ```

---

## LOTR — regression

`-regress` uses a plain-text file under `verif/<dut>/regress/` where each line
is `<test_name> [<sim +/-g args>]`. LOTR does not ship a canned regress list
yet — here is the template (copy from `verif/big_core/regress/rv32i_level0`):

```
alive.c
sorting_VGA.c        -gV_TIMEOUT=500000
print_int_test.c
```

Then:

```bash
python build.py -dut lotr -regress my_smoke -app -hw -sim -keep_going
```

Useful DUT regress lists already in the repo:

- `verif/big_core/regress/rv32i_level0`          — full smoke
- `verif/big_core/regress/rv32i_level0_cfg_rv32im` — same tests with rv32im
- `verif/mini_core/regress/rv32i_level0`         — reference pipeline

---

## LOTR — FPGA (DE10-Lite, Quartus 25.1std)

The project file is `FPGA/lotr/CPU_GARAGE.qpf` (project name **`CPU_GARAGE`**,
not `de10_lite_lotr`). All paths below are repo-relative.

### One-shot via build.py

```bash
# Build SW, run Quartus full compile, program the board
python build.py -dut lotr -tests alive -app -fpga -prog -fpga_project CPU_GARAGE
```

### Fast MIF-only refresh (after the first full compile)

Use this when the **FPGA image is already built** and you only changed **C /
linker artifacts** (instruction/data init). This does **not** re-run Map/Fit.

```bash
python build.py -dut lotr -tests alive -app -reload -prog -fpga_project CPU_GARAGE -cfg lotr_rv32i
```

Same flow works for any test name (`fpga_main`, `parallel_7seg`, …). Requires
an existing successful compile under `FPGA/lotr/` so `quartus_cdb --update_mif`
can patch BRAM init. See **“LOTR — authoring a C program”** above for details.

### Manual Quartus flow

```bash
cd FPGA/lotr

# Clean build (only when toolchain version changed or DB is suspect)
rm -rf db incremental_db output_files

# Full compile (A&S + Fit + Asm + STA + EDA netlist)
quartus_sh --flow compile CPU_GARAGE
# -> output_files/CPU_GARAGE.sof, *.rpt, *.summary, *.flow.rpt
```

Individual stages (when iterating on fit/timing):

```bash
quartus_map CPU_GARAGE -c CPU_GARAGE
quartus_fit CPU_GARAGE -c CPU_GARAGE
quartus_asm CPU_GARAGE -c CPU_GARAGE
quartus_sta CPU_GARAGE -c CPU_GARAGE
```

### Program the DE10-Lite (CLI)

```bash
# Volatile: loads SOF over JTAG; lost on power cycle.
quartus_pgm -m jtag -o "p;FPGA/lotr/output_files/CPU_GARAGE.sof"

# Identify JTAG cables if needed
jtagconfig
quartus_pgm -l                     # list
quartus_pgm -c "USB-Blaster [USB-0]" -m jtag -o "p;FPGA/lotr/output_files/CPU_GARAGE.sof"

# Non-volatile: program internal config flash via POF
quartus_cpf -c output_files/CPU_GARAGE.sof output_files/CPU_GARAGE.pof
quartus_pgm -m jtag -o "p;FPGA/lotr/output_files/CPU_GARAGE.pof"
```

### Fast-compile vs quality

`CPU_GARAGE.qsf` has a fast-compile block at the bottom for iteration:

```
set_global_assignment -name FITTER_EFFORT "FAST FIT"
set_global_assignment -name FITTER_AGGRESSIVE_ROUTABILITY_OPTIMIZATION NEVER
set_global_assignment -name PHYSICAL_SYNTHESIS_EFFORT OFF
set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS OFF
set_global_assignment -name SMART_RECOMPILE ON
```

For a final build, comment those out (and flip `ENABLE_SIGNALTAP ON` if you
want the JTAG logic analyzer).

One-off override on the command line (overrides the QSF for that run only):

```bash
quartus_sh --flow compile CPU_GARAGE \
  -c CPU_GARAGE \
  --set FITTER_EFFORT="FAST FIT" \
  --set PHYSICAL_SYNTHESIS_EFFORT=OFF \
  --set NUM_PARALLEL_PROCESSORS=4
```

### Reading the results

```bash
tail -n 40 FPGA/lotr/output_files/CPU_GARAGE.flow.rpt    # overall summary
grep -Hi "Error\|Critical" FPGA/lotr/output_files/*.rpt  # quick sanity
```

Timing summary lives in `*.sta.rpt` (setup/hold slack). Positive slack ⇒ pass.

### Common FPGA gotchas

- *"Database format is incompatible with current version"* → wiping a stale
  `db/` built by an older Quartus is enough: `rm -rf db incremental_db output_files`.
- *"Some pins have incomplete I/O assignments"* is a warning only; see
  `fit.rpt` → I/O Assignment Warnings.
- LOTR's `CLK_25` (VGA) has no explicit `create_generated_clock` yet, so STA
  only constrains `CLK_50`. To extend STA to VGA paths, add to
  `de10lite_lotr.sdc`:
  ```tcl
  create_generated_clock -name CLK_25 -divide_by 2 \
      -source [get_ports CLK_50] \
      [get_registers {lotr:lotr|fpga_tile:fpga_tile|DE10Lite_MMIO:DE10Lite_MMIO|vga_ctrl:vga_ctrl|CLK_25}]
  derive_clock_uncertainty
  ```
- Can't checkout license for `vsim`/`quartus_*`: `.bashrc` must export
  `SALT_LICENSE_SERVER` **and** `LM_LICENSE_FILE` (both point at
  `C:/altera_lite/LR-161694_License.dat`).

---

## Quick recipes

```bash
# Clean everything and start fresh
python build.py -dut lotr -clean
rm -rf FPGA/lotr/db FPGA/lotr/incremental_db FPGA/lotr/output_files target/lotr

# Sim a test, open GUI, then batch re-run
python build.py -dut lotr -tests alive -app -hw -sim -gui      # iterate in GUI
python build.py -dut lotr -tests alive -hw -sim                # batch pass

# End-to-end FPGA bring-up with alive.c
python build.py -dut lotr -tests alive -app -fpga -prog -fpga_project CPU_GARAGE

# C/code iteration: fast MIF + program (no full Quartus compile)
python build.py -dut lotr -tests alive -app -reload -prog -fpga_project CPU_GARAGE -cfg lotr_rv32i

# Only load a prebuilt bitstream
quartus_pgm -m jtag -o "p;FPGA/lotr/output_files/CPU_GARAGE.sof"
```

---

## big_core (quick reference)

Same flow, project name matches convention (`de10_lite_big_core.qsf`):

```bash
# Sim
python build.py -dut big_core -tests alive -app -hw -sim

# Regression
python build.py -dut big_core -regress rv32i_level0 -app -hw -sim -keep_going

# FPGA
python build.py -dut big_core -tests alive -app -fpga -prog
# or:
cd FPGA/big_core
quartus_sh --flow compile de10_lite_big_core
quartus_pgm -m jtag -o "p;output_files/de10_lite_big_core.sof"
```

No `-fpga_project` override needed for `big_core` — `build.py` auto-detects
`de10_lite_<dut>.qsf`.

---

## Where to look when things break

- SW build failures → `target/<dut>/tests/<test>/gcc_files/` (map, elf.txt)
- Sim pass/fail   → `target/<dut>/tests/<test>/<test>_transcript`
- Sim work lib    → `target/<dut>/modelsim/` (delete `work/` for a clean rebuild)
- FPGA results    → `FPGA/<dut>/output_files/*.rpt` (esp. `*.flow.rpt`, `*.sta.rpt`, `*.fit.rpt`)
- JTAG / cable    → `jtagconfig`, `quartus_pgm -l`
- Env / license   → `~/.bashrc`, then `source ~/.bashrc`

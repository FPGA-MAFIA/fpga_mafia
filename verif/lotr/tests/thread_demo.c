/*
 * thread_demo.c — 8 threads (4 per tile), each in its own VGA band + distinct IO.
 *
 * CR_WHO_AM_I (see hello_sw.c, cr_mem.sv): { 22'b0, core_id[7:0], thread[1:0] }
 *   core_id 1, thread 0..3 -> 0x4 .. 0x7 (tile 1)
 *   core_id 2, thread 0..3 -> 0x8 .. 0xb (tile 2)
 *
 * fpga_main.c writes CR_ID2x_PC_EN at the start of each Core 2 case; on this
 * RTL that address is the current tile's THREADx_PC_EN for the same thread index,
 * so a write of 0 would freeze that thread before it does useful work. We keep
 * fpga_main's delay() pacing only (no PC_EN poke) so all eight threads stay live.
 *
 * VGA uses only draw_char() at fixed (raw,col) — no rvc_printf (shared cursor).
 */

#include "LOTR_defines.h"
#include "graphic_lotr.h"

/* Same pacing as fpga_main.c */
static void delay(void) {
    int timer = 0;
    while (timer < 80000) {
        timer++;
    }
}

static void busy_wait(int n) {
    volatile int t = 0;
    while (t < n) {
        t++;
    }
}

static void put_str(int raw, int col, const char *s) {
    int c = col;
    while (*s != '\0' && c < COLUMN) {
        draw_char(*s++, raw, c++);
    }
}

static void put_dec_fixed(int raw, int col, unsigned n, int width) {
    char d[12];
    int i = 0;

    if (n == 0) {
        d[i++] = '0';
    } else {
        while (n && i < 11) {
            d[i++] = (char)('0' + (n % 10U));
            n /= 10U;
        }
    }
    int need = i;
    int c = col;
    int pad = width - need;
    while (pad-- > 0) {
        draw_char(' ', raw, c++);
    }
    while (i > 0) {
        draw_char(d[--i], raw, c++);
    }
}

/* 7-seg patterns, same encoding as parallel_7seg / led_blinky */
static const int seg_hex[16] = {
    0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78,
    0x00, 0x18, 0x08, 0x03, 0x46, 0x21, 0x06, 0x0E
};

int main(void) {
    /* Let CR / ring settle (hello_sw.c, fpga_main clear_screen has similar effect). */
    {
        int t = 0;
        while (t < 100000) {
            t++;
        }
    }

    int id = CR_WHO_AM_I[0];

    if (id == 0x4) {
        clear_screen();
    } else {
        busy_wait(600000);
        /* Tile 2 MMIO often reaches DE10Lite_MMIO via extra hops — give C1T0 time
         * to finish clear_screen() before Core 2 draws (fpga_main relies on delay). */
        if (id >= 0x8 && id <= 0xb) {
            busy_wait(1200000);
        }
    }

    switch (id) {

    case 0x4: /* C1 T0 — HEX0 cycles 0–F */
        put_str(0, 0, "C1T0: HEX0 CYCLING 0-F");
        {
            int d = 0;
            while (1) {
                *SEG0_FGPA = seg_hex[d & 15];
                d++;
                busy_wait(200000);
            }
        }

    case 0x5: /* C1 T1 — HEX1 = SW[3:0] as hex digit */
        put_str(6, 0, "C1T1: HEX1 SHOWS SW[3:0]");
        while (1) {
            int sw = *SWITCH_FGPA;
            *SEG1_FGPA = seg_hex[sw & 0xF];
            busy_wait(40000);
        }

    case 0x6: /* C1 T2 — decimal counter on VGA */
        put_str(12, 0, "C1T2: COUNTER (DEC, BELOW)");
        {
            unsigned c = 0;
            while (1) {
                put_dec_fixed(14, 0, c, 10);
                c++;
                busy_wait(120000);
            }
        }

    case 0x7: /* C1 T3 — one LED walks LED[9:0] */
        put_str(18, 0, "C1T3: LED ROTATE 0-9");
        {
            int pos = 0;
            while (1) {
                *LED_FGPA = (1 << (pos % 10));
                pos++;
                busy_wait(180000);
            }
        }

    /* ---- Core 2: same initial delay() pacing as fpga_main (no PC_EN=0 here). ---- */
    case 0x8: /* C2 T0 — HEX3 cycles 8,9,A */
        delay();
        put_str(24, 0, "C2T0: HEX3 CYCLES 8,9,A");
        {
            int k = 0;
            while (1) {
                *SEG3_FGPA = seg_hex[8 + (k % 3)];
                k++;
                busy_wait(250000);
            }
        }

    case 0x9: /* C2 T1 — HEX4 = SW[7:4] */
        delay();
        put_str(30, 0, "C2T1: HEX4 SHOWS SW[7:4]");
        while (1) {
            int sw = *SWITCH_FGPA;
            *SEG4_FGPA = seg_hex[(sw >> 4) & 0xF];
            busy_wait(40000);
        }

    case 0xa: /* C2 T2 — slow bouncing '#' (erase only previous cell; full-line clear was too heavy) */
        delay();
        put_str(36, 0, "C2T2: # BOUNCES ROW 52 SLOW");
        {
            const int BROW = 52;
            int x = 12;
            int dir = 1;
            int prev = -1;
            while (1) {
                if (prev >= 0) {
                    draw_char(' ', BROW, prev);
                }
                draw_char('#', BROW, x);
                prev = x;
                x += dir;
                if (x >= 74 || x <= 5) {
                    dir = -dir;
                }
                busy_wait(380000);
            }
        }

    case 0xb:
        /* DE10-Lite KEY0 is often wired as CPU_RESET — use SW9 for a testable bit. */
        delay();
        put_str(42, 0, "C2T3: HEX5 = SW9 (0 OR 1)");
        while (1) {
            int sw = *SWITCH_FGPA;
            int hi = (sw >> 9) & 1;
            *SEG5_FGPA = seg_hex[hi ? 1 : 0];
            busy_wait(40000);
        }

    default:
        while (1) {
        }
    }
}

/* hello_sw.c -- static per-thread IO assignment.
 *
 * Expected CR_WHO_AM_I values: {cr_ro.core[7:0], cr_ro.thread[1:0]}
 *   0x4 = Tile1 Thread0     0x8 = Tile2 Thread0
 *   0x5 = Tile1 Thread1     0x9 = Tile2 Thread1
 *   0x6 = Tile1 Thread2     0xA = Tile2 Thread2
 *   0x7 = Tile1 Thread3     0xB = Tile2 Thread3
 *
 * Assignments:
 *   Tile1 T0..T3 write LED bit 0..3 (they share LED_FGPA; last writer
 *                                    wins, but any visible lit LED in
 *                                    {0,1,2,3} proves Tile1 threads ran).
 *   Tile2 T0..T3 write HEX0..HEX3 with digits '0','1','2','3' respectively.
 *                                    These are distinct regs -> no race;
 *                                    all 4 should be visible at once.
 *   HEX4, HEX5, LED bits [9:4] stay blanked.
 *
 * If we see HEX0='0' HEX1='1' HEX2='2' HEX3='3' and *some* LED in {0..3}
 * lit, CR_WHO_AM_I is working and the fabric is fine.
 */

#include "LOTR_defines.h"

#define BLANK_SEG 0b1111111

/* Active-LOW 7-seg digit patterns (same as parallel_7seg.c). */
#define DIG_0 0b1000000
#define DIG_1 0b1111001
#define DIG_2 0b0100100
#define DIG_3 0b0110000

int main()
{
    /* Warm-up: let CR ring settle before the first CR_WHO_AM_I read.
     * fpga_main.c effectively does this via its clear_screen() call. */
    int t = 0;
    while (t < 100000) { t++; }

    int UniqeId = CR_WHO_AM_I[0];

    switch (UniqeId) {
    /* ---- Tile 1 (core id 1): animate LEDs ---- */
    case 0x4:  *LED_FGPA  = 1 << 0; while (1) { }  /* LED0 */
    case 0x5:  *LED_FGPA  = 1 << 1; while (1) { }  /* LED1 */
    case 0x6:  *LED_FGPA  = 1 << 2; while (1) { }  /* LED2 */
    case 0x7:  *LED_FGPA  = 1 << 3; while (1) { }  /* LED3 */

    /* ---- Tile 2 (core id 2): drive HEX displays (separate regs, no race) ---- */
    case 0x8:  *SEG0_FGPA = DIG_0;  while (1) { }  /* HEX0 = '0' */
    case 0x9:  *SEG1_FGPA = DIG_1;  while (1) { }  /* HEX1 = '1' */
    case 0xA:  *SEG2_FGPA = DIG_2;  while (1) { }  /* HEX2 = '2' */
    case 0xB:  *SEG3_FGPA = DIG_3;  while (1) { }  /* HEX3 = '3' */

    default:
        while (1) { }
        break;
    }

    return 0;
}

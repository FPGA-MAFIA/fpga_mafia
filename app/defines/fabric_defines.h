#define TILE_1_1_SCRATCH ((volatile int *) (0x1101F000))
#define TILE_1_2_SCRATCH ((volatile int *) (0x1201F000))
#define TILE_1_3_SCRATCH ((volatile int *) (0x1301F000))
#define TILE_2_1_SCRATCH ((volatile int *) (0x2101F000))
#define TILE_2_2_SCRATCH ((volatile int *) (0x2201F000))
#define TILE_2_3_SCRATCH ((volatile int *) (0x2301F000))
#define TILE_3_1_SCRATCH ((volatile int *) (0x3101F000))
#define TILE_3_2_SCRATCH ((volatile int *) (0x3201F000))
#define TILE_3_3_SCRATCH ((volatile int *) (0x3301F000))
#define LOCAL_SCRATCH    ((volatile int *) (0x0001F000))

#define WHO_AM_I         ((volatile int *) (0x00FFFFFF))

/* The shared VGA frame buffer. 640x480 monochrome, one bit per pixel, so
   38400 bytes. Unlike the scratch pads above there is only one of these in
   the whole fabric, so every tile reaching this address lands on the same
   memory no matter which tile it runs on.
   Byte layout, same as graphic_vga.h:
     byte_addr = (y / 4) * 320 + (x / 8) * 4 + (y % 4)   */
#define FABRIC_VGA_BASE  0x00FF0000
#define FABRIC_VGA_MEM   ((volatile unsigned char *) (FABRIC_VGA_BASE))
#define FABRIC_VGA_BYTES 38400
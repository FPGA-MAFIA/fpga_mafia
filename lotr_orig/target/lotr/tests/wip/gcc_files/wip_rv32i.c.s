	.file	"wip.c"
	.option nopic
	.text
	.globl	ASCII_TOP
	.data
	.align	2
	.type	ASCII_TOP, @object
	.size	ASCII_TOP, 388
ASCII_TOP:
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	1382169600
	.word	438048768
	.word	1078082560
	.word	1078082560
	.word	606613504
	.word	1040350720
	.word	37895168
	.word	809532928
	.word	1111636992
	.word	1111636992
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	1715214336
	.word	1042423296
	.word	37633024
	.word	574496256
	.word	101088768
	.word	101088768
	.word	37633024
	.word	1717986816
	.word	404258304
	.word	1616928768
	.word	1046889984
	.word	101058048
	.word	1516651008
	.word	1852203520
	.word	1717976064
	.word	1717976576
	.word	1111636992
	.word	1717976576
	.word	503741440
	.word	404258304
	.word	1717986816
	.word	1717986816
	.word	1111638528
	.word	1013343744
	.word	1013343744
	.word	270564864
	.zero	24
	.globl	ASCII_BOTTOM
	.align	2
	.type	ASCII_BOTTOM, @object
	.size	ASCII_BOTTOM, 388
ASCII_BOTTOM:
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	102635544
	.word	0
	.word	1579008
	.word	0
	.word	3950154
	.word	8263704
	.word	8258108
	.word	3949112
	.word	2105470
	.word	3949120
	.word	3949118
	.word	526344
	.word	3949116
	.word	4079740
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	6717030
	.word	1974846
	.word	3948034
	.word	1981986
	.word	8259198
	.word	394878
	.word	3940922
	.word	6710910
	.word	8263704
	.word	8152678
	.word	4613694
	.word	8259078
	.word	4342362
	.word	4613750
	.word	3958374
	.word	394814
	.word	8151634
	.word	6710846
	.word	4087928
	.word	1579032
	.word	3964518
	.word	1588326
	.word	4357722
	.word	6710844
	.word	1579032
	.word	8258568
	.zero	24
	.globl	ANIME_TOP
	.align	2
	.type	ANIME_TOP, @object
	.size	ANIME_TOP, 24
ANIME_TOP:
	.word	2084048944
	.word	943198256
	.word	943198256
	.word	2084048944
	.word	943198256
	.word	0
	.globl	ANIME_BOTTOM
	.align	2
	.type	ANIME_BOTTOM, @object
	.size	ANIME_BOTTOM, 24
ANIME_BOTTOM:
	.word	-2105259846
	.word	1145613432
	.word	271067256
	.word	672151738
	.word	1212692604
	.word	0
	.text
	.align	2
	.globl	draw_char
	.type	draw_char, @function
draw_char:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	mv	a5,a0
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	sb	a5,-33(s0)
	lw	a4,-40(s0)
	mv	a5,a4
	slli	a5,a5,2
	add	a5,a5,a4
	slli	a5,a5,6
	sw	a5,-20(s0)
	lw	a5,-44(s0)
	slli	a5,a5,2
	sw	a5,-24(s0)
	lw	a4,-24(s0)
	lw	a5,-20(s0)
	add	a4,a4,a5
	li	a5,54525952
	add	a5,a4,a5
	sw	a5,-28(s0)
	lw	a4,-24(s0)
	lw	a5,-20(s0)
	add	a4,a4,a5
	li	a5,54525952
	addi	a5,a5,320
	add	a5,a4,a5
	sw	a5,-32(s0)
	lbu	a5,-33(s0)
	lui	a4,%hi(ASCII_TOP)
	addi	a4,a4,%lo(ASCII_TOP)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a5,0(a5)
	mv	a4,a5
	lw	a5,-28(s0)
	sw	a4,0(a5)
	lbu	a5,-33(s0)
	lui	a4,%hi(ASCII_BOTTOM)
	addi	a4,a4,%lo(ASCII_BOTTOM)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a5,0(a5)
	mv	a4,a5
	lw	a5,-32(s0)
	sw	a4,0(a5)
	nop
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	draw_char, .-draw_char
	.align	2
	.globl	rvc_printf
	.type	rvc_printf, @function
rvc_printf:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	zero,-20(s0)
	sw	zero,-24(s0)
	sw	zero,-28(s0)
	li	a5,12582912
	addi	a5,a5,544
	lw	a5,0(a5)
	sw	a5,-28(s0)
	li	a5,12582912
	addi	a5,a5,564
	lw	a5,0(a5)
	sw	a5,-24(s0)
	j	.L3
.L7:
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a4,0(a5)
	li	a5,10
	bne	a4,a5,.L4
	sw	zero,-28(s0)
	lw	a5,-24(s0)
	addi	a5,a5,2
	sw	a5,-24(s0)
	lw	a4,-24(s0)
	li	a5,120
	bne	a4,a5,.L5
	sw	zero,-24(s0)
.L5:
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
	j	.L3
.L4:
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	lw	a4,-24(s0)
	lw	a3,-28(s0)
	mv	a2,a3
	mv	a1,a4
	mv	a0,a5
	call	draw_char
	lw	a5,-28(s0)
	addi	a5,a5,1
	sw	a5,-28(s0)
	lw	a4,-28(s0)
	li	a5,80
	bne	a4,a5,.L6
	sw	zero,-28(s0)
	lw	a5,-24(s0)
	addi	a5,a5,2
	sw	a5,-24(s0)
	lw	a4,-24(s0)
	li	a5,120
	bne	a4,a5,.L6
	sw	zero,-24(s0)
.L6:
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L3:
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	bne	a5,zero,.L7
	li	a5,12582912
	addi	a5,a5,544
	lw	a4,-28(s0)
	sw	a4,0(a5)
	li	a5,12582912
	addi	a5,a5,564
	lw	a4,-24(s0)
	sw	a4,0(a5)
	nop
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	rvc_printf, .-rvc_printf
	.align	2
	.globl	draw_symbol
	.type	draw_symbol, @function
draw_symbol:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	lw	a4,-40(s0)
	mv	a5,a4
	slli	a5,a5,2
	add	a5,a5,a4
	slli	a5,a5,6
	sw	a5,-20(s0)
	lw	a5,-44(s0)
	slli	a5,a5,2
	sw	a5,-24(s0)
	lw	a4,-24(s0)
	lw	a5,-20(s0)
	add	a4,a4,a5
	li	a5,54525952
	add	a5,a4,a5
	sw	a5,-28(s0)
	lw	a4,-24(s0)
	lw	a5,-20(s0)
	add	a4,a4,a5
	li	a5,54525952
	addi	a5,a5,320
	add	a5,a4,a5
	sw	a5,-32(s0)
	lui	a5,%hi(ANIME_TOP)
	addi	a4,a5,%lo(ANIME_TOP)
	lw	a5,-36(s0)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a5,0(a5)
	mv	a4,a5
	lw	a5,-28(s0)
	sw	a4,0(a5)
	lui	a5,%hi(ANIME_BOTTOM)
	addi	a4,a5,%lo(ANIME_BOTTOM)
	lw	a5,-36(s0)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a5,0(a5)
	mv	a4,a5
	lw	a5,-32(s0)
	sw	a4,0(a5)
	nop
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	draw_symbol, .-draw_symbol
	.align	2
	.globl	set_cursor
	.type	set_cursor, @function
set_cursor:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	sw	a1,-24(s0)
	li	a5,12582912
	addi	a5,a5,544
	lw	a4,-24(s0)
	sw	a4,0(a5)
	li	a5,12582912
	addi	a5,a5,564
	lw	a4,-20(s0)
	sw	a4,0(a5)
	nop
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	set_cursor, .-set_cursor
	.align	2
	.globl	clear_screen
	.type	clear_screen, @function
clear_screen:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	sw	zero,-20(s0)
	li	a5,54525952
	sw	a5,-24(s0)
	sw	zero,-20(s0)
	j	.L11
.L12:
	lw	a5,-20(s0)
	slli	a5,a5,2
	lw	a4,-24(s0)
	add	a5,a4,a5
	sw	zero,0(a5)
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L11:
	lw	a4,-20(s0)
	li	a5,8192
	addi	a5,a5,1407
	ble	a4,a5,.L12
	nop
	nop
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	clear_screen, .-clear_screen
	.globl	__modsi3
	.globl	__divsi3
	.align	2
	.globl	rvc_print_int
	.type	rvc_print_int, @function
rvc_print_int:
	addi	sp,sp,-64
	sw	ra,60(sp)
	sw	s0,56(sp)
	addi	s0,sp,64
	sw	a0,-52(s0)
	sw	zero,-20(s0)
	sw	zero,-24(s0)
	lw	a5,-52(s0)
	bge	a5,zero,.L15
	lw	a5,-20(s0)
	addi	a4,a5,1
	sw	a4,-20(s0)
	addi	a4,s0,-16
	add	a5,a4,a5
	li	a4,45
	sb	a4,-32(a5)
	lw	a5,-52(s0)
	neg	a5,a5
	sw	a5,-52(s0)
.L15:
	lw	a5,-52(s0)
	li	a1,10
	mv	a0,a5
	call	__modsi3
	mv	a5,a0
	andi	a4,a5,0xff
	lw	a5,-20(s0)
	addi	a3,a5,1
	sw	a3,-20(s0)
	addi	a4,a4,48
	andi	a4,a4,0xff
	addi	a3,s0,-16
	add	a5,a3,a5
	sb	a4,-32(a5)
	lw	a5,-52(s0)
	li	a1,10
	mv	a0,a5
	call	__divsi3
	mv	a5,a0
	sw	a5,-52(s0)
	lw	a5,-52(s0)
	bgt	a5,zero,.L15
	sw	zero,-24(s0)
	j	.L16
.L17:
	lw	a5,-24(s0)
	addi	a4,s0,-16
	add	a5,a4,a5
	lbu	a5,-32(a5)
	sb	a5,-33(s0)
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	sub	a5,a4,a5
	addi	a5,a5,-1
	addi	a4,s0,-16
	add	a5,a4,a5
	lbu	a4,-32(a5)
	lw	a5,-24(s0)
	addi	a3,s0,-16
	add	a5,a3,a5
	sb	a4,-32(a5)
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	sub	a5,a4,a5
	addi	a5,a5,-1
	addi	a4,s0,-16
	add	a5,a4,a5
	lbu	a4,-33(s0)
	sb	a4,-32(a5)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L16:
	lw	a5,-20(s0)
	srli	a4,a5,31
	add	a5,a4,a5
	srai	a5,a5,1
	mv	a4,a5
	lw	a5,-24(s0)
	blt	a5,a4,.L17
	li	a5,12582912
	addi	a5,a5,564
	lw	a5,0(a5)
	sw	a5,-28(s0)
	li	a5,12582912
	addi	a5,a5,544
	lw	a5,0(a5)
	sw	a5,-32(s0)
	sw	zero,-24(s0)
	j	.L18
.L21:
	lw	a5,-24(s0)
	addi	a4,s0,-16
	add	a5,a4,a5
	lbu	a5,-32(a5)
	lw	a2,-32(s0)
	lw	a1,-28(s0)
	mv	a0,a5
	call	draw_char
	lw	a5,-32(s0)
	addi	a5,a5,1
	sw	a5,-32(s0)
	lw	a4,-32(s0)
	li	a5,80
	bne	a4,a5,.L19
	sw	zero,-32(s0)
	lw	a5,-28(s0)
	addi	a5,a5,2
	sw	a5,-28(s0)
.L19:
	lw	a4,-28(s0)
	li	a5,119
	ble	a4,a5,.L20
	sw	zero,-28(s0)
.L20:
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L18:
	lw	a4,-24(s0)
	lw	a5,-20(s0)
	blt	a4,a5,.L21
	li	a5,12582912
	addi	a5,a5,544
	lw	a4,-32(s0)
	sw	a4,0(a5)
	li	a5,12582912
	addi	a5,a5,564
	lw	a4,-28(s0)
	sw	a4,0(a5)
	nop
	lw	ra,60(sp)
	lw	s0,56(sp)
	addi	sp,sp,64
	jr	ra
	.size	rvc_print_int, .-rvc_print_int
	.align	2
	.globl	rvc_delay
	.type	rvc_delay, @function
rvc_delay:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	zero,-20(s0)
	j	.L23
.L24:
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L23:
	lw	a4,-20(s0)
	lw	a5,-36(s0)
	blt	a4,a5,.L24
	nop
	nop
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	rvc_delay, .-rvc_delay
	.align	2
	.globl	hex7seg
	.type	hex7seg, @function
hex7seg:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	lw	a4,-36(s0)
	li	a5,14
	bgtu	a4,a5,.L26
	lw	a5,-36(s0)
	slli	a4,a5,2
	lui	a5,%hi(.L28)
	addi	a5,a5,%lo(.L28)
	add	a5,a4,a5
	lw	a5,0(a5)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L28:
	.word	.L42
	.word	.L41
	.word	.L40
	.word	.L39
	.word	.L38
	.word	.L37
	.word	.L36
	.word	.L35
	.word	.L34
	.word	.L33
	.word	.L32
	.word	.L31
	.word	.L30
	.word	.L29
	.word	.L27
	.text
.L42:
	li	a5,192
	sw	a5,-20(s0)
	j	.L43
.L41:
	li	a5,249
	sw	a5,-20(s0)
	j	.L43
.L40:
	li	a5,164
	sw	a5,-20(s0)
	j	.L43
.L39:
	li	a5,176
	sw	a5,-20(s0)
	j	.L43
.L38:
	li	a5,153
	sw	a5,-20(s0)
	j	.L43
.L37:
	li	a5,146
	sw	a5,-20(s0)
	j	.L43
.L36:
	li	a5,130
	sw	a5,-20(s0)
	j	.L43
.L35:
	li	a5,248
	sw	a5,-20(s0)
	j	.L43
.L34:
	li	a5,128
	sw	a5,-20(s0)
	j	.L43
.L33:
	li	a5,144
	sw	a5,-20(s0)
	j	.L43
.L32:
	li	a5,136
	sw	a5,-20(s0)
	j	.L43
.L31:
	li	a5,131
	sw	a5,-20(s0)
	j	.L43
.L30:
	li	a5,198
	sw	a5,-20(s0)
	j	.L43
.L29:
	li	a5,161
	sw	a5,-20(s0)
	j	.L43
.L27:
	li	a5,134
	sw	a5,-20(s0)
	j	.L43
.L26:
	li	a5,128
	sw	a5,-20(s0)
	nop
.L43:
	lw	a5,-20(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	hex7seg, .-hex7seg
	.align	2
	.globl	fpga_7seg_print
	.type	fpga_7seg_print, @function
fpga_7seg_print:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a5,-20(s0)
	li	a1,10
	mv	a0,a5
	call	__modsi3
	mv	a5,a0
	li	s1,62922752
	mv	a0,a5
	call	hex7seg
	mv	a5,a0
	sw	a5,0(s1)
	lw	a5,-20(s0)
	li	a1,10
	mv	a0,a5
	call	__divsi3
	mv	a5,a0
	li	a1,10
	mv	a0,a5
	call	__modsi3
	mv	a5,a0
	mv	a4,a5
	li	a5,62922752
	addi	s1,a5,4
	mv	a0,a4
	call	hex7seg
	mv	a5,a0
	sw	a5,0(s1)
	lw	a5,-20(s0)
	li	a1,100
	mv	a0,a5
	call	__divsi3
	mv	a5,a0
	li	a1,10
	mv	a0,a5
	call	__modsi3
	mv	a5,a0
	mv	a4,a5
	li	a5,62922752
	addi	s1,a5,8
	mv	a0,a4
	call	hex7seg
	mv	a5,a0
	sw	a5,0(s1)
	lw	a5,-20(s0)
	li	a1,1000
	mv	a0,a5
	call	__divsi3
	mv	a5,a0
	li	a1,10
	mv	a0,a5
	call	__modsi3
	mv	a5,a0
	mv	a4,a5
	li	a5,62922752
	addi	s1,a5,12
	mv	a0,a4
	call	hex7seg
	mv	a5,a0
	sw	a5,0(s1)
	lw	a4,-20(s0)
	li	a5,8192
	addi	a1,a5,1808
	mv	a0,a4
	call	__divsi3
	mv	a5,a0
	li	a1,10
	mv	a0,a5
	call	__modsi3
	mv	a5,a0
	mv	a4,a5
	li	a5,62922752
	addi	s1,a5,16
	mv	a0,a4
	call	hex7seg
	mv	a5,a0
	sw	a5,0(s1)
	lw	a4,-20(s0)
	li	a5,98304
	addi	a1,a5,1696
	mv	a0,a4
	call	__divsi3
	mv	a5,a0
	li	a1,10
	mv	a0,a5
	call	__modsi3
	mv	a5,a0
	mv	a4,a5
	li	a5,62922752
	addi	s1,a5,20
	mv	a0,a4
	call	hex7seg
	mv	a5,a0
	sw	a5,0(s1)
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	addi	sp,sp,32
	jr	ra
	.size	fpga_7seg_print, .-fpga_7seg_print
	.section	.rodata
	.align	2
.LC1:
	.string	"HELLO FROM CORE 1 THREAD POC ADI 0\n"
	.align	2
.LC2:
	.string	"    "
	.text
	.align	2
	.globl	run_t0
	.type	run_t0, @function
run_t0:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
.L51:
	li	a1,0
	li	a0,30
	call	set_cursor
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	rvc_printf
	sw	zero,-20(s0)
	j	.L47
.L50:
	li	a1,40
	li	a0,30
	call	set_cursor
	lw	a0,-20(s0)
	call	rvc_print_int
	li	a5,62922752
	addi	a5,a5,24
	lw	a4,-20(s0)
	sw	a4,0(a5)
	li	a5,62922752
	addi	a5,a5,36
	lw	a5,0(a5)
	sw	a5,-28(s0)
	li	a1,50
	li	a0,30
	call	set_cursor
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	rvc_printf
	li	a1,50
	li	a0,30
	call	set_cursor
	lw	a0,-28(s0)
	call	rvc_print_int
	lw	a0,-20(s0)
	call	fpga_7seg_print
	sw	zero,-24(s0)
	j	.L48
.L49:
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L48:
	lw	a4,-24(s0)
	li	a5,8192
	addi	a5,a5,1807
	ble	a4,a5,.L49
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L47:
	lw	a4,-20(s0)
	li	a5,98304
	addi	a5,a5,1695
	ble	a4,a5,.L50
	j	.L51
	.size	run_t0, .-run_t0
	.section	.rodata
	.align	2
.LC3:
	.string	"HELLO FROM CORE 1 THREAD 1\n"
	.text
	.align	2
	.globl	run_t1
	.type	run_t1, @function
run_t1:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
.L53:
	li	a1,0
	li	a0,40
	call	set_cursor
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	rvc_printf
	j	.L53
	.size	run_t1, .-run_t1
	.section	.rodata
	.align	2
.LC4:
	.string	"MATRIX 1\n"
	.align	2
.LC5:
	.string	" "
	.align	2
.LC6:
	.string	"\n"
	.align	2
.LC7:
	.string	"\nMATRIX 2\n"
	.globl	__mulsi3
	.align	2
.LC8:
	.string	"\nMATRIX 3\n"
	.align	2
.LC0:
	.word	1
	.word	2
	.word	3
	.word	4
	.word	5
	.word	6
	.word	7
	.word	8
	.word	9
	.text
	.align	2
	.globl	matrix_calc
	.type	matrix_calc, @function
matrix_calc:
	addi	sp,sp,-160
	sw	ra,156(sp)
	sw	s0,152(sp)
	sw	s1,148(sp)
	addi	s0,sp,160
	li	a1,0
	li	a0,70
	call	set_cursor
	lui	a5,%hi(.LC0)
	addi	a5,a5,%lo(.LC0)
	lw	t1,0(a5)
	lw	a7,4(a5)
	lw	a6,8(a5)
	lw	a0,12(a5)
	lw	a1,16(a5)
	lw	a2,20(a5)
	lw	a3,24(a5)
	lw	a4,28(a5)
	lw	a5,32(a5)
	sw	t1,-88(s0)
	sw	a7,-84(s0)
	sw	a6,-80(s0)
	sw	a0,-76(s0)
	sw	a1,-72(s0)
	sw	a2,-68(s0)
	sw	a3,-64(s0)
	sw	a4,-60(s0)
	sw	a5,-56(s0)
	lui	a5,%hi(.LC0)
	addi	a5,a5,%lo(.LC0)
	lw	t1,0(a5)
	lw	a7,4(a5)
	lw	a6,8(a5)
	lw	a0,12(a5)
	lw	a1,16(a5)
	lw	a2,20(a5)
	lw	a3,24(a5)
	lw	a4,28(a5)
	lw	a5,32(a5)
	sw	t1,-124(s0)
	sw	a7,-120(s0)
	sw	a6,-116(s0)
	sw	a0,-112(s0)
	sw	a1,-108(s0)
	sw	a2,-104(s0)
	sw	a3,-100(s0)
	sw	a4,-96(s0)
	sw	a5,-92(s0)
	sw	zero,-160(s0)
	sw	zero,-156(s0)
	sw	zero,-152(s0)
	sw	zero,-148(s0)
	sw	zero,-144(s0)
	sw	zero,-140(s0)
	sw	zero,-136(s0)
	sw	zero,-132(s0)
	sw	zero,-128(s0)
	lui	a5,%hi(.LC4)
	addi	a0,a5,%lo(.LC4)
	call	rvc_printf
	sw	zero,-20(s0)
	j	.L55
.L58:
	sw	zero,-24(s0)
	j	.L56
.L57:
	lw	a4,-20(s0)
	mv	a5,a4
	slli	a5,a5,1
	add	a5,a5,a4
	lw	a4,-24(s0)
	add	a5,a5,a4
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a5,-72(a5)
	mv	a0,a5
	call	rvc_print_int
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	rvc_printf
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L56:
	lw	a4,-24(s0)
	li	a5,2
	ble	a4,a5,.L57
	lui	a5,%hi(.LC6)
	addi	a0,a5,%lo(.LC6)
	call	rvc_printf
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L55:
	lw	a4,-20(s0)
	li	a5,2
	ble	a4,a5,.L58
	lui	a5,%hi(.LC7)
	addi	a0,a5,%lo(.LC7)
	call	rvc_printf
	sw	zero,-28(s0)
	j	.L59
.L62:
	sw	zero,-32(s0)
	j	.L60
.L61:
	lw	a4,-28(s0)
	mv	a5,a4
	slli	a5,a5,1
	add	a5,a5,a4
	lw	a4,-32(s0)
	add	a5,a5,a4
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a5,-108(a5)
	mv	a0,a5
	call	rvc_print_int
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	rvc_printf
	lw	a5,-32(s0)
	addi	a5,a5,1
	sw	a5,-32(s0)
.L60:
	lw	a4,-32(s0)
	li	a5,2
	ble	a4,a5,.L61
	lui	a5,%hi(.LC6)
	addi	a0,a5,%lo(.LC6)
	call	rvc_printf
	lw	a5,-28(s0)
	addi	a5,a5,1
	sw	a5,-28(s0)
.L59:
	lw	a4,-28(s0)
	li	a5,2
	ble	a4,a5,.L62
	sw	zero,-36(s0)
	j	.L63
.L68:
	sw	zero,-40(s0)
	j	.L64
.L67:
	sw	zero,-44(s0)
	j	.L65
.L66:
	lw	a4,-36(s0)
	mv	a5,a4
	slli	a5,a5,1
	add	a5,a5,a4
	lw	a4,-40(s0)
	add	a5,a5,a4
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	s1,-144(a5)
	lw	a4,-36(s0)
	mv	a5,a4
	slli	a5,a5,1
	add	a5,a5,a4
	lw	a4,-44(s0)
	add	a5,a5,a4
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a3,-72(a5)
	lw	a4,-44(s0)
	mv	a5,a4
	slli	a5,a5,1
	add	a5,a5,a4
	lw	a4,-40(s0)
	add	a5,a5,a4
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a5,-108(a5)
	mv	a1,a5
	mv	a0,a3
	call	__mulsi3
	mv	a5,a0
	add	a3,s1,a5
	lw	a4,-36(s0)
	mv	a5,a4
	slli	a5,a5,1
	add	a5,a5,a4
	lw	a4,-40(s0)
	add	a5,a5,a4
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	sw	a3,-144(a5)
	lw	a5,-44(s0)
	addi	a5,a5,1
	sw	a5,-44(s0)
.L65:
	lw	a4,-44(s0)
	li	a5,2
	ble	a4,a5,.L66
	lw	a5,-40(s0)
	addi	a5,a5,1
	sw	a5,-40(s0)
.L64:
	lw	a4,-40(s0)
	li	a5,2
	ble	a4,a5,.L67
	lw	a5,-36(s0)
	addi	a5,a5,1
	sw	a5,-36(s0)
.L63:
	lw	a4,-36(s0)
	li	a5,2
	ble	a4,a5,.L68
	lui	a5,%hi(.LC8)
	addi	a0,a5,%lo(.LC8)
	call	rvc_printf
	sw	zero,-48(s0)
	j	.L69
.L72:
	sw	zero,-52(s0)
	j	.L70
.L71:
	lw	a4,-48(s0)
	mv	a5,a4
	slli	a5,a5,1
	add	a5,a5,a4
	lw	a4,-52(s0)
	add	a5,a5,a4
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a5,-144(a5)
	mv	a0,a5
	call	rvc_print_int
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	rvc_printf
	lw	a5,-52(s0)
	addi	a5,a5,1
	sw	a5,-52(s0)
.L70:
	lw	a4,-52(s0)
	li	a5,2
	ble	a4,a5,.L71
	lui	a5,%hi(.LC6)
	addi	a0,a5,%lo(.LC6)
	call	rvc_printf
	lw	a5,-48(s0)
	addi	a5,a5,1
	sw	a5,-48(s0)
.L69:
	lw	a4,-48(s0)
	li	a5,2
	ble	a4,a5,.L72
	nop
	nop
	lw	ra,156(sp)
	lw	s0,152(sp)
	lw	s1,148(sp)
	addi	sp,sp,160
	jr	ra
	.size	matrix_calc, .-matrix_calc
	.align	2
	.globl	run_count
	.type	run_count, @function
run_count:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	zero,-20(s0)
	j	.L74
.L77:
	lw	a5,-36(s0)
	slli	a5,a5,2
	li	a1,40
	mv	a0,a5
	call	set_cursor
	lw	a0,-20(s0)
	call	rvc_print_int
	sw	zero,-24(s0)
	j	.L75
.L76:
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L75:
	lw	a4,-24(s0)
	li	a5,8192
	addi	a5,a5,1807
	ble	a4,a5,.L76
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L74:
	lw	a4,-20(s0)
	li	a5,1000001536
	addi	a5,a5,-1537
	ble	a4,a5,.L77
.L78:
	j	.L78
	.size	run_count, .-run_count
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a5,12582912
	lw	a5,0(a5)
	sw	a5,-20(s0)
	call	clear_screen
	lw	a4,-20(s0)
	li	a5,6
	beq	a4,a5,.L80
	lw	a4,-20(s0)
	li	a5,6
	bgt	a4,a5,.L81
	lw	a4,-20(s0)
	li	a5,4
	beq	a4,a5,.L82
	lw	a4,-20(s0)
	li	a5,5
	beq	a4,a5,.L83
	j	.L81
.L82:
	call	run_t0
	j	.L84
.L83:
	call	run_t1
	j	.L84
.L80:
	call	matrix_calc
	j	.L80
.L81:
.L85:
	j	.L85
.L84:
	lw	a4,-20(s0)
	li	a5,4
	beq	a4,a5,.L86
.L87:
	j	.L87
.L86:
	li	a5,0
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: (xPack GNU RISC-V Embedded GCC x86_64) 10.2.0"

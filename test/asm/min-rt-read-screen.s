.text
	j	_min_caml_start
rad.157:
	fli	f3, 0.017453293
	fmul	f2, f2, f3
	jr	r31
read_screen_settings.159:
	la	r2, min_caml_screen
	sw	r2, 0(r29)
	sw	r31, -1(r29)
	addi	r29, r29, -2
	jal	min_caml_read_float
	addi	r29, r29, 2
	lw	r31, -1(r29)
	lw	r2, 0(r29)
	swf	f2, 0(r2)
	la	r2, min_caml_screen
	sw	r2, -1(r29)
	sw	r31, -2(r29)
	addi	r29, r29, -3
	jal	min_caml_read_float
	addi	r29, r29, 3
	lw	r31, -2(r29)
	lw	r2, -1(r29)
	swf	f2, 1(r2)
	la	r2, min_caml_screen
	sw	r2, -2(r29)
	sw	r31, -3(r29)
	addi	r29, r29, -4
	jal	min_caml_read_float
	addi	r29, r29, 4
	lw	r31, -3(r29)
	lw	r2, -2(r29)
	swf	f2, 2(r2)
	sw	r31, -3(r29)
	addi	r29, r29, -4
	jal	min_caml_read_float
	addi	r29, r29, 4
	lw	r31, -3(r29)
	sw	r31, -3(r29)
	addi	r29, r29, -4
	jal	rad.157
	addi	r29, r29, 4
	lw	r31, -3(r29)
	swf	f2, -3(r29)
	sw	r31, -4(r29)
	addi	r29, r29, -5
	jal	min_caml_cos
	addi	r29, r29, 5
	lw	r31, -4(r29)
	lwf	f3, -3(r29)
	swf	f2, -4(r29)
	fmove	f2, f3
	sw	r31, -5(r29)
	addi	r29, r29, -6
	jal	min_caml_sin
	addi	r29, r29, 6
	lw	r31, -5(r29)
	swf	f2, -5(r29)
	sw	r31, -6(r29)
	addi	r29, r29, -7
	jal	min_caml_read_float
	addi	r29, r29, 7
	lw	r31, -6(r29)
	sw	r31, -6(r29)
	addi	r29, r29, -7
	jal	rad.157
	addi	r29, r29, 7
	lw	r31, -6(r29)
	swf	f2, -6(r29)
	sw	r31, -7(r29)
	addi	r29, r29, -8
	jal	min_caml_cos
	addi	r29, r29, 8
	lw	r31, -7(r29)
	lwf	f3, -6(r29)
	swf	f2, -7(r29)
	fmove	f2, f3
	sw	r31, -8(r29)
	addi	r29, r29, -9
	jal	min_caml_sin
	addi	r29, r29, 9
	lw	r31, -8(r29)
	la	r2, min_caml_screenz_dir
	lwf	f3, -4(r29)
	fmul	f4, f3, f2
	fli	f5, 200.
	fmul	f4, f4, f5
	swf	f4, 0(r2)
	la	r2, min_caml_screenz_dir
	fli	f4, -200.
	lwf	f5, -5(r29)
	fmul	f4, f5, f4
	swf	f4, 1(r2)
	la	r2, min_caml_screenz_dir
	lwf	f4, -7(r29)
	fmul	f6, f3, f4
	fli	f7, 200.
	fmul	f6, f6, f7
	swf	f6, 2(r2)
	la	r2, min_caml_screenx_dir
	swf	f4, 0(r2)
	la	r2, min_caml_screenx_dir
	fli	f6, 0.
	swf	f6, 1(r2)
	la	r2, min_caml_screenx_dir
	fneg	f6, f2
	swf	f6, 2(r2)
	la	r2, min_caml_screeny_dir
	fneg	f6, f5
	fmul	f2, f6, f2
	swf	f2, 0(r2)
	la	r2, min_caml_screeny_dir
	fneg	f2, f3
	swf	f2, 1(r2)
	la	r2, min_caml_screeny_dir
	fneg	f2, f5
	fmul	f2, f2, f4
	swf	f2, 2(r2)
	la	r2, min_caml_viewpoint
	la	r3, min_caml_screen
	lwf	f2, 0(r3)
	la	r3, min_caml_screenz_dir
	lwf	f3, 0(r3)
	fsub	f2, f2, f3
	swf	f2, 0(r2)
	la	r2, min_caml_viewpoint
	la	r3, min_caml_screen
	lwf	f2, 1(r3)
	la	r3, min_caml_screenz_dir
	lwf	f3, 1(r3)
	fsub	f2, f2, f3
	swf	f2, 1(r2)
	la	r2, min_caml_viewpoint
	la	r3, min_caml_screen
	lwf	f2, 2(r3)
	la	r3, min_caml_screenz_dir
	lwf	f3, 2(r3)
	fsub	f2, f2, f3
	swf	f2, 2(r2)
	jr	r31
dump_screen.161:
	la	r2, min_caml_screen
	lwf	f2, 0(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_screen
	lwf	f2, 1(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_screen
	lwf	f2, 2(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_screenz_dir
	lwf	f2, 0(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_screenz_dir
	lwf	f2, 1(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_screenz_dir
	lwf	f2, 2(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_screenx_dir
	lwf	f2, 0(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_screenx_dir
	lwf	f2, 1(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_screenx_dir
	lwf	f2, 2(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_screeny_dir
	lwf	f2, 0(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_screeny_dir
	lwf	f2, 1(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_screeny_dir
	lwf	f2, 2(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_viewpoint
	lwf	f2, 0(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_viewpoint
	lwf	f2, 1(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	la	r2, min_caml_viewpoint
	lwf	f2, 2(r2)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	min_caml_dump_float
	addi	r29, r29, 1
	lw	r31, 0(r29)
	jr	r31
_min_caml_start: # main entry point
   # main program start
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	read_screen_settings.159
	addi	r29, r29, 1
	lw	r31, 0(r29)
	sw	r31, 0(r29)
	addi	r29, r29, -1
	jal	dump_screen.161
	addi	r29, r29, 1
	lw	r31, 0(r29)
   # main program end
   break
	halt

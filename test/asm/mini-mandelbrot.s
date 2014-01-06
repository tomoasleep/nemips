.text
	j	_min_caml_start
dbl.38:
	fadd	f2, f2, f2
	jr	r31
iloop.52:
	li	r3, 0
	bne	r2, r3, beq_else.131
	li	r2, 1
	j	min_caml_print_int
beq_else.131:
	fsub	f4, f4, f5
	fadd	f4, f4, f6
	swf	f6, 0(r29)
	sw	r2, -1(r29)
	swf	f4, -2(r29)
	swf	f7, -3(r29)
	swf	f3, -4(r29)
	sw	r31, -5(r29)
	addi	r29, r29, -6
	jal	dbl.38
	addi	r29, r29, 6
	lw	r31, -5(r29)
	lwf	f3, -4(r29)
	fmul	f2, f2, f3
	lwf	f7, -3(r29)
	fadd	f3, f2, f7
	lwf	f2, -2(r29)
	fmul	f4, f2, f2
	fmul	f5, f3, f3
	fadd	f6, f4, f5
	fli	f8, 4.
	fbgt	f6, f8, fble_else.132
	lw	r2, -1(r29)
	addi	r2, r2, -1
	lwf	f6, 0(r29)
	j	iloop.52
fble_else.132:
	li	r2, 0
	j	min_caml_print_int
xloop.43:
	lwf	f2, 11(r28)
	lwf	f3, 6(r28)
	lw	r4, 1(r28)
	bgt	r4, r2, ble_else.133
	jr	r31
ble_else.133:
	sw	r28, 0(r29)
	sw	r2, -1(r29)
	swf	f2, -2(r29)
	sw	r3, -3(r29)
	swf	f3, -4(r29)
	sw	r31, -5(r29)
	addi	r29, r29, -6
	jal	min_caml_float_of_int
	addi	r29, r29, 6
	lw	r31, -5(r29)
	sw	r31, -5(r29)
	addi	r29, r29, -6
	jal	dbl.38
	addi	r29, r29, 6
	lw	r31, -5(r29)
	lwf	f3, -4(r29)
	fdiv	f2, f2, f3
	fli	f3, 1.5
	fsub	f2, f2, f3
	lw	r2, -3(r29)
	swf	f2, -5(r29)
	sw	r31, -6(r29)
	addi	r29, r29, -7
	jal	min_caml_float_of_int
	addi	r29, r29, 7
	lw	r31, -6(r29)
	sw	r31, -6(r29)
	addi	r29, r29, -7
	jal	dbl.38
	addi	r29, r29, 7
	lw	r31, -6(r29)
	lwf	f3, -2(r29)
	fdiv	f2, f2, f3
	fli	f3, 1.
	fsub	f7, f2, f3
	li	r2, 10
	fli	f2, 0.
	fli	f3, 0.
	fli	f4, 0.
	fli	f5, 0.
	lwf	f6, -5(r29)
	sw	r31, -6(r29)
	addi	r29, r29, -7
	jal	iloop.52
	addi	r29, r29, 7
	lw	r31, -6(r29)
	lw	r2, -1(r29)
	addi	r2, r2, 1
	lw	r3, -3(r29)
	lw	r28, 0(r29)
	lw	r1, 0(r28)
	jr	r1
yloop.40:
	lwf	f2, 8(r28) # y_float
	lw	r3, 7(r28) # y_int
	lwf	f3, 6(r28) # x_float
	lw	r4, 1(r28) # x_int
	bgt	r3, r2, ble_else.135 # if y_int > idx
	jr	r31
ble_else.135:
	move	r3, r30
	addi	r30, r30, 16 # allocate
	la	r5, xloop.43

	sw	r5, 0(r3) # jump point
	swf	f2, 11(r3) # y_float
	swf	f3, 6(r3) # x_float
	sw	r4, 1(r3) # x_int
	li	r4, 0 # x_idx
	sw	r28, 0(r29) # heap base
	sw	r2, -1(r29) # y_idx
	move	r28, r3
	move	r3, r2
	move	r2, r4
	sw	r31, -2(r29)
	addi	r29, r29, -3
	lw	r1, 0(r28)
	jalr	r1
	addi	r29, r29, 3
	lw	r31, -2(r29)
	lw	r2, -1(r29)
	addi	r2, r2, 1
	lw	r28, 0(r29)
	lw	r1, 0(r28)
	jr	r1
_min_caml_start: # main entry point
   # main program start
   # set x and y lengthes
	li	r2, 2
	li	r3, 2

	sw	r2, 0(r29)
	sw	r3, -1(r29)
	sw	r31, -2(r29)
	addi	r29, r29, -3

   # convert int r2 to float f2 (x?)
	jal	min_caml_float_of_int

	addi	r29, r29, 3
	lw	r31, -2(r29)
	lw	r2, -1(r29)

	swf	f2, -2(r29)
	sw	r31, -3(r29)
	addi	r29, r29, -4

   # convert int r3 to float f3 (y?)
	jal	min_caml_float_of_int

	addi	r29, r29, 4
	lw	r31, -3(r29)

	move	r28, r30 # heap zero
	addi	r30, r30, 13 # memory allocate
	la	r2, yloop.40

	sw	r2, 0(r28)  # yloop.40
	swf	f2, 8(r28)  # y_float

	lw	r2, -1(r29) # y_int
	sw	r2, 7(r28)  # y_int

	lwf	f2, -2(r29) # x_float
	swf	f2, 6(r28)  # x_float

	lw	r2, 0(r29)  # x_int
	sw	r2, 1(r28)  # x_int

	li	r2, 0 # y_idx

	sw	r31, -3(r29)
	addi	r29, r29, -4

	lw	r1, 0(r28) # yloop.40
	jalr	r1

	addi	r29, r29, 4
	lw	r31, -3(r29)
   # main program end
  break
	halt

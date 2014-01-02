.data
jump_code:
.int 0x03e00008 # 000000 11111 00000 00000 00000 001000
program_start: # program rom address of loaded program start
.int 0x100
program_eof: # program end sign of io
.int -1
jump_op_funct:
.int 0x08000000
jump_funct_mask:
.int -134217728 # 0xf8000000
.text
bootloader:
  ld r10, program_start
  ld r9, program_eof
  ld r8, program_start
# bit mask of jump funct
  ld r7, jump_funct_mask
  ld r6, jump_op_funct
# write 'jr r31' at 'program_start'
write_empty_program:
  ld r3, jump_code
  sprogram r3, 0(r8)
loop:
  nop
load_program:
  iw r3
  beq r3, r9, boot_program
  xor r4, r3, r6
  and r4, r4, r7
  bne r4, r0, write_program
# add address operand by 'program_start'
# when this instruciton is j or jal
add_pc:
  add r3, r3, r10
write_program:
  sprogram r3, 0(r8)
  addi r8, r8, 1
  j loop
boot_program:
  jalr r10
  jr r0 # reload initializer(at address 0)
  halt


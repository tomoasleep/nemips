.data
program_start:
.int 0x400
program_eof:
.int -1
jump_op_funct:
.int 0x08000000
jump_funct_mask:
.int -134217728 # 0xf8000000
.text
bootloader:
  la r10, program_start
  la r9, program_eof
  la r8, program_start
# bit mask of jump funct
  la r7, jump_funct_mask
  la r6, jump_op_funct
  srl r5, r10, 2
loop:
  nop
load_program:
  iw r3
  beq r3, r9, boot_program
  xor r4, r3, r6
  and r4, r4, r7
  bne r4, r0, write_program
add_pc:
  add r3, r3, r5
write_program:
  sprogram r3, 0(r8)
  addi r8, r8, 4
  j loop
boot_program:
  jalr r10
  j bootloader
  halt


.data
jump_code:
.int 0x03e00008 # 000000 11111 00000 00000 00000 001000
bootloader_start: # program rom address of bootloader_start
.int 924
program_eof: # program end sign of io
.int -1
.text
bootloader:
  ld r10, bootloader_start
  ld r9, program_eof
  li r8, 0
# write 'jr r31' at 'program_start'
write_empty_program:
  ld r3, jump_code
  sprogram r3, 0(r0)
loop:
  nop
  iw r3
  beq r3, r9, boot_program
write_program:
  sprogram r3, 0(r8)
  addi r8, r8, 1
  beq r0, r0, loop
boot_program:
  jalr r0
  jr r10 # reload initializer
  halt


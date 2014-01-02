.text
# don't use jump label and label load
bootloader:
  li r9, -1
  li r8, 0
# write 'jr r31' at 'program_start'
write_empty_program:
  lui r3, 0x03e0
  ori r3, r3, 0x0008 # 000000 11111 00000 00000 00000 001000
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
  beq r0, r0, bootloader # reload initializer
  halt


.text
main:
  li r1, 12
  sw r1, 20(r0)
  li r1, 8
  lw r1, 12(r1)
output:
  ow r1
  j output

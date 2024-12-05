.data
vetor: .word 1, 2, 3, 4, 5, 6, 7, 8, 9
new_line: .asciiz "\n"

.text

  la $s0, vetor
  addi $s1, $zero, 9

for_i:
  lw $t0, 0($s0)
  slti $t1, $t0, 7
  beq $t1, $zero, print_int_t0
  j increment_vetor_address

print_int_t0:
  li $v0, 1
  add $a0, $t0, $zero
  syscall

print_new_line:
  li $v0, 4
  la $a0, new_line
  syscall

increment_vetor_address:
  addi $s0, $s0, 4

decrement_index_vector:
  addi $s1, $s1, -1

end_condition_for_i:
  bne $s1, $zero, for_i

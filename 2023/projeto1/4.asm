.data
vetor: .word 1, 2, 3, 4, 5, 6, 7, 8, 9
size: .word 2
finded_item_string: .asciiz "Encontrado na posição "
not_finded_item_string: .asciiz "Número não encontrado"
new_line: .asciiz "\n"

.text
j show_not_finded

load_vetor:
  la $s0, vetor
  la $s1, size

for_$t0_less_then_0_insert_$s0:
  read_int_$t0:
    li $v0, 5
    syscall
    add $t0, $v0, $zero

  write_vector_in_$s0:
    sw $t0, ($s0)

  increment_vetor_address:
    addi $s0, $s0, 4

  decrement_index_vector:
    addi $s1, $s1, -1

  end_condition_for_i:
    bne $s1, $zero, for_$t0_less_then_0_insert_$s0

read_int_$t2_to_find_in_vetor:
  li $v0, 5
  syscall
  add $t2, $v0, $zero

load_vetor_to_find_in_vector:
  la $s0, vetor
  addi $s1, $zero, 9

for_i:
  lw $t0, ($s0)
  slt $t1, $t0, $t2
  slt $t3, $t2, $t0
  beq $t1, $t3, print_finded_item_string
  j increment_vetor_address_string_find

print_finded_item_string:
  li $v0, 4
  lw $a0, finded_item_string
  syscall

print_int_value_position:
  li $v0, 1
  addi $a0, $t0, 0
  syscall

print_new_line:
  lw $a0, new_line
  syscall
  j exit

increment_vetor_address_string_find:
  addi $s0, $s0, 4

decrement_index_vector_string_find:
  addi $s1, $s1, -1

end_condition_for_i_string_find:
  bne $s1, $zero, for_i

show_not_finded:
  li $v0, 4
  lw $a0, not_finded_item_string
  syscall

exit:
  li $v0, 10
  syscall

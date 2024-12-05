.data
  vetor: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  size: .word 10

  finded_item_string: .asciiz "Encontrado na posição "
  not_finded_item_string: .asciiz "Número não encontrado"
  new_line: .asciiz "\n"

.text


load_vetor:
  la $s0, vetor

load_size_vetor:
  la $s1, size
  lw $t9, ($s1)

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
    addi $t9, $t9, -1

  end_condition_for_i:
    bne $t9, $zero, for_$t0_less_then_0_insert_$s0

read_int_$t2_to_find_in_vetor:
  li $v0, 5
  syscall
  add $t2, $v0, $zero

load_vetor_to_find_in_vector:
  la $s0, vetor
  la $s1, size
  lw $t9, ($s1)
  add $t8, $zero, $zero

for_i:
  lw $t0, ($s0)
  slt $t1, $t0, $t2
  slt $t3, $t2, $t0
  bne $t1, $t3, increment_vetor_address_string_find

print_finded_item_string:
  li $v0, 4
  la $a0, finded_item_string
  syscall

print_int_value_position:
  li $v0, 1
  add $a0, $t8, $zero
  syscall

print_new_line:
  li $v0, 4
  la $a0, new_line
  syscall
  j exit

increment_vetor_address_string_find:
  addi $s0, $s0, 4

decrement_index_vector_string_find:
  addi $t8, $t8, 1

end_condition_for_i_string_find:
  bne $t8, $t9, for_i

show_not_finded:
  li $v0, 4
  la $a0, not_finded_item_string
  syscall

exit:
  li $v0, 10
  syscall

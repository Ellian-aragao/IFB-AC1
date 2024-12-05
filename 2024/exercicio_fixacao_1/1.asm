initialize:
  addi $t1, $zero, 1
  addi $t2, $zero, 2
  addi $t3, $zero, 3

sum_n2_n3:
  add $t4, $t2, $t3

sub_n1_result_n2_n3_sum:
  sub $t4, $t4, $t1

show_result_value:
  li $v0, 1
  add $a0, $t4, $zero
  syscall

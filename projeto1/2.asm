initialize_n1:
li $v0, 5
syscall
add $t1, $zero, $v0

initialize_n2:
li $v0, 5
syscall
add $t2, $zero, $v0

initialize_n3:
li $v0, 5
syscall
add $t3, $zero, $v0

sum_n2_n3:
add $t4, $t2, $t3

sub_n1_result_n2_n3_sum:
sub $t4, $t4, $t1

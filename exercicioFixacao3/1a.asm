if (a < b){
	a++;
}

main:
	lw $t0 $s0 # carrega valor a
	lw $t1 $s1 # carrega valor b
	lw $t2 $s2 # carrega valor c

	slt $t3 $t1 $t0    # b < a ? 1 : 0
	beq $t3 $zero exit # pula pro final se a < b
	addi $t0 $t0 1     # a++
	
	sw $s0 $t0         # salva valor a

exit:

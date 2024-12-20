.data
vetor: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

.text

la $a0, vetor
li $a1, 0
li $a2, 10
li $a3, 1
jal busca_binaria
j exit

busca_binaria:
  addi $sp, $sp, -4  # cria elemento na pilha
  sw $ra, 0($sp)       # endereço de retorno

  # VERIFICA SE INDICES SÃO VÁLIDOS
  slt $t5, $a2, $a1 # offset final < offset inicial ? 1 : 0
  bne $t5, $zero, nao_encontrado 

  # CORPO FUNÇÃO DA BUSCA BINÁRIA
  srl $t0, $a2, 1       # índice do meio do vetor | offset final / 2
  sll $t1, $t0, 2       # índice do meio do vetor * 4 bytes
  add $t1, $t1, $a0     # offset do endereço do elemento do meio do vetor
  lw  $t3, ($t1)        # carrega valor do elemento do meio do vetor
  beq $a3, $t3, conclui # elemento do meio = elemento buscado => conclui
  slt $t4, $t3, $a3     # elemento do meio < valor procurado ? 1 : 0
  bne $t4, $zero, busca_binaria_direita # elemento do meio > valor procurado => busca no lado direito do vetor

  busca_binaria_esquerda:
    add $a2, $t0, $zero   # offset final = índice do meio do vetor
    jal busca_binaria     # executa busca binária recursiva
    j remove_pilha_e_retorna

  busca_binaria_direita:
    add $a1, $t0, $zero   # offset inicial = índice do meio do vetor
    jal busca_binaria     # executa busca binária recursiva
    j remove_pilha_e_retorna

  conclui:
    add $v0, $t0, $zero   # índice do elemento como retorno
    j remove_pilha_e_retorna

  nao_encontrado:
    addi $v0, $zero, -1  # elemento não encontrado

  remove_pilha_e_retorna:
    lw $ra, 0($sp)    # carrega endereço de retorno da pilha
    addi $sp, $sp, 4  # remove item da pilha
    jr $ra            # retorna pro último procedimento chamado

exit:
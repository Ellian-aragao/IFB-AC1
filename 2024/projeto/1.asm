.data
vetor: .word 1, 2, 3, 4, 5, 6, 7, 8, 9
new_line: .asciiz "\n"

.text

busca_binaria:
  addi $sp, $zero, -4
  sw $ra, $sp # endereço de retorno

  # VERIFICA SE INDICES SÃO VÁLIDOS
  slt $t5, $a2, $a1 # offset final < offset inicial ? 1 : 0
  bne $t5, $zero, nao_encontrado 

  # CORPO FUNÇÃO DA BUSCA BINÁRIA
  srl $t0, $a2, 1       # índice do meio do vetor | offset final / 2
  add $t1, $t0, $a0     # offset do endereço do elemento do meio do vetor
  lw  $t3, $t1          # carrega valor do elemento do meio do vetor
  beq $a3, $t3, conclui # elemento do meio = elemento buscado => conclui
  slt $t4, $a3, $t3     # elemento do meio < valor procurado ? 1 : 0
  bne $t4, $zero, busca_binaria_direita # elemento do meio > valor procurado => busca no lado direito do vetor


  busca_binaria_esquerda:
    add $a2, $t0, $zero   # offset final = índice do meio do vetor
    jal busca_binaria     # executa busca binária recursiva

  busca_binaria_direita:
    add $a1, $t0, $zero   # offset inicial = índice do meio do vetor
    jal busca_binaria     # executa busca binária recursiva

  conclui:
    addi $v0, $t0, $zero # índice do elemento como retorno
    j remove_pilha_e_retorna

  nao_encontrado:
    addi $v0, $zero, -1  # elemento não encontrado

  remove_pilha_e_retorna:
    lw $ra, $sp       # carrega endereço de retorno da pilha
    addi $sp, $sp, 4  # remove item da pilha
    jr $ra            # retorna pro último procedimento chamado

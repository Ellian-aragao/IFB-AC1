.data
vetor: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

.text

main: 
  la $a0, vetor        # argumento de endereço do vetor
  addi $a1, $zero, 0   # argumento de índice inicial do vetor
  addi $a2, $zero, 10  # argumento de índice final do vetor
  addi $a3, $zero, 4   # argumento de elemento a ser buscado
  jal busca_binaria    # chama função de busca binária
  add $a0, $v0, $zero  # carrega resultado da busca para print
  jal print_integer    # chama função de print do resultado
  j exit               # chama procedimento de finalização

busca_binaria:

  salva_endereco_retorno:
    addi $sp, $sp, -4  # cria elemento na pilha
    sw $ra, 0($sp)     # salva endereço de retorno da chamada na pilha

  verifica_indice_igual:
    beq $a1, $a2, nao_encontrado    # chama procedimento de retorno não encontrado
  
  verifica_indice_menor:
    slt $t5, $a2, $a1               # offset final < offset inicial ? 1 : 0
    bne $t5, $zero, nao_encontrado  # 0 => chama procedimento de retorno não encontrado

  divide_indice_mais_um:
    srl $t0, $a2, 1                # índice do meio = offset final / 2
    andi $t6, $a2, 1               # eh_impar = índice meio % 2
    beq $t6, $a2, carrega_indice   # eh_impar == indice meio => carrega_indice
    add $t0, $t0, $t6              # índice meio += eh_impar

  carrega_indice:
    sll $t1, $t0, 2       # índice do meio do vetor * 4 bytes
    add $t1, $t1, $a0     # offset do endereço do elemento do meio do vetor
    lw  $t3, 0($t1)       # carrega valor do elemento do meio do vetor

  verifica_elemento_encontrado:
    beq $a3, $t3, conclui # elemento do meio = elemento buscado => conclui

  verifica_lado_busca:
    slt $t4, $t3, $a3     # elemento do meio < valor procurado ? 1 : 0
    bne $t4, $zero, busca_binaria_direita # elemento do meio > valor procurado => busca no lado direito do vetor

  busca_binaria_esquerda:
    add $a2, $t0, $zero   # offset final = índice do meio do vetor
    jal busca_binaria     # executa busca binária recursiva
    j remove_pilha        # chama procedimento de remove pilha

  busca_binaria_direita:
    add $a1, $t0, $zero   # offset inicial = índice do meio do vetor
    jal busca_binaria     # executa busca binária recursiva
    j remove_pilha        # chama procedimento de remove pilha

  conclui:
    add $v0, $t0, $zero   # índice do elemento como retorno
    j remove_pilha        # chama procedimento de remove pilha

  nao_encontrado:
    addi $v0, $zero, -1  # retorno da função: elemento não encontrado

  remove_pilha:
    lw $ra, 0($sp)       # carrega endereço de retorno da pilha
    addi $sp, $sp, 4     # remove item da pilha
  
  return:
    jr $ra           # retorna para ultima instrução a chamar a função

print_integer:
  addi $v0, $zero, 1 # identificador de print integer para syscall
  syscall            # exibe valor do argumento $a0 da chamada
  jr $ra             # retorna para ultima instrução a chamar a função

exit:
  addi $v0, $zero, 10  # carrega como argumento a chamada exit
  syscall              # finaliza o programa

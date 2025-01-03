.data
  erro_le_arquivo_str: .asciiz "Erro ao ler arquivo"
  erro_abrir_arquivo:  .asciiz "Erro ao abrir arquivo"
  nome_arquivo:        .asciiz "/Users/ellian/code/faculdade/IFB-AC1/2024/projeto/sample/t2.txt"
  espacamento:         .asciiz " -> "
  quebra_linha:        .asciiz "\n"

  buffer:              .space 512  # buffer para armazenar o conteúdo do arquivo
  buffer_ano:          .space  40  # buffer para armazenar o ano do arquivo
  buffer_read_line:    .space 200  # buffer para armazenar linha lida 

  size_buffer:         .word 64 # quantidade de caracteres que o buffer suporta
  size_buffer_line:    .word 25 # quantidade de caracteres que o buffer suporta
  size_ano:            .word 4  # quantidade de caracteres para ano
  size_ignore:         .word 4  # quantidade de caracteres para ignorar informação

.text

main:
  la $a0, nome_arquivo      # carrega path arquivo
  jal abre_arquivo_leitura  # chama função de abrir arquivo
  add $s0, $v0, $zero       # salva descritor de arquivo

  li $s4, 0                 # inicializa somador
  li $s5, 0                 # inicializa flag de print

  loop_buffer:
    add $a0, $s0, $zero                      # configura descritor do arquivo como argumento
    la $a1, buffer                           # configura buffer de leitura

    processo_ler_arquivo:
      calcula_quantos_caracteres_o_buffer_deve_ler:
        la $t0, size_buffer                    # carrega endereço tamanho do buffer
        lw $t0, ($t0)                          # carrega valor do endereço do tamanho do buffer
        add $a2, $t0, $zero                    # configura numero de caracteres para leitura

      le_arquivo_e_finaliza_se_eof:
        jal le_arquivo                           # chama leitura de arquivo
        beq $v0, $zero, valida_se_fecha_arquivo_e_finaliza # leitura == EOF => fecha arquivo e finaliza execução

      verifica_erro_na_leitura_do_arquivo:
        slt $t0, $v0, $zero              # retorno leitura arquivo < 0 ? 1 : 0
        bne $t0, $zero, erro_le_arquivo  # retorno leitura arquivo < 0 => encerra processo com erro


    la $s3, buffer                       # carrega buffer para copiar

    loop_interpreta_linha:
      busca_quebra_de_linha:
        move $a0, $s3                    # configura buffer de busca da string
        li $a1, 10                       # configura char (nova linha) para buscar na string
        jal strchr                       # chama procedimento de busca de char
        move $s1, $v0                    # salva resultado da função
        beq $v0, $zero, loop_buffer      # volta para loop do buffer

      copia_linha_para_buffer:
        la $a0, buffer_read_line         # carrega buffer para escrita
        move $a1, $s3                    # carrega buffer para copiar
        move $a2, $s1                    # salva resultado da função strchr como argumento memcpy
        jal memcpy                       # chama procedimento de cópia de buffer

      escreve_null_final_string:
        addi $t0, $s1, 1                 # offset resultado strchr + 1
        la $t1, buffer_read_line         # carrega endereço buffer para escrita
        add $t0, $t0, $t1                # t0 += endereço do buffer => endereço do próximo elemento da string
        sb $zero, 0($t0)                 # escreve '\0' no ultimo caractere do string

      varifica_buffer_ano_vazio:
        la $t0, buffer_ano                # carrega endereço buffer do ano
        lb $t0, 0($t0)                    # carrega valor do endereço buffer do ano
        bne $t0, $zero, interpretar_linha_loop            # *buffer_ano != '\0' => pula para interpretação da linha
        jal escreve_ano_do_buffer_read_line_no_buffer_ano # *buffer_ano == '\0' => chama procedimento para escrita no buffer_ano
        li $s6, 1                         # flag para indicar que não foi printado

      interpretar_linha_loop:
        jal interpreter_line             # chama procedimento de interpretação da string
        move $s5, $v1                    # salva retorno do valor inteiro no $s5
        or $s6, $s6, $v0                # flag = flag | ano diferente
        # se v0 != 0 => ano diferente
        beq $v0, $zero, calcula_offset_atual_e_volta_loop # ano igual => calcula próximo endereço
        # ano diferente => print informações

      print_informacoes:
        la $a0, buffer_ano               # carrega endereço buffer do ano
        jal print_string                 # chama procedimento de print da string

        la $a0, espacamento              # carrega endereço buffer de espaçamento
        jal print_string                 # chama procedimento de print da string

        move $a0, $s4                    # carrega valor do somatório
        jal print_integer                # chama procedimento de print do inteiro

        la $a0, quebra_linha             # carrega endereço buffer da quebra de linha
        jal print_string                 # chama procedimento de print da string

        li $s6, 0                        # flag para indicar se foi printado

      atualiza_valores_contador_buffer_ano:
        li $s4, 0                        # reinicializa somador
        jal escreve_ano_do_buffer_read_line_no_buffer_ano # chama procedimento para escrita no buffer_ano

      calcula_offset_atual_e_volta_loop:
        add $s4, $s4, $s5               # s4 += retorno da interpretação
        add $s3, $s3, $s1               # buffer += offset strchr(buffer) => última linha do buffer '\0'
        addi $s3, $s3, 1                # buffer += buffer + 1
        j loop_interpreta_linha         # loop para próxima linha

  valida_se_fecha_arquivo_e_finaliza:
    la $a0, buffer_ano               # carrega endereço buffer do ano
    jal print_string                 # chama procedimento de print da string

    la $a0, espacamento              # carrega endereço buffer de espaçamento
    jal print_string                 # chama procedimento de print da string

    move $a0, $s4                    # carrega valor do somatório
    jal print_integer                # chama procedimento de print do inteiro

    la $a0, quebra_linha             # carrega endereço buffer da quebra de linha
    jal print_string                 # chama procedimento de print da string

  fecha_arquivo_e_finaliza:
    add $a0, $s0, $zero            # configura descritor como argumento do fechamento de arquivo
    addi $v0, $zero, 16            # configura syscall de fechamento de arquivo
    syscall                        # fecha arquivo
    j exit_success                 # finaliza execução do programa


# Functions

# int strchr (const char *str, const char arg1)
strchr:
  li $v0, 0            # inicializa contador com zero

  while_find_char:
    lb $t0, 0($a0)               # carrega byte do argumento str

    beq $t0, '\0', strchr_return # caractere == '\0' => break
    beq $t0, $a1, strchr_return  # caractere == arg1 => break

    addi $a0, $a0, 1             # endereço próximo caractere
    addi $v0, $v0, 1             # incrementa contador

    j while_find_char

  strchr_return:
    jr $ra

# int memcmp ( const void * p1, const void * p2, size_t num ) p1 > p2 => 1 | p1 == p2 => 0 | p1 < p2 => -1
memcmp:
  add $t2, $zero, $zero         # inicializa contador

  while_memcmp:
    lb $t0, 0($a0)       # carrega primeiro byte do argumento a0
    lb $t1, 0($a1)       # carrega primeiro byte do argumento a1

    # incrementa endereco string
    addi $a0, $a0, 1   # endereço próximo caractere
    addi $a1, $a1, 1   # endereço próximo caractere

    addi $t2, $t2, 1   # incrementa contador
    beq $t2, $a2, retorna_subtracao_memcmp
    beq $t0, $t1, while_memcmp # *p1 == *p2 => while_strcmp

  retorna_subtracao_memcmp:
    subu $v0, $t0, $t1  # v0 = t0 - t1
    jr $ra              # retorna para ultima instrução a chamar a função

# void memcpy(void *dest_str, const void * src_str, size_t n)
memcpy:
  addiu $t0, $zero, 1         # inicializa contador

  for_memcpy:
    lb $t1, 0($a1)            # carrega primeiro byte do argumento a0
    sb $t1, 0($a0)            # *dest_str = *src_str

    incrementa_endereco_memoria:
      addi $a0, $a0, 1        # endereço próximo caractere
      addi $a1, $a1, 1        # endereço próximo caractere

    beq $t0, $a2, end_memcpy  # valida se copiou todos os bytes
    addiu $t0, $t0, 1         # incrementa contador
    j for_memcpy              # retorna no for_memcpy

  end_memcpy:
    jr $ra                    # retorna para ultima instrução a chamar a função

# int atoi (const char * str)
atoi:
  add $v0, $zero, $zero  # inicializa o resultado com zero
  addi $t3, $zero, 10    # inicializa o offset decimal
  li $t2, '9'            # inicializa t2 = '9'

  while_atoi:
    lb $t0, 0($a0)       # carrega primeiro byte do argumento a0

    verifica_fim_numero:
      beq $t0, '\0', retorna_atoi # caractere '\0' => break
      beq $t0, '\n', retorna_atoi # caractere '\n' => break

    verifica_limites_numeros:
      slti $t1, $t0, '0'       # caracter < '0' ? 1 : 0
      beq $t1, 1, retorna_atoi # caracter < '0' => break
      slt $t1, $t2, $t0        # caracter < '9' ? 1 : 0
      beq $t1, 1, retorna_atoi # caracter < '9' => break

    subi $t1, $t0, '0'         # valor inteiro = char - offset do '0'
    mul $v0, $v0, $t3          # retorno = retorno * 10
    add $v0, $v0, $t1          # resultado += valor inteiro

    addi $a0, $a0, 1     # endereço próximo caractere
    j while_atoi         # volta ao loop while

  retorna_atoi:
    jr $ra              # retorna para ultima instrução a chamar a função

# ($v0 != 0 => ano diferente, $v1 = valor inteiro processado) interpreter_line ()
interpreter_line:
  empilha_dados:
    addi $sp, $sp, -12       # ajusta offset da pilha
    sw $s0, 8($sp)           # empilha dados dos registradores
    sw $s1, 4($sp)           # empilha dados dos registradores
    sw $ra, 0($sp)           # empilha dados dos registradores

  carrega_variaveis:
    la $s0, buffer_read_line  # carrega endereço do buffer da linha
    la $t0, buffer_ano        # carrega endereço do buffer do ano
    la $s1, size_ano          # carrega endereço do size_ano
    lw $s1, 0($s1)            # carrega valor do endereço size_ano

  compara_tamanho_ano_com_buffer_ano:
    move $a0, $s0             # carrega endereço do buffer da linha
    move $a1, $t0             # carrega endereço do buffer do ano
    move $a2, $s1             # carrega endereço do size_ano
    jal memcmp                # chama procedimento de comparação de buffers
    move $t4, $v0             # salva retorno memcmp em t4

  obtem_valor_inteiro_str:
    la $t3, size_ignore       # carrega endereço do size_ignore
    lw $t3, 0($t3)            # carrega valor do endereço size_ignore
    add $t3, $s1, $t3         # t3 = size_ano + size_ignore
    add $a0, $s0, $t3         # t3 = offset ignore + &buffer_read_line
    jal atoi                  # chama procedimento de conversão str para int

  configura_retornos:
    move $v1, $v0             # coloca o resultado de atoi no 2 retorno
    move $v0, $t4             # coloca o resultado de memcmp no 1 retorno

  desempilha_dados_e_retorna:
    lw $s0, 8($sp)            # desempilha dados dos registradores
    lw $s1, 4($sp)            # desempilha dados dos registradores
    lw $ra, 0($sp)            # desempilha dados dos registradores
    addi $sp, $sp, 12         # ajusta offset da pilha
    jr $ra                    # retorna para instrução que chamou procedimento

escreve_ano_do_buffer_read_line_no_buffer_ano:
  addi $sp, $sp, -4          # ajusta offset da pilha
  sw $ra, 0($sp)             # empilha dados dos registradores

  la $a0, buffer_ano         # carrega endereço buffer do ano
  la $a1, buffer_read_line   # carrega endereço buffer da linha
  la $a2, size_ano           # carrega endereço tamanho do buffer
  lw $a2, ($a2)              # carrega valor do endereço do tamanho do buffer do ano
  jal memcpy                 # chama procedimento de cópia da string ano
  la $t0, buffer_ano         # carrega endereço buffer do ano
  sb $zero, 32($t0)          # escreve '\0' no ultimo elemento do buffer

  lw $ra, 0($sp)             # desempilha dados dos registradores
  addi $sp, $sp, 4           # ajusta offset da pilha
  jr $ra                     # retorna para instrução que chamou procedimento

abre_arquivo_leitura:
  addi $v0, $zero, 13   # código para abrir arquivo
  addi $a1, $zero, 0    # seleciona flag de read-only
  addi $a2, $zero, 0    # seleciona modo zero
  syscall               # abre arquivo com descritor em $v0
  slt $t0, $v0, $zero   # descritor < 0 ? 1 : 0
  bne $t0, $zero, erro_abre_arquivo_leitura  # descritor < 0 => erro_abre_arquivo_leitura
  jr $ra                # retorna para instrução que chamou procedimento

print_string:
  addi $v0, $zero, 4 # identificador de print integer para syscall
  syscall            # exibe valor do argumento $a0 da chamada
  jr $ra             # retorna para ultima instrução a chamar a função

print_integer:
  addi $v0, $zero, 1 # identificador de print integer para syscall
  syscall            # exibe valor do argumento $a0 da chamada
  jr $ra             # retorna para ultima instrução a chamar a função

le_arquivo:
  addi $v0, $zero, 14 # identificador de leitura de arquivo para syscall
  syscall             # escreve texto lido no buffer $a1 e indicador de sucesso $v0
  jr $ra              # retorna para ultima instrução a chamar a função

# Error handling

erro_le_arquivo:
  la $a0, erro_le_arquivo_str  # carrega string erro ler arquivo
  jal print_string             # chama print string
  j exit_error                 # finaliza execução

erro_abre_arquivo_leitura:
  la $a0, erro_abrir_arquivo # carrega string erro abrir arquivo
  jal print_string           # chama print string
  j exit_error               # finaliza execução

# Exit functions

exit_error:
  addi $v0, $zero, 17   # carrega como argumento a chamada exit
  addi $a0, $zero, -1   # carrega valor 1 como retorno da chamada exit
  syscall               # finaliza o programa

exit_success:
  addi $v0, $zero, 17     # carrega como argumento a chamada exit
  add $a0, $zero, $zero   # carrega valor 0 como retorno da chamada exit
  syscall                 # finaliza o programa

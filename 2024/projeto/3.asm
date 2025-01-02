.data
  erro_le_arquivo_str: .asciiz "Erro ao ler arquivo"
  erro_abrir_arquivo:  .asciiz "Erro ao abrir arquivo"
  nome_arquivo:        .asciiz "/Users/ellian/code/faculdade/IFB-AC1/2024/projeto/sample/t2.txt"

  buffer:              .space 400  # buffer para armazenar o conteúdo do arquivo
  buffer_ano:          .space  40  # buffer para armazenar o ano do arquivo
  buffer_read_line:    .space 200  # buffer para armazenar linha lida 

  size_buffer:         .word 50 # quantidade de caracteres que o buffer suporta
  size_buffer_line:    .word 25 # quantidade de caracteres que o buffer suporta
  size_ano:            .word 4  # quantidade de caracteres para ano
  size_ignore:         .word 4  # quantidade de caracteres para ignorar informação

.text

main:
  la $a0, nome_arquivo      # carrega path arquivo
  jal abre_arquivo_leitura  # chama função de abrir arquivo
  add $s0, $v0, $zero       # salva descritor de arquivo

  loop:
    add $a0, $s0, $zero                      # configura descritor do arquivo como argumento
    la $a1, buffer                           # configura buffer de leitura

    processo_ler_arquivo:
      calcula_quantos_caracteres_o_buffer_deve_ler:
        la $t0, size_buffer                    # carrega endereço tamanho do buffer
        lw $t0, ($t0)                          # carrega valor do endereço do tamanho do buffer
        add $a2, $t0, $zero                    # configura numero de caracteres para leitura

      le_arquivo_e_finaliza_se_eof:
        jal le_arquivo                           # chama leitura de arquivo
        beq $v0, $zero, fecha_arquivo_e_finaliza # leitura == EOF => fecha arquivo e finaliza execução

      verifica_erro_na_leitura_do_arquivo:
        slt $t0, $v0, $zero              # retorno leitura arquivo < 0 ? 1 : 0
        bne $t0, $zero, erro_le_arquivo  # retorno leitura arquivo < 0 => encerra processo com erro

    busca_quebra_de_linha:
      la $a0, buffer                   # configura buffer de busca da string
      li $a1, '\n'                     # configura char para buscar na string
      jal strchr                       # chama procedimento de busca de char

    copia_linha_para_buffer:
      la $a0, buffer_read_line         # carrega buffer para escrita
      la $a1, buffer                   # carrega buffer para copiar
      move $a2, $v0                    # salva resultado da função como argumento memcpy
      jal memcpy                       # chama procedimento de cópia de buffer

      la $a0, buffer_read_line
      jal print_string                # chama procedimento de print da string

      # copiar string até caracter de quebra de linha para outro buffer
      # interpretar linha do arquivo
      #   ler 4 bytes do ano, ignorar 4 próximos bytes, separar buffer do valor inteiro

    j loop                           # volta no loop

  fecha_arquivo_e_finaliza:
    add $a0, $s0, $zero            # configura descritor como argumento do fechamento de arquivo
    addi $v0, $zero, 16            # configura syscall de fechamento de arquivo
    syscall                        # fecha arquivo
    j exit_success                 # finaliza execução do programa


# Functions

# https://stackoverflow.com/questions/53039818/understanding-the-strcmp-function-of-gnu-libc
# int strcmp (const char *p1, const char *p2) p1 > p2 => 1 | p1 == p2 => 0 | p1 < p2 => -1
strcmp:
  while_strcmp:
    lb $t0, 0($a0)       # carrega primeiro byte do argumento a0
    lb $t1, 0($a1)       # carrega primeiro byte do argumento a1

    beq $t0, $zero retorna_subtracao # caractere '\0' => break

    incrementa_endereco_string:
      addi $a0, $a0, 1   # endereço próximo caractere
      addi $a1, $a1, 1   # endereço próximo caractere

    beq $t0, $t1, while_strcmp

  retorna_subtracao:
    subu $v0, $t0, $t1  # v0 = t0 - t1
    jr $ra              # retorna para ultima instrução a chamar a função

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
  addiu $t2, $zero, 1         # inicializa contador

  while_memcmp:
    lb $t0, 0($a0)       # carrega primeiro byte do argumento a0
    lb $t1, 0($a1)       # carrega primeiro byte do argumento a1

    # incrementa endereco string
    addi $a0, $a0, 1   # endereço próximo caractere
    addi $a1, $a1, 1   # endereço próximo caractere

    beq $t2, $a2, retorna_subtracao_memcmp
    beq $t0, $t1, while_strcmp # *p1 == *p2 => while_strcmp

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

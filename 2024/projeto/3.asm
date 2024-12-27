.data
  erro_le_arquivo_str: .asciiz "Erro ao ler arquivo"
  erro_abrir_arquivo:  .asciiz "Erro ao abrir arquivo"
  nome_arquivo:        .asciiz "/home/ellian/code/faculdade/IFB-AC1/2024/projeto/sample/t2.txt"

  buffer:              .space 1024  # buffer para armazenar o conteúdo do arquivo
  buffer_ano:          .space 40    # buffer para armazenar o ano do arquivo

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

    calcula_quantos_caracteres_o_buffer_deve_ler:
      la $t0, size_ano                       # carrega endereço tamanho das strings ano
      lw $t0, ($t0)                          # carrega valor do endereço do tamanho do buffer
      add $a2, $t2, $zero                    # configura numero de caracteres para leitura

    le_arquivo_e_finaliza_se_eof:
      jal le_arquivo                           # chama leitura de arquivo
      beq $v0, $zero, fecha_arquivo_e_finaliza # leitura == EOF => fecha arquivo e finaliza execução

    verifica_erro_na_leitura_do_arquivo:
      slt $t0, $v0, $zero              # retorno leitura arquivo < 0 ? 1 : 0
      bne $t0, $zero, erro_le_arquivo  # retorno leitura arquivo < 0 => encerra processo com erro

    carrega_chamada_print_da_leitura_retorna_loop:
      la $a0, buffer_ano               # configura buffer de escrita
      jal print_string                 # chama procedimento de print da string

    j loop                           # volta no loop

  fecha_arquivo_e_finaliza:
    add $a0, $s0, $zero            # configura descritor como argumento do fechamento de arquivo
    addi $v0, $zero, 16            # configura syscall de fechamento de arquivo
    syscall                        # fecha arquivo
    j exit_success                 # finaliza execução do programa


# Functions

# https://stackoverflow.com/questions/53039818/understanding-the-strcmp-function-of-gnu-libc
# int strcmp (const char *p1, const char *p2)
strcmp:
  while_strcmp:
    lb $t0, 0($a0)       # carrega primeiro byte do argumento a0
    lb $t1, 0($a1)       # carrega primeiro byte do argumento a1

    beq $t0, $zero retorna_subtracao # break

    incrementa_endereco_string:
      addi $a0, $a0, 8   # a0 += 8 bytes => endereço próximo caractere
      addi $a1, $a1, 8   # a1 += 8 bytes => endereço próximo caractere

    beq $t0, $t1, while_strcmp

  subu $v0, $t0, $t1  # v0 = t0 - t1
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

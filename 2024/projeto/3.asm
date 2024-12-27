.data
  erro_le_arquivo_str: .asciiz "Erro ao ler arquivo"
  erro_abrir_arquivo:  .asciiz "Erro ao abrir arquivo"
  nome_arquivo:        .asciiz "/Users/ellian/code/faculdade/IFB-AC1/2024/projeto/1.asm"
  buffer:              .space 1024  # buffer para armazenar o conteúdo do arquivo
  size_buffer:         .word  1024  # tamanho do buffer

.text

main:
  la $a0, nome_arquivo      # carrega path arquivo
  jal abre_arquivo_leitura  # chama função de abrir arquivo
  add $s0, $v0, $zero       # salva descritor de arquivo

  loop:
    add $a0, $s0, $zero                      # configura descritor do arquivo como argumento
    la $a1, buffer                           # configura buffer de leitura

    calcula_quantos_caracteres_o_buffer_suporta:
      la $t0, size_buffer                    # carrega endereço tamanho buffer
      lw $t0, ($t0)                          # carrega valor do endereço do tamanho do buffer
      srl $t2, $t0, 3                        # numero de caracteres =  tamanho buffer / 8
      add $a2, $t2, $zero                    # configura numero de caracteres para leitura

    le_arquivo_e_finaliza_se_eof:
      jal le_arquivo                           # chama leitura de arquivo
      beq $v0, $zero, fecha_arquivo_e_finaliza # leitura = EOF => fecha arquivo e finaliza execução

    verifica_erro_na_leitura_do_arquivo:
      slt $t0, $v0, $zero              # retorno leitura arquivo < 0 ? 1 : 0
      bne $t0, $zero, erro_le_arquivo  # retorno leitura arquivo < 0 => encerra processo com erro

    carrega_chamada_print_da_leitura_retorna_loop:
      add $a0, $a1, $zero              # carrega o buffer para print da string
      jal print_string                 # chama procedimento de print da string
      j loop                           # volta no loop

  fecha_arquivo_e_finaliza:
    add $a0, $s0, $zero            # configura descritor como argumento do fechamento de arquivo
    addi $v0, $zero, 16            # configura syscall de fechamento de arquivo
    syscall                        # fecha arquivo
    j exit_success                 # finaliza execução do programa


# Functions

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

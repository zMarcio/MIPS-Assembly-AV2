.data
    arqComDiretorio: .asciiz "C:/Users/marci/OneDrive/Documentos/Faculdade/ArquiteturaDeComputadores/MIPS/trabalho-av2/numeros.txt"
    arqSalvar: .asciiz "C:/Users/marci/OneDrive/Documentos/Faculdade/ArquiteturaDeComputadores/MIPS/trabalho-av2/output_sorted.txt"
    .align 2                               # Garante alinhamento de 4 bytes
    arrayNumeros: .space 100               # Espaço para armazenar números (aumente se necessário)
    conteudoArquivo: .space 1024 #tamanho da memoria alocada para o arquivo3
    tamanhoArray: .word 100                          # tamanhoArray do array
    nova_linha: .asciiz "\n"                  # String para nova
    comma: .asciiz ", "     # Para adicionar vírgula entre os números 
    numBuffer: .space 12  # Espaço para armazenar a representação de um inteiro como string
.text
    .globl main
main:

    #abrir o arquivo no modo leitura
	la $v0, 13 #solicita a abertura
	#depois deve ser feita um pedido do arquivo que tem que ser salvo em #a0
	la $a0, arqComDiretorio #endereço do arquivo me $a0
	li $a1, 0 #0: leitura; 1: escrita;
	syscall
	#descritor fica em $v0

	#o descritor do arquivo é recuperado em $v0
	move $s0, $v0 #copia o descritor
	
	move $a0, $s0
	li $v0, 14 #ler conteudo do arquivo referenciado por $a0
	la $a1, conteudoArquivo #buffer que armazena o conteudo
	li $a2, 1024 #tamanhoArray do buffer
	syscall #leitura realizada

    # Inicialização
    la $t0, conteudoArquivo               # Ponteiro para o início da string 'dados'
    la $t1, arrayNumeros                  # Ponteiro para o início do array de inteiros
    li $t2, 0                             # Inicializa o número acumulado
    li $t3, 0                             # Sinalizador para negativo (0 = positivo, 1 = negativo)


processar_dados:
    lb $t4, 0($t0)                        # Carrega o próximo byte (caractere) da string
    beqz $t4, finalizar                   # Se for nulo (final da string), termina

    # Verificar se o caractere é uma vírgula ou sinal de menos
    li $t5, 44                            # ASCII para vírgula ','
    beq $t4, $t5, armazenar_numero        # Se for vírgula, armazena o número
    li $t5, 45                            # ASCII para '-'
    beq $t4, $t5, marcar_negativo         # Se for '-', marca como negativo

    # Converte caractere numérico para dígito e acumula no número
    li $t5, 48                            # ASCII para '0'
    sub $t4, $t4, $t5                     # Transforma caractere em dígito numérico
    mul $t2, $t2, 10                      # Multiplica número acumulado por 10
    add $t2, $t2, $t4                     # Adiciona o dígito ao número acumulado
    j continuar                           # Pula para continuar o processamento

marcar_negativo:
    li $t3, 1                             # Marca o número como negativo
    j continuar

armazenar_numero:
    # Torna o número negativo se necessário antes de armazená-lo
    beq $t3, 1, tornar_negativo

armazenar_direto:
    sw $t2, 0($t1)                        # Armazena o número no array
    addi $t1, $t1, 4                      # Avança para a próxima posição do array
    li $t2, 0                             # Redefine o número acumulado para 0
    li $t3, 0                             # Redefine o sinalizador de negativo
    j continuar

tornar_negativo:
    sub $t2, $zero, $t2                   # Torna o número negativo
    j armazenar_direto

continuar:
    addi $t0, $t0, 1                      # Avança para o próximo caractere na string
    j processar_dados                     # Continua o loop

finalizar:
    # Armazena a sentinela (0) para indicar o fim do array
    li $t2, 0
    sw $t2, 0($t1)       # Coloca a sentinela no array

    # Calcule o número de elementos armazenados
    # O ponteiro $t1 já está na posição onde a sentinela foi escrita
    # Portanto, para obter o número de elementos, precisamos calcular a diferença
    # entre o ponteiro inicial de arrayNumeros e $t1, e dividir por 4 (tamanho de cada inteiro)

    la $t1, arrayNumeros           # Reseta $t1 para o início do array
    li $t3, 0                       # Contador de elementos

contar_elementos:
    lw $t4, 0($t1)                  # Carrega o próximo número
    beqz $t4, armazenar_tamanho     # Se for zero (sentinela), termina
    addi $t3, $t3, 1                # Incrementa o contador de elementos
    addi $t1, $t1, 4                # Avança para o próximo número
    j contar_elementos              # Continua contando

armazenar_tamanho:
    sw $t3, tamanhoArray            # Armazena o tamanho no array

    # Inicia o Bubble Sort
    j boble_sort



imprimir_loop:
    lw $a0, 0($t1)                        # Carrega o número atual do array em $a0
    beqz $a0, encerrar                    # Se for sentinela (0), termina o loop

    li $v0, 1                             # syscall para printar integer
    syscall                               # Imprime o valor em $a0

    # Printar uma nova linha para legibilidade
    li $v0, 11                            # syscall para printar caractere
    li $a0, 10                            # ASCII para nova linha '\n'
    syscall

    addi $t1, $t1, 4                      # Move para a próxima posição do array
    j imprimir_loop                       # Continua até encontrar a sentinela

encerrar:
    li $v0, 10                            # Finaliza o programa
    syscall


boble_sort:
    # Inicializa ponteiros e contadores
    la $t0, arrayNumeros                # Ponteiro para o início do array
    lw $t1, tamanhoArray                   # Carrega o tamanhoArray do array em $t1

    # Loop externo para o Bubble Sort
outer_loop:
    li $t2, 0                         # Inicializa contador do loop interno
    li $t3, 0                         # Sinalizador para verificar se trocas ocorreram

inner_loop:
    # Compara dois elementos adjacentes
    lw $t4, 0($t0)                   # Carrega o elemento atual
    lw $t5, 4($t0)                   # Carrega o próximo elemento

    # Verifica se o elemento atual é maior que o próximo
    ble $t4, $t5, no_swap            # Se não for maior, não faz a troca

    # Troca os elementos
    sw $t5, 0($t0)                   # Armazena o próximo elemento na posição atual
    sw $t4, 4($t0)                   # Armazena o elemento atual na próxima posição
    li $t3, 1                         # Marca que uma troca ocorreu

no_swap:
    addi $t0, $t0, 4                  # Avança para o próximo par de elementos
    addi $t2, $t2, 1                  # Incrementa o contador do loop interno
    lw $t6, tamanhoArray                   # Carrega o tamanhoArray do array
    sub $t6, $t6, 1                    # Subtrai 1 para não acessar o último elemento
    bne $t2, $t6, inner_loop          # Continua o loop interno se não for o último par

    # Se não houve trocas, o array está ordenado
    beqz $t3, done                    # Se não houve trocas, termina

    # Reseta o ponteiro para o início do array e continua o loop externo
    la $t0, arrayNumeros                   # Reseta o ponteiro
    j outer_loop

# Imprime a lista ordenada
done:
    la $t0, arrayNumeros                  # Ponteiro para o início do array
    li $t1, 0                               # Contador de números impressos
    lw $t2, tamanhoArray                   # Carrega o tamanhoArray do array

print_loop:
    lw $a0, 0($t0)                        # Carrega o próximo número em $a0
    beqz $a0, encerrar                     # Se for zero (sentinela), termina o loop

    li $v0, 1                              # syscall para printar integer
    syscall                                # Imprime o número

    # Printa nova linha
    li $v0, 4                              # syscall para imprimir string
    la $a0, nova_linha                     # Endereço da nova linha
    syscall                                # Imprime nova linha

    addi $t0, $t0, 4                       # Avança para o próximo número
    addi $t1, $t1, 1                        # Incrementa o contador
    bne $t1, $t2, print_loop               # Continua imprimindo até o final do array
    
write_file:
    # Abrir o arquivo
    li $v0, 13            # syscall para abrir arquivo
    la $a0, arqSalvar     # nome do arquivo
    li $a1, 1             # modo escrita
    syscall                # chamada de sistema
    move $s0, $v0         # armazenar descritor do arquivo em $s0

    # Escrever os números no arquivo
    li $t0, 0             # índice do vetor
write_loop:
    # Carregar o próximo número do vetor
    lw $t4, arrayNumeros($t0) # Carrega o próximo número do vetor
    beqz $t4, end_write_loop   # Sair se o número for 0 (sentinela)

    # Converter inteiro para string
    move $a0, $t4          # número a ser convertido
    la $a1, numBuffer      # buffer para armazenar a string
    jal int_to_string      # chamar a função de conversão

    # Escrever a string no arquivo
    li $v0, 15             # syscall para escrever no arquivo
    move $a0, $s0          # descritor do arquivo
    la $a1, numBuffer      # string a ser escrita
    move $a2, $t3          # quantidade de caracteres a ser escrita
    syscall

    # Adicionar vírgula se não for o último número
    addi $t0, $t0, 4       # próximo inteiro (4 bytes por inteiro)
    lw $t5, arrayNumeros($t0) # Carrega o próximo número do vetor
    bnez $t5, write_comma   # Se não for o último número, escreva a vírgula

    j write_loop            # repetir o loop

write_comma:
    # Escrever vírgula no arquivo
    li $v0, 15             # syscall para escrever no arquivo
    move $a0, $s0          # descritor do arquivo
    la $a1, comma          # string vírgula
    li $a2, 2              # tamanho da vírgula (", ")
    syscall

    j write_loop            # repetir o loop

end_write_loop:
    # Fechar o arquivo
    li $v0, 16             # syscall para fechar arquivo
    move $a0, $s0          # descritor do arquivo
    syscall

    # Encerrar o programa
    li $v0, 10             # syscall para sair
    syscall


# Função para converter inteiro em string
# Recebe: $a0 = inteiro a ser convertido
# Retorna: $v0 = número de caracteres escritos (em $t3)
int_to_string:
    li $t3, 0              # contador de caracteres
    li $t4, 10             # divisor para conversão
    li $t5, 0              # indicador de sinal

    # Verifica se o número é negativo
    bltz $a0, negative

    j convert_loop

negative:
    negu $a0, $a0          # torna o número positivo
    li $t5, 1              # marca que é negativo
    j convert_loop

convert_loop:
    # Converte o número
    div $a0, $t4           # divide por 10
    mfhi $t6               # resto (dígito)
    addi $t6, $t6, '0'     # converte para caractere ASCII
    sb $t6, numBuffer($t3) # armazena o caractere no buffer
    addi $t3, $t3, 1       # incrementa contador

    mflo $a0               # atualiza o número para a parte inteira
    bnez $a0, convert_loop  # continua até o número ser 0

    # Se o número era negativo, adiciona o sinal
    beqz $t5, end_convert
    li $t6, '-'            # caractere de sinal
    sb $t6, numBuffer($t3) # armazena o sinal
    addi $t3, $t3, 1       # incrementa contador

end_convert:
    # Inverte a string
    li $t7, 0              # índice de inversão
    move $t8, $t3          # número de caracteres
    sub $t8, $t8, 1        # ajuste para índice

reverse_loop:
    bge $t7, $t8, done_reverse # se t7 >= t8, termina
    lb $t6, numBuffer($t7)      # carrega o caractere
    lb $t9, numBuffer($t8)      # carrega o caractere do final
    sb $t6, numBuffer($t8)      # troca
    sb $t9, numBuffer($t7)      # troca
    addi $t7, $t7, 1        # incrementa índice inicial
    subi $t8, $t8, 1        # decrementa índice final
    j reverse_loop

done_reverse:
    sb $zero, numBuffer($t3) # termina a string com null
    move $v0, $t3              # retorna a quantidade de caracteres
    jr $ra                      # retorna
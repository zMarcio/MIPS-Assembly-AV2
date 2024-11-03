.data
    numeros: .word 12, -34, 56, -78, 90, 80   # Array de números a serem ordenados
    tamanho: .word 6                          # Tamanho do array
    nova_linha: .asciiz "\n"                  # String para nova linha


.text
    .globl boble_sort
boble_sort:
    # Inicializa ponteiros e contadores
    la $t0, numeros                   # Ponteiro para o início do array
    lw $t1, tamanho                   # Carrega o tamanho do array em $t1

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
    lw $t6, tamanho                   # Carrega o tamanho do array
    sub $t6, $t6, 1                    # Subtrai 1 para não acessar o último elemento
    bne $t2, $t6, inner_loop          # Continua o loop interno se não for o último par

    # Se não houve trocas, o array está ordenado
    beqz $t3, done                    # Se não houve trocas, termina

    # Reseta o ponteiro para o início do array e continua o loop externo
    la $t0, numeros                   # Reseta o ponteiro
    j outer_loop

done:
    # Imprime a lista ordenada
    la $t0, numeros                   # Ponteiro para o início do array
    li $t1, 0                         # Contador de números impressos

print_loop:
    lw $a0, 0($t0)                   # Carrega o próximo número em $a0
    beqz $a0, encerrar                # Se for zero (sentinela), termina o loop

    li $v0, 1                         # syscall para printar integer
    syscall                           # Imprime o número

    # Printa nova linha
    li $v0, 4                         # syscall para imprimir string
    la $a0, nova_linha                # Endereço da nova linha
    syscall                           # Imprime nova linha

    addi $t0, $t0, 4                  # Avança para o próximo número
    addi $t1, $t1, 1                  # Incrementa o contador
    lw $t2, tamanho                   # Carrega o tamanho do array
    bne $t1, $t2, print_loop          # Continua imprimindo até o final do array

encerrar:
    # Finaliza o programa
    li $v0, 10                        # syscall para finalizar
    syscall
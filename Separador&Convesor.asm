.data
    dados: .asciiz "12,-34,56,-78,90,80,88,888"   # String com números separados por vírgulas
    .align 2                               # Garante alinhamento de 4 bytes
    arrayNumeros: .space 100               # Espaço para armazenar números (aumente se necessário)

.text
    .globl main
main:
    # Inicialização
    la $t0, dados                         # Ponteiro para o início da string 'dados'
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
    sw $t2, 0($t1)                        # Coloca a sentinela no array

    # Imprime cada número armazenado até encontrar a sentinela
    la $t1, arrayNumeros                  # Ponteiro para o início do array

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
.data 
    conteudoArq: .word 510,247,-107,858,465,777,-728,-15,165,717,323,968,636,906,-555,-300,-580
    localArq: .asciiz "C:/Users/marci/OneDrive/Documentos/Faculdade/ArquiteturaDeComputadores/MIPS/trabalho-av2/output.txt"
    numBuffer: .space 12  # Espaço para armazenar a representação de um inteiro como string
    comma: .asciiz ", "     # Para adicionar vírgula entre os números

.text
    main:
        # Abrir o arquivo
        li $v0, 13            # syscall para abrir arquivo
        la $a0, localArq      # nome do arquivo
        li $a1, 1             # modo escrita
        syscall                # chamada de sistema
        move $s0, $v0         # armazenar descritor do arquivo em $s0

        # Escrever os números no arquivo
        li $t0, 0             # índice do vetor

write_loop:
        # Carregar o próximo número do vetor
        lw $t2, conteudoArq($t0) # carregar o inteiro
        beq $t0, 400, end_write_loop  # sair se o índice atingir 100 números (100 * 4 bytes = 400 bytes)

        # Converter inteiro para string
        move $a0, $t2          # número a ser convertido
        la $a1, numBuffer      # buffer para armazenar a string
        jal int_to_string      # chamar a função de conversão

        # Escrever a string no arquivo
        li $v0, 15             # syscall para escrever no arquivo
        move $a0, $s0          # descritor do arquivo
        la $a1, numBuffer      # string a ser escrita
        move $a2, $t3          # quantidade de caracteres a ser escrita (t3 contém o número de caracteres)
        syscall

        # Adicionar vírgula se não for o último número
        addi $t0, $t0, 4       # próximo inteiro (4 bytes por inteiro)
        beq $t0, 400, end_write_loop # se for o último número, vá para o final

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
        move $v0, $t3             # retorna o número de caracteres
        jr $ra                     # retorna

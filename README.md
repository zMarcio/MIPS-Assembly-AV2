# Projeto em Assembly MIPS para Leitura, Processamento e Ordenação de Números

Este projeto em Assembly MIPS lê uma lista de números de um arquivo, processa, ordena, exibe os números ordenados no console e salva o resultado em um novo arquivo. A seguir está uma descrição detalhada das etapas e funcionalidades implementadas.

---

## Declaração de Dados

As variáveis e buffers usados são descritos abaixo:

- **arqComDiretorio**: Caminho do arquivo de entrada que contém os números.
- **arqSalvar**: Caminho do arquivo onde os números ordenados serão salvos.
- **arrayNumeros**: Espaço na memória para armazenar os números lidos do arquivo.
- **conteudoArquivo**: Buffer para armazenar o conteúdo lido do arquivo.
- **tamanhoArray**: Quantidade de números no array `arrayNumeros`.
- **nova_linha**: Símbolo de nova linha para exibição no console.
- **comma**: Símbolo de vírgula para separar números ao escrevê-los no arquivo de saída.
- **numBuffer**: Buffer temporário para conversão de números inteiros em strings.

---

## Código Principal

### 1. Abrir Arquivo para Leitura

- Solicita a abertura do arquivo `arqComDiretorio` em modo de leitura.
- Salva o descritor de arquivo, que será usado para operações de leitura.

### 2. Ler Conteúdo do Arquivo

- Lê o conteúdo do arquivo especificado em `conteudoArquivo`.
  
### 3. Processar Dados do Arquivo

- Para cada caractere em `conteudoArquivo`:
  - Se for um dígito, acumula o valor como parte de um número.
  - Se for um sinal de negativo, marca o número como negativo.
  - Se for uma vírgula, o número acumulado é salvo em `arrayNumeros`, e o processo recomeça para o próximo número.

### 4. Calcular Número de Elementos no Array

- Conta o número de elementos em `arrayNumeros` até encontrar a sentinela (`0`).
- Salva o total de elementos em `tamanhoArray`.

### 5. Ordenar Números com Bubble Sort

- Implementa o Bubble Sort para ordenar `arrayNumeros`.
- Para cada par de elementos adjacentes no array, realiza uma troca, se necessário, até que a lista esteja ordenada.

### 6. Imprimir Números Ordenados

- Exibe cada número de `arrayNumeros` no console, cada um em uma nova linha.

### 7. Abrir Arquivo para Escrita e Salvar Números

- Abre `arqSalvar` para escrita e salva os números de `arrayNumeros` no arquivo, separados por vírgulas.

---

## Função de Conversão de Inteiro para String

Converte um número inteiro em uma string para facilitar a exibição e gravação no arquivo de saída:

1. Se o número for negativo, torna-o positivo e marca o sinal.
2. Converte cada dígito em um caractere ASCII e armazena em `numBuffer`.
3. Inverte a string para que a ordem dos dígitos esteja correta.
4. Finaliza a string com um caractere null (`\0`).

---

## Finalização do Programa

- Fecha os arquivos abertos.
- Termina o programa com uma chamada de saída do sistema. 

---

Este projeto demonstra conceitos de manipulação de arquivos, ordenação e processamento de dados em Assembly MIPS.

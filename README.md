# SSC0108 - Prática-SD

[Laboratory Exercise 7 - Finite State Machines](img/lab8.pdf)

### Alunos

|        Nome                         |    NUSP   |       
|:-----------------------------------:|:---------:|  
|   Laura Fernandes Camargos          |  13692334 |   
|   Sandy da Costa Dutra       	      |  12544570 |   
|   Vitor Nishimura		                |  5255289  | 

# Softwares utilizados

Quartus Prime 21.1 <br>

## Part I
Desejamos implementar uma máquina de estados finitos (FSM) que reconheça duas sequências específicas de símbolos de entrada aplicados, a saber, quatro 1s consecutivos ou quatro 0s consecutivos. Existe uma entrada w e uma saída z. Sempre que w=1 ou w=0 por quatro pulsos de clock consecutivos, o valor de z deve ser 1; caso contrário, z=0. Sequências sobrepostas são permitidas, de modo que, se w=1 por cinco pulsos de clock consecutivos, a saída z será igual a 1 após o quarto e quinto pulsos. A Figura abaixo ilustra a relação necessária entre w e z.

<div align ="center">
    <img src ="img/figure1.png" style="max-width: 100%;" alt="rampart1">
</div>

### Arquivo VHDL ram32x4.vhd:
```
ENTITY ram32x4 IS
PORT ( address : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
clock : IN STD_LOGIC := ’1’;
data : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
wren : IN STD_LOGIC ;
q : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) );
END ram32x4;
```
Ao compilar o circuito com os sinais dd entrada e saída foi observado no Relatório de Compilação que o Compilador Quartus usa 128 bits em um dos blocos de memória FPGA para implementar o circuito RAM.

<div align ="center">
    <img src ="img/compilationreportpart1.PNG" style="max-width: 100%;" alt="rampart1">
</div>

Simulação do comportamento do nosso circuito:
<div align ="center">
    <img src ="img/simulacaopart1.png" style="max-width: 100%;" alt="Simulação do circuito no Quartus">
</div>


## Part II
Uma vez compilado e simulado o circuito, foi feita a configuração da FPGA Cyclone V DE0-CV para testar o circuito de fato. Fora usados os switches SW3−0 para fornecer dados de entrada para a RAM e os switches SW8−4 para especificar o endereço. O switch SW9 foi usado como o sinal de gravação e o KEY0 como a entrada do relógio. O valor do endereço foi mostrado nos displays de 7 segmentos HEX5 − 4, os dados que estão inseridos na memória foram mostrados no HEX2 e os dados lidos da memória no HEX0.

Circuito do nosso esquema no quartus com os pinos já configurados:

<div align ="center">
    <img src ="img/blocospart2.png" style="max-width: 100%;" alt="Blocopart2">
</div>

[Link para o projeto implementado no Quartus](quartus/part1/praticaram)

	
## Part III

Agora, em vez de criar um subcircuito de módulo de memória usando o IP Catalog do Quartus, implementamos a memória necessária especificando sua estrutura em código VHDL. Em um design especificado por VHDL, é possível definir a memória como uma matriz multidimensional.

Uma matriz 32 x 4, que tem 32 palavras com 4 bits por palavra, pode ser declarada pela seguinte declaração:

```
TYPE mem IS ARRAY(0 TO 31) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL memory_array : mem;
```

Em uma FPGA, tal matriz pode ser implementada usando os flip-flops que cada elemento lógico contém ou, mais eficientemente, usando os blocos de memória integrados.

### Codigo VHDL:

```
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY ram32bits IS
    PORT (
        address  : IN  STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5-bit address for 32 locations
        clock    : IN  STD_LOGIC;
        dataIn   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4-bit input data
        wrt      : IN  STD_LOGIC; -- write enable signal
        --dataOut  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4-bit output data
        hex0     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- data out
        hex1     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- data in
        hex2     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- mem digit 1
        hex3     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- mem digit 2
    );
END ram32bits;

ARCHITECTURE Behavior OF ram32bits IS
    TYPE mem IS ARRAY(0 TO 31) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL memory_array : mem := (others => (others => '0'));

    FUNCTION to_7_segment(data : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE data IS
            WHEN "0000" => RETURN "0000001"; -- 0
            WHEN "0001" => RETURN "1001111"; -- 1
            WHEN "0010" => RETURN "0010010"; -- 2
            WHEN "0011" => RETURN "0000110"; -- 3
            WHEN "0100" => RETURN "1001100"; -- 4
            WHEN "0101" => RETURN "0100100"; -- 5
            WHEN "0110" => RETURN "0100000"; -- 6
            WHEN "0111" => RETURN "0001111"; -- 7
            WHEN "1000" => RETURN "0000000"; -- 8
            WHEN "1001" => RETURN "0001100"; -- 9
            WHEN "1010" => RETURN "0001000"; -- A
            WHEN "1011" => RETURN "1100000"; -- B
            WHEN "1100" => RETURN "0110001"; -- C
            WHEN "1101" => RETURN "1000010"; -- D
            WHEN "1110" => RETURN "0110000"; -- E
            WHEN "1111" => RETURN "0111000"; -- F
            WHEN OTHERS => RETURN "1111111"; -- Blank or error
        END CASE;
    END FUNCTION;

    FUNCTION bit_to_7_segment(data : STD_LOGIC) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE data IS
            WHEN '0' => RETURN "0000001"; -- 0
            WHEN '1' => RETURN "1001111"; -- 1
            WHEN OTHERS => RETURN "1111111"; -- Blank or error
        END CASE;
    END FUNCTION;

BEGIN
    PROCESS (clock)
    BEGIN
        IF rising_edge(clock) THEN
            IF wrt = '1' THEN
                memory_array(CONV_INTEGER(address)) <= dataIn;
            END IF;
            --dataOut <= memory_array(CONV_INTEGER(address)); -- Update the dataOut with the read value
            hex0 <= to_7_segment(memory_array(CONV_INTEGER(address))); -- data out
				hex1 <= to_7_segment(dataIn); -- data in
				hex2 <= to_7_segment(address(3 DOWNTO 0)); -- Display lower 4 bits of address
				hex3 <= bit_to_7_segment(address(4)); -- Display highest bit of address as a single bit
        END IF;
		  
    END PROCESS;
END Behavior;

```
Uma vez compilado o circuito, foi testado a funcionalidade do nosso projeto aplicando algumas entradas e saídas para a FPGA DEO-CV.

[Link para o projeto implementado no Quartus](quartus/part3/ram_part3/)


## Part IV

Para esta parte da prática, foi criado um tipo diferente do módulo de memória apresentado na Part I, no qual há uma porta para fornecer o endereço para uma operação de leitura e uma porta separada que fornece o endereço para uma operação de gravação. Foram executadas as seguintes etapas:

### 1. Criar um novo projeto no Quartus e gerar o módulo de memória:
   - No **IP Catalog**, foi escolhido o módulo **RAM: 2-PORT** na categoria **Basic Functions > On Chip Memory**.
   - Depois, escolhido **With one read port and one write port** para configurar a RAM com uma porta de leitura e outra de escrita.
   - Configurado o tamanho da memória, o método de clock e as portas registradas, assim como na Parte II.
   - Para a opção **Mixed Port Read-During-Write for Single Input Clock RAM**, foi selecionado **I do not care (The outputs will be undefined)**, permitindo que os dados possam ser novos ou antigos se os endereços de leitura e escrita coincidirem.
   - Foi feita a inicialização dos valores da memória através da criação de um arquivo `ram32x4.mif`.

### 2. Criar um Arquivo VHDL para instanciar a memória:
   - Foi criado um arquivo VHDL que instancia o módulo de memória de duas portas.
   - Adicionado um contador para percorrer os endereços de leitura da memória a cada um segundo.

### 5. Configurar os pinos da FPGA e testar o circuito:
   - No display de 7 segmentos **HEX0**, é mostrado o conteúdo da memória (em hexadecimal).
   - No display **HEX3-2** é mostrado o endereço atual através do contador de 1 segundo.
   - Os switches **SW8-4** mostram o endereço de escrita e **SW3-0** o dado de escrita. O endereço de escrita é exibido em **HEX5-4** e o dado de escrita em **HEX1**.
   - É feita a sincronização das entradas dos switches ao clock de 50 MHz da FPGA.

 Após testar o circuito os resultados foram: o conteúdo inicial da memória corresponde ao arquivo `ram32x4.mif` e foi possível escrever dados em qualquer endereço da memória usando os switches.

[Link para o projeto implementado no Quartus](quartus/part3/ram_part3/)



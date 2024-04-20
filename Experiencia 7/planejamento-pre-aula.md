# Planejamento Aula 6

Como planejamento de afazeres para a experiência 06, visamos realizar alguns testes de forma a verificar a eficácia dos códigos gerados. Para tanto, começaremos realizando a mesma montagem do experimento 5 e adicionando o receptor serial na placa.

Após realizada a montagem do código em vhdl, o próximo passo a ser realizado em laboratório é a montagem no *Quartus*. Inicialmente conecta-se a entrada serial em algum pino próximo a saída serial que utilizamos na experiência 5. Enquanto isso, o *reset*, *serial_data* e o *start* são conectado em um pinos na GPIO, bem como o GND, e o sinal de *Done* é enviado para um LED da placa. 

O *clock* gerado pelo FPGA através pela GPIO (CLOCK_50) apresenta uma frequência de 50MHz, por isso temos a necessidade de realizar a sua divisão, ja que a nossa frequência de transmissão será de 4800Hz. A nossa implementação do *serial_in* recebe o *clock* de 50MHz e divide ele a uma taxa de 50MHz/(4800*4) para assim, utilizar na frequência de amostragem de 19200Hz, para maximizar a chance de amostrar o dado corretamente. 

O objetivo da experiência é utilizar o programa *Waveform* para enviar um caractere através de um GPIO, do *Analog Discovery*, utilizando o protocolo serial UART e mostrar o dado recebido no FPGA em um display de 7 segmentos e nos LEDs.

Para isso, iremos fazer testes qualitativos para os caracteres "1", "3", "A", "P" e "Q":

| Analog Discovery | Analog Discovery(ASCII) | GPIO      | GPIO      | Analog Discovery        | LED(7 downto 0) | LED(9)             | Display (ASCII)   |
| ---------------- | ----------------------- | --------- | --------  | ----------------------- | --------------- | ------------------ | ----------------- |
| **Entrada**      | **Entrada**             | **reset** | **start** | **Saída(Parity_Bit)**   | **Saída**       | **Saída(done)**    | **Saída**         |
| 00110001         | 1                       | 1         | 1         | 1/0                     | 00000000        | 0                  | ------            |
| 00110001         | 1                       | 0         | 0         | Mantém o anterior       | 00000000        | Mantém o anterior  | ------            |
| 00110001         | 1                       | 0         | 1         | 1                       | 00110001        | 1                  | 1                 |
| 00110001         | 1                       | 0         | 0         | Mantém o anterior       | 00110001        | Mantém o anterior  | 1                 |
|                  |                         |           |           |                         |                 |                    |                   |
| 00110011         | 3                       | 1         | 1         | 1/0                     | 00000000        | 0                  | ------            |
| 00110011         | 3                       | 0         | 0         | Mantém o anterior       | 00000000        | 0                  | ------            |
| 00110011         | 3                       | 0         | 1         | 1                       | 00110011        | 1                  | 3                 |
| 00110011         | 3                       | 0         | 0         | Mantém o anterior       | 00110011        | Mantém o anterior  | 3                 |
|                  |                         |           |           |                         |                 |                    |                   |
| 01000001         | A                       | 1         | 1         | 1/0                     | 00000000        | 0                  | ------            | 
| 01000001         | A                       | 0         | 0         | Mantém o anterior       | 00000000        | 0                  | ------            |
| 01000001         | A                       | 0         | 1         | 1                       | 01000001        | 1                  | A                 |
| 01000001         | A                       | 0         | 0         | Mantém o anterior       | 01000001        | Mantém o anterior  | A                 |
|                  |                         |           |           |                         |                 |                    |                   |
| 01010000         | P                       | 1         | 1         | 1/0                     | 00000000        | 0                  | ------            | 
| 01010000         | P                       | 0         | 0         | Mantém o anterior       | 00000000        | 0                  | ------            |
| 01010000         | P                       | 0         | 1         | 1                       | 01010000        | 1                  | P                 |
| 01010000         | P                       | 0         | 0         | Mantém o anterior       | 01010000        | Mantém o anterior  | P                 |
|                  |                         |           |           |                         |                 |                    |                   |
| 01010001         | Q                       | 1         | 1         | 1/0                     | 00000000        | 0                  | ------            | 
| 01010001         | Q                       | 0         | 0         | Mantém o anterior       | 00000000        | 0                  | ------            |
| 01010001         | Q                       | 0         | 1         | 1                       | 01010001        | 1                  | Q                 |
| 01010001         | Q                       | 0         | 0         | Mantém o anterior       | 01010001        | Mantém o anterior  | Q                 |
  
> Os parâmetros utilizados para os casos teste foram os seguintes:          
>  <i style="font-size: 12px;">
> $\quad$ POLARITY = TRUE\
> $\quad$ WIDTH = 8\
> $\quad$ PARITY = 1\
> $\quad$ CLOCK_MUL = 4 </i>
> 
> "`-`" <i style="font-size: 12px;"> representa um display apagado </i>
>
> <i style="font-size: 12px;"> As saídas equivalentes aos `stop_bits` não foram representadas na tabela </i>
> 
> <i style="font-size: 12px;"> Os GPIOs para o `reset` e `tx_go` vão ser definidos no laboratório, quando formos montar o projeto Quartus</i>
> 
> <i style="font-size: 12px;"> A entrada `clock` é gerada pela própria placa FPGA, correspondendo ao valor de 50MHz.</i>
>
> <i style="font-size: 12px;"> Conforme especificado pelo enunciado, o `reset` é compartilhado com transmissor.</i>
>
> <i style="font-size: 12px;">O display só mostrará a saída paralela apenas quando o *done* for igual 1, caso contrario, estará desligado.</i>
>
> <i style="font-size: 12px;">A entradas/saídas com `1/0`, estão com essa indicação pois tanto faz qual valor será recebido/enviado, devido o reset e/ou o start. </i>

Com os testes realizados, caso as saída sejam iguais as esperadas, isso significara sucesso no projeto. Caso elas sejam diferentes, significara que algo em nosso código esta errado e, com isso, iremos buscar corrigi-lo.
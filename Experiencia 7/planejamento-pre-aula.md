# Planejamento Aula 7

Como planejamento de afazeres para a experiência 07, visamos realizar alguns testes de forma a verificar a eficiência dos códigos gerados. Para tanto, começaremos realizando a elaboração de um código que unifica as duas ultimas experiências com o projeto do *multisteps*.

Após realizada a montagem do código em vhdl, o próximo passo a ser realizado em laboratório é a montagem no *Quartus*. Inicialmente conecta-se a entrada serial em algum pino próximo a saída serial que utilizamos na experiência 5. Enquanto isso, o *reset* será conectado em um pinos na GPIO, bem como o GND.

Utilizando o divisor de *clock* gerado nos experimentos passado, iremos pegar o *clock* gerado pelo FPGA através da GPIO (CLOCK_50), que apresenta uma frequência de 50MHz, e dividi-lo de forma a ajustar nossa frequência de transmissão e de amostragem, de forma a amostrar o dado corretamente. A nossa entidade espera uma frequência de transmissão 4 vezes menor que a frequência de entrada, por isso, vamos dividir o clock de 50MHz do FPGA  para colocar uma frequencia de entrada (*clock*) de 19200Hz, para assim fazer a transmissão em 4800Hz.

Por fim, seguindo as recomendações do roteiro experimental, iremos realizar a montagem na placa de forma a verificar os dados do *serial_in*, o estado do *multisteps* e os dados do *serial_out*. Para isso, iremos expor display o *serial_in* e, utilizando um dos botões, iremos expor o *serial_out*, para verificar o estado do *multisteps*, iremos interligar seu estado em um dos LEDs da placa, em que o LED em alto significa que esta ocorrendo uma operação e o LED em baixo indica que a operação foi finalizada.

O objetivo da experiência é unificar os dois últimos experimentos com projeto do multisteps o programa, de forma a enviar um dado de entrada, codifica-lo e expor seu resultado. 

Para isso, iremos fazer o seguinte testes qualitativo (podendo realizar outros):

| Entrada          | GPIO      | Display                          |
| ---------------- | --------- | -------------------------------- |
| **Entrada**      | **reset** | **saída (ultimos 8b multistep)** |
| 11000111         | 1         | ------                           |
| 11000111         | 0         | 11101000                         |
| 11000111         | 1         | ------                           |

  
> Os parâmetros utilizados para os casos teste foram os seguintes:          
>  <i style="font-size: 12px;">
> $\quad$ POLARITY = TRUE\
> $\quad$ WIDTH = 8\
> $\quad$ PARITY = 1\
>$\quad$ STOP_BITS = 2\
> $\quad$ CLOCK_MUL = 4 </i>
> 
> "`-`" <i style="font-size: 12px;"> representa um display apagado </i>>
>
> 
> <i style="font-size: 12px;"> O GPIO para o `reset` será definidos no laboratório, quando formos montar o projeto Quartus</i>
> 
> <i style="font-size: 12px;"> A entrada `clock` é gerada pela própria placa FPGA, correspondendo ao valor de 50MHz.</i>
>
> <i style="font-size: 12px;"> Conforme especificado pelo enunciado, o `reset` é compartilhado com transmissor.</i>

Com os testes realizados, caso as saída sejam iguais as esperadas, isso significara sucesso no projeto. Caso elas sejam diferentes, significara que algo em nosso código esta errado e, com isso, iremos buscar corrigi-lo.
Com o inicio da aula, começamos por sintetizar o código no quartus para verificar se nossas conexões estavam corretas. COmo conexões, interligamos o resetr e o serial_in no GPIO_0 e o serial_out no GPIO_1. Com tudo montado, compilamos o projeto e fomos verificar sua eficácia. De inicio, o unico erro encontrado foi no fato de que esquecemos de interligar o clock da placa com o clock do programa. A partir disso, nosso código começou a funcionar corretamente. Demonstramos para o professor e, após isso, começamos a realizar o desafio.
Ele consistia em enviar os dois bytes menos significativos da saida do multsteps (em ASCII) para os displays e enviar pela a saida serial o segundo byte menos significativo (ao inves do primeiro). Ajustamos nosso código do multisteps de forma a enviar o Haso para fora e, com isso, enviamos para os displays a saida da seguinte forma:
HEX0 <= haso(7 downto 0),
HEX1 <= haso(15 downto 8),
HEX2 <= haso(23 downto 16),
HEX3 <= haso(31 downto 24).
Com isso, verificando a saida em ASCII do Bytes pedido.
Para enviar o segundo byte menos significativo, nós apenas alteramos qual conjunto de bits da saída do multsteps teriamos que enviar para o serial_out.
Como teste para verificar seu funcionamento, testamos o caracter "H", em que a saida esperada no display era "h?". Verificando que estava funcionando, chamamos o professor e finalizamos o projeto.

Com a elaboração do experimento, entendemos como realizar a inteligação entre vários componentes criados anteriormente, utilizar a aba _protocol_ do aplicativo _Waveforms_ para enviar e receber dados através do protocolo UART e verificar a codificação de dados.

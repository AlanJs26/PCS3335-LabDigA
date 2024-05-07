Com o inicio da aula, começamos por sintetizar o código no quartus para verificar se nossas conexões estavam corretas. Como conexões, interligamos o reset e o serial_in no GPIO_0 e o serial_out no GPIO_1. Com tudo montado, compilamos o projeto e fomos verificar sua eficácia. De inicio, verificamos um problema para enviar a entrada, pois o programa só aceitava entradas em texto ou numero, sendo que ela estava em ASCII. Após converter os números para texto (colocando '\x' entre cada byte), compilamos e colocamas a entrada, que gerou o resultado, mas verificamos que não conseguiamos enviar mais de uma entrada seguida e, por um erro de interpretação do enunciado, enviavamos a entrada zero para o caso em que a paridade não batia com o esperado. Corrigimos nosso erro e, a partir disso, nosso código começou a funcionar corretamente. Demonstramos para o professor e, finalizamos a experiencia.
Para demonstrar o funcionamento, realizamos os seguintes testes:
- Com a entrada fornecida, o primeiro foi verificar se a saida correspondia com a esperada
- O segundo teste foi verificar se o programa considerava para o caso de enviarmos mais que 64 bytes seguidos
- O terceiro e ultimo foi verificar o que aconteceria se enviassemos uma entrada com a paridade errada

Para os testes realizados, as entradas/saidas foram:
- Entrada: \x00\x00\x00\x78\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x6f\x6e\x61\x80\x44\x65\x20\x42\x62\x65\x72\x20\x47\x6c\x61\x75
- Saida:
8F 3B 9F 04 9D F6 10 D9 EB 74 B8 00 D5 FA DE 14 08 AA 73 C1 0C AD 00 AD 06 69 98 02 92 A7 79 FD 

- Entrada: \x00\x00\x00\xf8\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x6c\x20\x41\x80\x67\x69\x74\x61\x6f\x20\x44\x69\x74\x6f\x72\x69\x62\x6f\x72\x61\x2d\x20\x4c\x61\x33\x33\x35\x20\x50\x43\x53\x33
- Saida:
BD 02 D6 73 FF 4E 48 68 C1 F0 15 C8 FF EB 42 03 30 B7 5E E3 6D BC 77 D0 5C 6E 9B 20 DE 71 68 FD

Com a elaboração do experimento, verificamos e entendemos como realizar a inteligação entre vários componentes criados anteriormente, utilizar a aba _protocol_ do aplicativo _Waveforms_ para enviar e receber dados através do protocolo UART e verificar a codificação de dados.

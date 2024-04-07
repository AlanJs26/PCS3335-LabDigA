# Planejamento Aula 5

Como planejamento de afazeres para a experiência 05, visamos realizar alguns testes de forma a verificar a eficácia dos códigos gerados.

Para isso, iremos fazer testes qualitativos:

|Chaves|Display|LED(9)|LED(7 downto 0)|GPIO|GPIO|Analog Discovery|
|--|--|--|--|--|--|--|
|Entrada|Entrada|Saída(tx_done)|Entrada|rst|tx_go|Saída|
|11111110|----fe|0|11111110|1|0|1111111111| <!-- Teste 1 -->
|11111110|----fe|0|11111110|0|0|1111111111|
|11111110|----fe|0|11111110|0|1|1111111111|
|11111110|----fe|0|11111110|0|1|1111111111|
|11111110|----fe|1|11111110|0|1|0000000000|
||||||||
|10101010|----aa|1|10101010|0|0|0101010100| <!-- Teste 2 -->
|10101010|----aa|1|10101010|0|0|0101010100|
|10101010|----aa|1|10101010|0|0|1111111111|
|10101010|----aa|1|10101010|0|0|0101010100|
|10101010|----aa|0|10101010|0|0|0101010100|
|||||||
|00110001|----31|0|00110001|0|0|1111111111| <!-- Teste 3 -->
|00110001|----31|0|00110001|0|0|1111111111|
|00110001|----31|1|00110001|0|0|1111111111|
|00110001|----31|0|00110001|0|0|1111111111|
|00110001|----31|1|00110001|0|0|0110010110|
||||||||
|11111111|----ff|1|11111111|0|0|0111111110| <!-- Teste 4 -->
|11111111|----ff|1|11111111|0|0|1111111111|
|11111111|----ff|1|11111111|0|0|1111111111|
|11111111|----ff|1|11111111|0|0|1111111111|
|11111111|----ff|1|11111111|0|0|0111111110|

> `-` <i style="font-size: 12px;"> representa um display apagado </i>

Com os testes realizados, caso as saída sejam iguais as esperadas, isso significara sucesso no projeto. Caso elas sejam diferentes, significara que algo em nosso código esta errado e, com isso, iremos buscar corrigi-lo.
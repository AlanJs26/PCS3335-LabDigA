# Planejamento Aula 6

Como planejamento de afazeres para a experiência 06, visamos realizar alguns testes de forma a verificar a eficácia dos códigos gerados. Para tanto, começaremos realizando a mesma montagem do experimento 5 e adicionando o receptor serial na placa.

Para isso, iremos fazer testes qualitativos para os caracteres "1", "3", "A", "P" e "Q":

| Analog Discovery | Analog Discovery(ASCII) | LED(7 downto 0) | Analog Discovery        | LED(9)             | GPIO      | GPIO      | GPIO      | Display (ASCII)   |
| ---------------- | ----------------------- | --------------- | ----------------------- | ------------------ | --------- | --------  | --------- | ----------------- |
| **Entrada**      | **Entrada**             | **Entrada**     | **Entrada(Parity_Bit)** | **Saída(tx_done)** | **reset** | **start** | **tx_go** | **Saída**         |
| 00110001         | 1                       | 00110001        | 0                       | 0                  | 1         | 1         | 0         | 1                 |
| 00110001         | 1                       | 00110001        | 0                       | 0                  | 0         | 0         | 0         | 1                 |
| 00110001         | 1                       | 00110001        | 0                       | 1                  | 0         | 0         | 1         | 1                 |
| 00110001         | 1                       | 00110001        | 0                       | 1                  | 0         | 0         | 1         | 1                 |
| 00110001         | 1                       | 00110001        | 0                       | 0                  | 1         | 1         | 1         | 1                 |
|                  |                         |                 |                         |                    |           |           |           |                   |
| 00110011         | 3                       | 00110011        | 0                       | 0                  | 0         | 0         | 0         | 3                 |
| 00110011         | 3                       | 00110011        | 0                       | 1                  | 0         | 0         | 1         | 3                 |
| 00110011         | 3                       | 00110011        | 0                       | 0                  | 1         | 1         | 0         | 3                 |
| 00110011         | 3                       | 00110011        | 0                       | 0                  | 1         | 1         | 1         | 3                 |
| 00110011         | 3                       | 00110011        | 0                       | 1                  | 0         | 0         | 1         | 3                 |
|                  |                         |                 |                         |                    |           |           |           |                   |
| 01000001         | A                       | 01000001        | 0                       | 0                  | 1         | 1         | 1         | A                 | 
| 01000001         | A                       | 01000001        | 0                       | 0                  | 0         | 0         | 0         | A                 |
| 01000001         | A                       | 01000001        | 0                       | 1                  | 0         | 0         | 1         | A                 |
| 01000001         | A                       | 01000001        | 0                       | 0                  | 0         | 0         | 1         | A                 |
| 01000001         | A                       | 01000001        | 0                       | 1                  | 1         | 1         | 0         | A                 |
|                  |                         |                 |                         |                    |           |           |           |                   |
| 01010000         | P                       | 01010000        | 0                       | 1                  | 0         | 0         | 1         | P                 | 
| 01010000         | P                       | 01010000        | 0                       | 0                  | 1         | 1         | 0         | P                 |
| 01010000         | P                       | 01010000        | 0                       | 0                  | 1         | 1         | 1         | P                 |
| 01010000         | P                       | 01010000        | 0                       | 1                  | 0         | 0         | 1         | P                 |
| 01010000         | P                       | 01010000        | 0                       | 1                  | 0         | 0         | 1         | P                 |
|                  |                         |                 |                         |                    |           |           |           |                   |
| 01010001         | Q                       | 01010001        | 1                       | 1                  | 0         | 0         | 1         | Q                 | 
| 01010001         | Q                       | 01010001        | 1                       | 0                  | 1         | 1         | 0         | Q                 |
| 01010001         | Q                       | 01010001        | 1                       | 0                  | 1         | 1         | 1         | Q                 |
| 01010001         | Q                       | 01010001        | 1                       | 1                  | 0         | 0         | 1         | Q                 |
| 01010001         | Q                       | 01010001        | 1                       | 1                  | 0         | 0         | 1         | Q                 |
            
> `-` <i style="font-size: 12px;"> representa um display apagado </i>
>
> <i style="font-size: 12px;"> As saídas equivalentes aos `stop_bits` não foram representadas na tabela </i>
> 
> <i style="font-size: 12px;"> Os GPIOs para o `reset` e `tx_go` vão ser definidos no laboratório, quando formos montar o projeto Quartus</i>
> 
> <i style="font-size: 12px;"> A entrada `clock` é gerada pela própria placa FPGA, correspondendo ao valor de 50MHz.</i>
>
> <i style="font-size: 12px;"> Conforme especificado pelo enunciado, o `reset` é compartilhado com transmissor.</i>

Com os testes realizados, caso as saída sejam iguais as esperadas, isso significara sucesso no projeto. Caso elas sejam diferentes, significara que algo em nosso código esta errado e, com isso, iremos buscar corrigi-lo.
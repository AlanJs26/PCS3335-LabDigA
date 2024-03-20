/******************************************************************************
   Author: Alan Jose dos Santos (alanjose@usp.br)
   Author: Lucas Franco
   File Name: main.cpp
*******************************************************************************/

#include <iostream>
#include <bitset>
#include <iomanip>
#include <stdint.h>

uint32_t reverse(uint32_t x)
{
    x = ((x & 0x55555555) << 1) | ((x & 0xAAAAAAAA) >> 1); // Swap _<>_
    x = ((x & 0x33333333) << 2) | ((x & 0xCCCCCCCC) >> 2); // Swap __<>__
    x = ((x & 0x0F0F0F0F) << 4) | ((x & 0xF0F0F0F0) >> 4); // Swap ____<>____
    x = ((x & 0x00FF00FF) << 8) | ((x & 0xFF00FF00) >> 8); // Swap ...
    x = ((x & 0x0000FFFF) << 16) | ((x & 0xFFFF0000) >> 16); // Swap ...
    return x;
}

uint32_t rotr(uint32_t x, int n){
    return (x >> n) | (x << (32 - n));
}

uint32_t ch(uint32_t x,uint32_t y,uint32_t z) {
  return (x & y) ^ (~x & z);
}

uint32_t maj(uint32_t x,uint32_t y,uint32_t z) {
  return (x & y) ^ (x & z) ^ (y & z);
}

uint32_t sum0(uint32_t x) {
  return rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22);
}

uint32_t sum1(uint32_t x) {
  return rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25);
}

uint32_t sigma0(uint32_t x) {
  return rotr(x, 7) ^ rotr(x, 18) ^ (x >> 3);
}

uint32_t sigma1(uint32_t x) {
  return rotr(x, 17) ^ rotr(x, 19) ^ (x >> 10);
}

void printbinary(uint32_t x, std::string name){
    std::cout << std::dec << std::left << name << ": " << std::setw(20) << x << std::right << "  binario: " << std::bitset<32>(x) << "  hexadecimal: " << std::hex << x << std::endl;
}

void stepfun(
    uint32_t ai,
    uint32_t bi,
    uint32_t ci,
    uint32_t di,
    uint32_t ei,
    uint32_t fi,
    uint32_t gi,
    uint32_t hi,
    uint32_t kpw
    ){

    uint32_t a0 = hi + sum1(ei) + ch(ei,fi,gi) + kpw + sum0(ai) + maj(ai,bi,ci);
    uint32_t b0 = ai;
    uint32_t c0 = bi;
    uint32_t d0 = ci;
    uint32_t e0 = di + hi + sum1(ei) + ch(ei,fi,gi) + kpw;
    uint32_t f0 = ei;
    uint32_t g0 = fi;
    uint32_t h0 = gi;

    // printbinary(ai, "ai");
    // printbinary(bi, "bi");
    // printbinary(ci, "ci");
    // printbinary(di, "di");
    // printbinary(ei, "ei");
    // printbinary(fi, "fi");
    // printbinary(gi, "gi");
    // printbinary(hi, "hi");
    //
    std::cout << std::endl;

    printbinary(a0, "a0");
    printbinary(b0, "b0");
    printbinary(c0, "c0");
    printbinary(d0, "d0");
    printbinary(e0, "e0");
    printbinary(f0, "f0");
    printbinary(g0, "g0");
    printbinary(h0, "h0");

}

void printOperacao(uint32_t x, std::string nome){
    std::cout << "*" << nome << "*" << "\n\n";

    std::bitset<32> binary(x);
    std::cout << "binario: " << binary << std::endl;
    std::cout << "decimal: " << x << std::endl;
    std::cout << "hexadecimal: " << std::hex << x << "\n\n";
}

int main()
{
    uint32_t x = 0b10000001; // número de 32 bits com sinal

    x = x | (x << 8) | (x << 16) | (x << 24);
    uint32_t y = ~x;
    uint32_t z = reverse(x);

    std::cout << "x: " << x << std::endl;
    std::bitset<32> binary_x(x);
    std::cout << "x: " << binary_x << std::endl << std::endl;

    std::cout << "y: " << y << std::endl;
    std::bitset<32> binary_y(y);
    std::cout << "y: " << binary_y << std::endl << std::endl;

    std::cout << "z: " << z << std::endl;
    std::bitset<32> binary_z(z);
    std::cout << "z: " << binary_z << std::endl << std::endl;

    // uint32_t sum0Result = sum0(x); 
    // uint32_t sum1Result = sum1(x); 
    // uint32_t sigma0Result = sigma0(x); 
    // uint32_t sigma1Result = sigma1(x); 
    // uint32_t chResult = ch(x,y,z); 
    // uint32_t majResult = maj(x,y,z); 

    // printOperacao(sum0Result, "sum0");
    // printOperacao(sum1Result, "sum1");
    // printOperacao(sigma0Result, "sigma0");
    // printOperacao(sigma1Result, "sigma1");
    // printOperacao(chResult, "ch");
    // printOperacao(majResult, "maj");

    stepfun(
            x,
            x,
            x,
            x,
            x,
            x,
            x,
            x,
    
            x
           );

    return 0;
}


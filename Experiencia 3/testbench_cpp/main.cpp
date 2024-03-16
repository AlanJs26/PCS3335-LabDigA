/******************************************************************************
   Author: Alan Jose dos Santos (alanjose@usp.br)
   Author: Lucas Franco
   File Name: main.cpp
*******************************************************************************/

#include <iostream>
#include <bitset>
#include <iomanip>
#include <stdint.h>

int32_t reverse(int32_t x)
{
    x = ((x & 0x55555555) << 1) | ((x & 0xAAAAAAAA) >> 1); // Swap _<>_
    x = ((x & 0x33333333) << 2) | ((x & 0xCCCCCCCC) >> 2); // Swap __<>__
    x = ((x & 0x0F0F0F0F) << 4) | ((x & 0xF0F0F0F0) >> 4); // Swap ____<>____
    x = ((x & 0x00FF00FF) << 8) | ((x & 0xFF00FF00) >> 8); // Swap ...
    x = ((x & 0x0000FFFF) << 16) | ((x & 0xFFFF0000) >> 16); // Swap ...
    return x;
}

int32_t rotr(int32_t x, int n){
    return (x >> n) | (x << (32 - n));
}

int32_t ch(int32_t x,int32_t y,int32_t z) {
  return (x & y) ^ (~x & z);
}

int32_t maj(int32_t x,int32_t y,int32_t z) {
  return (x & y) ^ (x & z) ^ (y & z);
}

int32_t sum0(int32_t x) {
  return rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22);
}

int32_t sum1(int32_t x) {
  return rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25);
}

int32_t sigma0(int32_t x) {
  return rotr(x, 7) ^ rotr(x, 18) ^ (x >> 3);
}

int32_t sigma1(int32_t x) {
  return rotr(x, 17) ^ rotr(x, 19) ^ (x >> 10);
}

void printbinary(int32_t x, std::string name){
    std::cout << std::dec << std::left << name << ": " << std::setw(20) << x << std::right << "  binario: " << std::bitset<32>(x) << "  hexadecimal: " << std::hex << x << std::endl;
}

void stepfun(
    int32_t ai,
    int32_t bi,
    int32_t ci,
    int32_t di,
    int32_t ei,
    int32_t fi,
    int32_t gi,
    int32_t hi,
    int32_t kpw
    ){

    int32_t a0 = hi + sum1(ei) + ch(ei,fi,gi) + kpw + sum0(ai) + maj(ai,bi,ci);
    int32_t b0 = ai;
    int32_t c0 = bi;
    int32_t d0 = ci;
    int32_t e0 = di + hi + sum1(ei) + ch(ei,fi,gi) + kpw;
    int32_t f0 = ei;
    int32_t g0 = fi;
    int32_t h0 = gi;

    printbinary(ai, "ai");
    printbinary(bi, "bi");
    printbinary(ci, "ci");
    printbinary(di, "di");
    printbinary(ei, "ei");
    printbinary(fi, "fi");
    printbinary(gi, "gi");
    printbinary(hi, "hi");

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

void printOperacao(int32_t x, std::string nome){
    std::cout << "*" << nome << "*" << "\n\n";

    std::bitset<32> binary(x);
    std::cout << "binario: " << binary << std::endl;
    std::cout << "decimal: " << x << std::endl;
    std::cout << "hexadecimal: " << std::hex << x << "\n\n";
}

int main()
{
    int32_t x = 0b10101010;
    x = x | (x << 8) | (x << 16) | (x << 24);
    int32_t y = ~x;
    int32_t z = reverse(x);

    int32_t sum0Result = sum0(x); 
    int32_t sum1Result = sum1(x); 
    int32_t sigma0Result = sigma0(x); 
    int32_t sigma1Result = sigma1(x); 
    int32_t chResult = ch(x,y,z); 
    int32_t majResult = maj(x,y,z); 

    std::cout << "x: " << x << std::endl;
    std::bitset<32> binary_x(x);
    std::cout << "x: " << binary_x << std::endl << std::endl;

    std::cout << "y: " << y << std::endl;
    std::bitset<32> binary_y(y);
    std::cout << "y: " << binary_y << std::endl << std::endl;

    std::cout << "z: " << z << std::endl;
    std::bitset<32> binary_z(z);
    std::cout << "z: " << binary_z << std::endl << std::endl;

    // printOperacao(sum0Result, "sum0");
    // printOperacao(sum1Result, "sum1");
    // printOperacao(sigma0Result, "sigma0");
    // printOperacao(sigma1Result, "sigma1");
    // printOperacao(chResult, "ch");
    // printOperacao(majResult, "maj");



    stepfun(
            x,
            y,
            z,
            x,
            y,
            z,
            x,
            y,
    
            y
           );

    return 0;
}


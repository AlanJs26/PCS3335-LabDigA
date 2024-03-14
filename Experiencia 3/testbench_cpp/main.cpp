/******************************************************************************
   Author: Alan Jose dos Santos (alanjose@usp.br)
   Author: Lucas Franco
   File Name: main.cpp
*******************************************************************************/

#include <iostream>
#include <bitset>
#include <iomanip>

unsigned long reverse(unsigned long x)
{
    x = ((x & 0x55555555) << 1) | ((x & 0xAAAAAAAA) >> 1); // Swap _<>_
    x = ((x & 0x33333333) << 2) | ((x & 0xCCCCCCCC) >> 2); // Swap __<>__
    x = ((x & 0x0F0F0F0F) << 4) | ((x & 0xF0F0F0F0) >> 4); // Swap ____<>____
    x = ((x & 0x00FF00FF) << 8) | ((x & 0xFF00FF00) >> 8); // Swap ...
    x = ((x & 0x0000FFFF) << 16) | ((x & 0xFFFF0000) >> 16); // Swap ...
    return x;
}

unsigned long rotr(unsigned long x, int n){
    return (x >> n) | (x << (32 - n));
}

unsigned long ch(unsigned long x,unsigned long y,unsigned long z) {
  return (x & y) ^ (~x & z);
}

unsigned long maj(unsigned long x,unsigned long y,unsigned long z) {
  return (x & y) ^ (x & z) ^ (y & z);
}

unsigned long sum0(unsigned long x) {
  return rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22);
}

unsigned long sum1(unsigned long x) {
  return rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25);
}

unsigned long sigma0(unsigned long x) {
  return rotr(x, 7) ^ rotr(x, 18) ^ (x >> 3);
}

unsigned long sigma1(unsigned long x) {
  return rotr(x, 17) ^ rotr(x, 19) ^ (x >> 10);
}

void printbinary(unsigned long x, std::string name){
    std::cout << std::left << name << ": " << std::setw(10) << x << std::right << "  binario: " << std::bitset<32>(x) << std::endl;
}

void stepfun(
    unsigned long ai,
    unsigned long bi,
    unsigned long ci,
    unsigned long di,
    unsigned long ei,
    unsigned long fi,
    unsigned long gi,
    unsigned long hi,
    unsigned long kpw
    ){

    unsigned long a0 = hi + sum1(ei) + ch(ei,fi,gi) + kpw + sum0(ai) + maj(ai,bi,ci);
    unsigned long b0 = ai;
    unsigned long c0 = bi;
    unsigned long d0 = ci;
    unsigned long e0 = di + hi + sum1(ei) + ch(ei,fi,gi) + kpw;
    unsigned long f0 = ei;
    unsigned long g0 = fi;
    unsigned long h0 = gi;

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

void printOperacao(unsigned long x, std::string nome){
    std::cout << "*" << nome << "*" << "\n\n";

    std::bitset<32> binary(x);
    std::cout << "binario: " << binary << std::endl;
    std::cout << "decimal: " << x << std::endl;
    std::cout << "hexadecimal: " << std::hex << x << "\n\n";
}

int main()
{
    unsigned long x = 0b11001100;
    unsigned long y = ~x;
    unsigned long z = reverse(x);
    x = x | (x << 8) | (x << 16) | (x << 24);

    unsigned long sum0Result = sum0(x); 
    unsigned long sum1Result = sum1(x); 
    unsigned long sigma0Result = sigma0(x); 
    unsigned long sigma1Result = sigma1(x); 
    unsigned long chResult = ch(x,y,z); 
    unsigned long majResult = maj(x,y,z); 

    std::cout << "x: " << x << std::endl;
    std::bitset<32> binary_x(x);
    std::cout << "x: " << binary_x << std::endl << std::endl;

    printOperacao(sum0Result, "sum0");
    printOperacao(sum1Result, "sum1");
    printOperacao(sigma0Result, "sigma0");
    printOperacao(sigma1Result, "sigma1");
    printOperacao(chResult, "ch");
    printOperacao(majResult, "maj");



    // stepfun(
    //         1,
    //         2,
    //         3,
    //         4,
    //         5,
    //         6,
    //         7,
    //         8,
    //
    //         12
    //        );

    return 0;
}


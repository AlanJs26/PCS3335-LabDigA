/******************************************************************************

                              Online C++ Compiler.
               Code, Compile, Run and Debug C++ program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <iostream>
#include <bitset>

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


    std::bitset<32> ai_b (ai);
    std::bitset<32> bi_b (bi);
    std::bitset<32> ci_b (ci);
    std::bitset<32> di_b (di);
    std::bitset<32> ei_b (ei);
    std::bitset<32> fi_b (fi);
    std::bitset<32> gi_b (gi);
    std::bitset<32> hi_b (hi);


    std::bitset<32> a0_b (a0);
    std::bitset<32> b0_b (b0);
    std::bitset<32> c0_b (c0);
    std::bitset<32> d0_b (d0);
    std::bitset<32> e0_b (e0);
    std::bitset<32> f0_b (f0);
    std::bitset<32> g0_b (g0);
    std::bitset<32> h0_b (h0);

    std::cout << "ai: " << ai << "  binario: " << ai_b << std::endl;
    std::cout << "bi: " << bi << "  binario: " << bi_b << std::endl;
    std::cout << "ci: " << ci << "  binario: " << ci_b << std::endl;
    std::cout << "di: " << di << "  binario: " << di_b << std::endl;
    std::cout << "ei: " << ei << "  binario: " << ei_b << std::endl;
    std::cout << "fi: " << fi << "  binario: " << fi_b << std::endl;
    std::cout << "gi: " << gi << "  binario: " << gi_b << std::endl;
    std::cout << "hi: " << hi << "  binario: " << hi_b << std::endl;

    std::cout << std::endl;

    std::cout << "a0: " << a0 << "  binario: " << a0_b << std::endl;
    std::cout << "b0: " << b0 << "  binario: " << b0_b << std::endl;
    std::cout << "c0: " << c0 << "  binario: " << c0_b << std::endl;
    std::cout << "d0: " << d0 << "  binario: " << d0_b << std::endl;
    std::cout << "e0: " << e0 << "  binario: " << e0_b << std::endl;
    std::cout << "f0: " << f0 << "  binario: " << f0_b << std::endl;
    std::cout << "g0: " << g0 << "  binario: " << g0_b << std::endl;
    std::cout << "h0: " << h0 << "  binario: " << h0_b << std::endl;
}

int main()
{
    unsigned long x = 0b10000001;
    unsigned long y = ~x;
    unsigned long z = reverse(x);
    x = x | (x << 8) | (x << 16) | (x << 24);

    // unsigned long result = maj(x,y,z); 
    //
    // std::cout << "x: " << x << std::endl;
    // std::bitset<32> binary_x(x);
    // std::cout << "x: " << binary_x << std::endl << std::endl;
    //
    // std::bitset<32> binary(result);
    // std::cout << "binario: " << binary << std::endl;
    // std::cout << "decimal: " << result << std::endl;
    // std::cout << "hexadecimal: " << std::hex << result << std::endl;

    stepfun(
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,

            12
           );

    return 0;
}


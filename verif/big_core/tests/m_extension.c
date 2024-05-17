// for software compilation : ./build.py -dut big_core -test m_extension -app  -cfg big_core_rv32im
// for simulation run:        ./build.py -dut big_core -test m_extension -app -hw -sim -cfg big_core_rv32im

int main() {

    //int a = 200000;  // 32'h30d40
    //int b = 300000;  // 32'h493e0

    // -------------------------------------------------------------------------------------
    // in case of a,b both positive than all the results will be the same.
    // for example: in case if a = 32'd200000 and b = 32'd300000. mul_res = 32'hf8475800
    // and all other variables will be equal to 32'h0000000d
    // --------------------------------------------------------------------------------------
    
    int a = 200000;  
    int b = -300000; 

    // ----------------------------------------------------------------------------------------------------------
    // in case of a positive and b negative for example. a = 32'd200000 and b = -300000
    // the full result will be 0xFFFFFF207B8A800.
    // mul_res  = 0x07b8a800.
    // mulh_res = 0xffffff2
    // mulhsu -> will treat positive number with or without $signed as 200000, b will be treated as
    // positive number. The result is 32'h00030d32.
    // lets make simple example: assume b = -3 and we use 4 bit width. b in signed equals 1101
    // and in unsigned it will be treated as 13.
    // mulhsu - we will get the same result because positive number are treated the same in signed or unsigned
    // -----------------------------------------------------------------------------------------------------------


    int mul_res;
    long long mulh_res;
    unsigned long long mulhu_res, mulhsu_res;

    // Multiply and store the result
    __asm__ volatile ("mul %0, %1, %2" : "=r"(mul_res) : "r"(a), "r"(b));

    // Multiply and store the high part of the signed result
    __asm__ volatile ("mulh %0, %1, %2" : "=r"(mulh_res) : "r"(a), "r"(b));

    // Multiply and store the high part of the unsigned result
    __asm__ volatile ("mulhu %0, %1, %2" : "=r"(mulhu_res) : "r"(a), "r"(b));

    // Multiply and store the high part of the mixed signed-unsigned result
    __asm__ volatile ("mulhsu %0, %1, %2" : "=r"(mulhsu_res) : "r"(a), "r"(b));


    return 0;
}
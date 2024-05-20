
// ------------------------------------------------------------------------------------------------
// In that test we check multiply instructions
// for software compilation : ./build.py -dut big_core -test m_extension -app  -cfg big_core_rv32im
// for simulation run       : ./build.py -dut big_core -test m_extension -app -hw -sim -cfg big_core_rv32im
// ------------------------------------------------------------------------------------------------
#include "interrupt_handler.h"

int main() {

    //int a = 200000;  // 32'h30d40
    //int b = 300000;  // 32'h493e0
 
    int a = 200000;  
    int b = -300000; 

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


    int dividend = 34;
    int divisor  = 7;

    int div_res;
    unsigned int divu_res;
    int rem_res;
    unsigned int remu_res;

    // Performe signed division and sore the results
    __asm__ volatile ("div %0, %1, %2" : "=r"(div_res) : "r"(dividend), "r"(divisor));
    rvc_print_int(div_res);
    rvc_printf("\n");

    
    // Performe unsigned division and sore the results
    __asm__ volatile ("divu %0, %1, %2" : "=r"(divu_res) : "r"(dividend), "r"(divisor));
    rvc_print_int(divu_res);
    rvc_printf("\n");

    // Performe signed reminder and sore the results
    __asm__ volatile ("rem %0, %1, %2" : "=r"(rem_res) : "r"(dividend), "r"(divisor));
    rvc_print_int(rem_res); 
    rvc_printf("\n");

    // Performe signed reminder and sore the results
    __asm__ volatile ("remu %0, %1, %2" : "=r"(remu_res) : "r"(dividend), "r"(divisor));
    rvc_print_int(remu_res);

    return 0;
}
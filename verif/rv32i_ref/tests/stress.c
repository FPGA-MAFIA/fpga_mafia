#include "big_core_defines.h"
#include "graphic_vga.h"

// Integer Register-Immediate Instructions test function
void test_reg_imm() {
    int x = 5;
    
    x = x + 1;  // ADDI
    rvc_print_int(x);  // Expected: 6
    rvc_printf(" ");
    
    x = x ^ 3;  // XORI
    rvc_print_int(x);  // Expected: 5
    rvc_printf(" ");
    
    x = x | 2;  // ORI
    rvc_print_int(x);  // Expected: 7
    rvc_printf(" ");
    
    x = x & 4;  // ANDI
    rvc_print_int(x);  // Expected: 4
    rvc_printf(" ");
    
    x = x << 1; // SLLI
    rvc_print_int(x);  // Expected: 8
    rvc_printf(" ");
    
    x = x >> 1; // SRLI (Assuming x is unsigned)
    rvc_print_int(x);  // Expected: 4
    rvc_printf(" ");
}

// Integer Register-Register Instructions test function
void test_reg_reg() {
    int x = 10;
    int y = 5;
    int z;

    z = x + y;    // ADD
    rvc_print_int(z);  // Expected: 15
    rvc_printf(" ");
    
    z = x - y;    // SUB
    rvc_print_int(z);  // Expected: 5
    rvc_printf(" ");
    
    z = x << y;   // SLL
    rvc_print_int(z);  // Expected: 320
    rvc_printf(" ");
    
    z = x >> y;   // SRL (Assuming x is unsigned)
    rvc_print_int(z);  // Expected: 0
    rvc_printf(" ");
}

// Load and Store Instructions test function
void test_load_store() {
    // LW and SW
    int arr[5];
    arr[0] = 10;   // SW: word
    arr[1] = arr[0]; // LW: word
    rvc_print_int(arr[1]);  // Expected: 10
    rvc_printf(" ");

    // LB, LBU, SB
    char chars[5];
    chars[0] = 'a';   // SB: byte
    chars[1] = chars[0]; // LB: byte signed
    rvc_print_int(chars[1]);  // Expected: 97
    rvc_printf(" ");
    
    unsigned char uchars[5];
    uchars[0] = 255; // SB: byte
    uchars[1] = uchars[0]; // LBU: byte unsigned
    rvc_print_int(uchars[1]);  // Expected: 255
    rvc_printf(" ");

    // LH, LHU, SH
    short sharr[5];
    sharr[0] = 32767; // SH: half word
    sharr[1] = sharr[0]; // LH: half word signed
    rvc_print_int(sharr[1]);  // Expected: 32767
    rvc_printf(" ");
    
    unsigned short usharr[5];
    usharr[0] = 65535; // SH: half word
    usharr[1] = usharr[0]; // LHU: half word unsigned
    rvc_print_int(usharr[1]);  // Expected: 65535
    rvc_printf(" ");
}


// Control Transfer Instructions test function
void test_control_transfer(int x, int y, int sel) {
    switch(sel) {
        case 1:  // BEQ
            if (x == y) rvc_print_int(100);
            break;
        case 2:  // BNE
            if (x != y) rvc_print_int(200);
            break;
        case 3:  // BLT
            if (x < y) rvc_print_int(300);
            break;
        case 4:  // BGE
            if (x >= y) rvc_print_int(400);
            break;
        case 5:  // BLTU (using positive values to ensure logical results)
            if ((unsigned)x < (unsigned)y) rvc_print_int(500);
            break;
        case 6:  // BGEU (using positive values to ensure logical results)
            if ((unsigned)x >= (unsigned)y) rvc_print_int(600);
            break;
        default:
            break;
    }
    rvc_printf(" ");
}

int main() {
    rvc_printf("ONE \n");
    test_reg_imm();
    rvc_printf("\n TWO \n");
    test_reg_reg();
    rvc_printf("\n THREE \n");
    test_load_store();
    rvc_printf("\n FOR \n");
    test_control_transfer(5, 10, 1);   // Expected: None
    test_control_transfer(5, 10, 2);   // Expected: 200
    test_control_transfer(5, 10, 3);   // Expected: 300
    test_control_transfer(5, 10, 4);   // Expected: None
    test_control_transfer(5, 10, 5);   // Expected: 500
    test_control_transfer(5, 10, 6);   // Expected: None

    test_control_transfer(10, 5, 1);   // Expected: None
    test_control_transfer(10, 5, 2);   // Expected: 200
    test_control_transfer(10, 5, 3);   // Expected: None
    test_control_transfer(10, 5, 4);   // Expected: 400
    test_control_transfer(10, 5, 5);   // Expected: None
    test_control_transfer(10, 5, 6);   // Expected: 600

    test_control_transfer(-10, -5, 1); // Expected: None
    test_control_transfer(-10, -5, 2); // Expected: 200
    test_control_transfer(-10, -5, 3); // Expected: 300
    test_control_transfer(-10, -5, 4); // Expected: None
    test_control_transfer(-10, -5, 5); // Expected: (Depends on representation and if values are valid as unsigned)
    test_control_transfer(-10, -5, 6); // Expected: (Depends on representation and if values are valid as unsigned)

    test_control_transfer(5, 5, 1);    // Expected: 100
    test_control_transfer(5, 5, 2);    // Expected: None
    test_control_transfer(5, 5, 3);    // Expected: None
    test_control_transfer(5, 5, 4);    // Expected: 400
    test_control_transfer(5, 5, 5);    // Expected: None (equal)
    test_control_transfer(5, 5, 6);    // Expected: 600

    return 0;
}

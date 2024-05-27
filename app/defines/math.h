#ifndef MATH_H  // Check if GRAPHIC_VGA_H is not defined
#define MATH_H  // Define GRAPHIC_VGA_H

#define INT_MAX 2147483647
#define INT_MIN (-INT_MAX - 1)
#define UINT_MAX 4294967295U


//================================================
//            Standard functions
// ===============================================
//------------------------------------------------
// 1. pow - calculate pow.
//------------------------------------------------

// calculate power of integer numbers with integer exponent
int pow(int base, int exp) {
	int result = 1;

	for (int i = 0; i < exp; i++)
		result *= base;

	return result;
}


//================================================
//        M-extensios division functions
// ===============================================
//------------------------------------------------
// 1. div  - m extension division.
// 2. divu - m extension unsigned division. 
// 3. rem  - m extension division reminder.
// 4. remu - m extension division unsigned reminder.
//------------------------------------------------

// Function implementing DIV, DIVU, REM and REMU 
// Helper function to safely compute the absolute value of an integer
int safe_abs(int x) {
    if (x < 0) {
        return (x == INT_MIN ? INT_MAX : -x);
    }
    return x;
}

// Signed Division using bitwise long division
int div(int rs1, int rs2) {
    if (rs2 == 0) {
        return INT_MAX;  // Handle division by zero
    } else if (rs1 == INT_MIN && rs2 == -1) {
        return INT_MAX;  // Handle overflow when rs1 is INT_MIN and rs2 is -1
    }

    int sign = ((rs1 < 0) ^ (rs2 < 0)) ? -1 : 1;
    unsigned int num = safe_abs(rs1);
    unsigned int den = safe_abs(rs2);
    unsigned int quotient = 0;
    unsigned int shift = 0;

    while (den <= num && den < 0x80000000) {  // prevent den from being shifted beyond the bounds of unsigned int
        den <<= 1;
        shift++;
    }

    while (shift-- > 0) {
        den >>= 1;
        quotient <<= 1;
        if (num >= den) {
            num -= den;
            quotient |= 1;
        }
    }

    return sign * quotient;
}

// Unsigned Division using bitwise long division
unsigned divu(unsigned rs1, unsigned rs2) {
    if (rs2 == 0) {
        return UINT_MAX;  // Handle division by zero
    }

    unsigned quotient = 0, shift = 0;
    while (rs2 <= rs1 && rs2 < 0x80000000) {  // prevent rs2 from being shifted beyond the bounds of unsigned int
        rs2 <<= 1;
        shift++;
    }

    while (shift-- > 0) {
        rs2 >>= 1;
        quotient <<= 1;
        if (rs1 >= rs2) {
            rs1 -= rs2;
            quotient |= 1;
        }
    }

    return quotient;
}

// Signed Remainder using the result from div
int rem(int rs1, int rs2) {
    if (rs2 == 0) {
        return rs1;  // Remainder by zero equals the dividend
    } else if (rs1 == INT_MIN && rs2 == -1) {
        return 0;  // Handle special overflow case
    }

    int quotient = div(rs1, rs2);
    return rs1 - quotient * rs2;
}

// Unsigned Remainder using the result from divu
unsigned remu(unsigned rs1, unsigned rs2) {
    if (rs2 == 0) {
        return rs1;  // Remainder by zero equals the dividend
    }

    unsigned quotient = divu(rs1, rs2);
    return rs1 - quotient * rs2;
}



// TODO - check the proper functionality of the function is special cases
// print cpi value as remainder and quotient
void fix_div(int numerator, int denominator, int* quo, int* rem) {
    int precision = 3;;
	int sign_numerator   = (numerator > 0) ? 1 : -1;
	int sign_denominator = (denominator > 0) ? 1 : -1;

	// convert to positive
	numerator *= sign_numerator;
	denominator *= sign_denominator;

	*quo = numerator / denominator;
	*rem = (((numerator) % denominator) * pow(10, precision)) / denominator;
	
	// remove zeros from right
	while (!(*rem % 10) && *rem!=0)
		*rem /= 10;

	if (sign_numerator * sign_denominator == -1)
		*quo = -1 * (*quo);
}


#endif // MATH_H
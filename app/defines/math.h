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

// Signed Division
int div(int rs1, int rs2) {
    if (rs2 == 0) {
        return INT_MAX; // Division by zero, return max int value
    } else if (rs1 == INT_MIN && rs2 == -1) {
        return INT_MIN; // Overflow case
    }

    int sign = ((rs1 < 0) ^ (rs2 < 0)) ? -1 : 1;
    unsigned int num = safe_abs(rs1);
    unsigned int den = safe_abs(rs2);
    unsigned int res = 0;

    while (num >= den) {
        num -= den;
        res++;
    }

    return sign * res;
}

// Unsigned Division
unsigned divu(unsigned rs1, unsigned rs2) {
    if (rs2 == 0) {
        return UINT_MAX; // Division by zero, return max unsigned int value
    }

    unsigned res = 0;
    while (rs1 >= rs2) {
        rs1 -= rs2;
        res++;
    }

    return res;
}

// Signed Remainder
int rem(int rs1, int rs2) {
    if (rs2 == 0) {
        return rs1; // Remainder by zero equals the dividend
    } else if (rs1 == INT_MIN && rs2 == -1) {
        return 0; // Overflow case
    }

    int sign = (rs1 < 0) ? -1 : 1;
    unsigned int num = safe_abs(rs1);
    unsigned int den = safe_abs(rs2);

    while (num >= den) {
        num -= den;
    }

    return sign * num;
}

// Unsigned Remainder
unsigned remu(unsigned rs1, unsigned rs2) {
    if (rs2 == 0) {
        return rs1; // Remainder by zero equals the dividend
    }

    while (rs1 >= rs2) {
        rs1 -= rs2;
    }

    return rs1;
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
// calculate power of integer numbers with integer exponent
int pow(int base, int exp) {
	int result = 1;

	for (int i = 0; i < exp; i++)
		result *= base;

	return result;
}

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

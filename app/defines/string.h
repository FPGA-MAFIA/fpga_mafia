#ifndef STRINGS_H
#define STRINGS_H

int atoi(const char *str) {
    int result = 0;
    int sign = 1;
    int i = 0;
    
    // Skip leading whitespaces
    while (str[i] == ' ') {
        i++;
    }
    
    // Check for sign
    if (str[i] == '+' || str[i] == '-') {
        sign = (str[i++] == '-') ? -1 : 1;
    }
    
    // Convert digits to integer
    while (str[i] >= '0' && str[i] <= '9') {
        result = result * 10 + (str[i++] - '0');
    }
    
    return sign * result;
}

int strlen(const char *str) {
    int len = 0;
    
    while (str[len] != '\0') {
        len++;
    }
    
    return len;
}


#endif // STRINGS_H

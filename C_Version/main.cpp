#include <iostream>

int main() {
    // X and Y to be multiplied, ans is their product.
    int16_t x = 0xC0A0;
    int16_t y = 0x4053;

    //Processed X's Mantissa as mant1
    int16_t mant1 = (0x7F & x) | (1 << 7);
    int count1 = 0;
    while ((mant1 & 1) == 0) {
        mant1 = mant1 >> 1;
        count1++;
    }

    //Processed Y's Mantissa as mant2
    int16_t mant2 = (0x7F & y) | (1 << 7);
    int count2 = 0;
    while ((mant2 & 1) == 0) {
        mant2 = mant2 >> 1;
        count2++;
    }

    // Multiplication of mantissa, mant1 becomes the result mantissa, 14-count1-count2 is the decimal point
    mant1 = mant1 * mant2;
    int16_t norm = 0x1 << (14 - count1 - count2);
    int offset = 0;
    if ((norm & mant1) != 0) {   //When no need to normalize
        mant1 = mant1 ^ norm;
    }
    else {              // When need to normalize
        mant1 = mant1 >> 1;
        mant1 = mant1 ^ norm;
        offset++;
    }

    // Shift the mantissa to appropriate position for float16
    int digit = 7 - (14 - count1 - count2);
    if (digit > 0) {
        mant1 = mant1 << digit;
    }
    else if (digit < 0) {
        mant1 = mant1 >> (7 - count1 - count2);
    }


    //Sign bit
    int16_t x_sign = (0x1 << 15) & x, y_sign = (0x1 << 15) & y;

    //Exponent
    int16_t x_exp = ((0xFF << 7) & (x)) >> 7, y_exp = ((0xFF << 7) & (y)) >> 7;
    int16_t ans_exp = (x_exp + y_exp - 127 + offset) << 7;

    //ans is the final product that we need to return
    int16_t ans = 0;

    //Assemble every component
    ans = ans | x_sign^y_sign;
    ans = ans | ans_exp;
    ans = ans | mant1;

    //Print the result
    std::cout<<std::hex<<ans<<std::endl;


    return 0;
}

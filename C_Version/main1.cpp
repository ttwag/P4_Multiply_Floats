#include <iostream>

int main() {
    // X and Y to be multiplied, ans is their product.
    int16_t x = 0x3F80;
    int16_t y = 0xC0A0;

    //Processed X's Mantissa as mant1
    int16_t mant1 = (0x7F & x) | (1 << 7);
    int16_t mant2 = (0x7F & y) | (1 << 7);

    mant1 = mant1 * mant2;

    // Multiplication of mantissa, mant1 becomes the result mantissa, 14-count1-count2 is the decimal point
    int16_t norm = 0x1 << (14);
    int offset = 0;
    if ((norm & mant1) != 0) {   //When no need to normalize
        mant1 = mant1 ^ norm;
    }
    else {              // When need to normalize
        mant1 = mant1 >> 1;
        mant1 = mant1 ^ norm;
        offset++;
    }

    // Extract then shift the mantissa to appropriate position for float16
    mant1 = mant1 & (0x7F << 7);
    mant1 = mant1 >> 7;

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
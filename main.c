#include <stdint.h>

#include "addone.h"
#include "subone.h"

// @brief main
int32_t main(void);

// @brief main
int32_t main(void)
{
    int32_t x = 3;

    addone(&x);
    subone(&x);

    return (int32_t)x;
}


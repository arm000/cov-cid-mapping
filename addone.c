#include <limits.h>

#include "addone.h"
#include "v1/iface.h"

void addone(int32_t *p)
{
    if (TEST_NULL(p)) {
        /* coverity[misra_c_2012_rule_15_1_violation] */
        goto fail;
    }

    if (*p == INT_MAX) {
        goto fail;
    }

    (*p)++;

 fail:
    return;
}

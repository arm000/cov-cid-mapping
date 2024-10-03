#include <limits.h>

#include "subone.h"
#include "v2/iface.h"

void subone(int32_t *p)
{
    if (TEST_NULL(p)) {
        goto fail;
    }

    if (*p == INT_MIN) {
        goto fail;
    }

    (*p)--;

 fail:
    return;
}


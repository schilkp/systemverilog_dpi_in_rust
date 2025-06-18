#ifndef C_FOO_H
#define C_FOO_H

#include "svdpi.h"
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

void foo_c(const svLogicVecVal *input, svLogicVecVal *out);

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus

#endif /* C_FOO_H */

#include "./dpi.h"
#include <stdio.h>

void foo_c(const svLogicVecVal *input, svLogicVecVal *out) {
  if (input == 0 || out == 0) {
    fprintf(stderr, "ZERO-PTR!\r\n");
    return;
  }
  out->aval = (input->aval + 30) % 256;
  out->bval = 0;
}

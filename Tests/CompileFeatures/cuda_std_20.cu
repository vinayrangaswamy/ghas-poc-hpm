#include "cxx_std.h"
#if defined(CXX_STD) && CXX_STD <= CXX_STD_17
#  error "cuda_std_20 not honored"
#endif

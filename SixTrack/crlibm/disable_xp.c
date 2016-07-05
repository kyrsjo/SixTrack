/* Initialise the IA32/64 FPU flags from Fortran */
/* An init function which sets FPU flags when needed */

#ifdef __APPLE__

void disable_xp_(void)
{
}

#elif defined(_WIN32) //_WIN32 means we're not running 16-bit Windows, i.e. it can be either 32- or 64-bit.

#include <float.h>

void disable_xp_(void)
{
#ifndef _WIN64
  _controlfp(_PC_53, _MCW_PC);
#endif
}

#else

#include <fpu_control.h>

void disable_xp_(void)
{
  /* Set FPU flags to use double, not double extended,
     with rounding to nearest */
  short unsigned int cw = (_FPU_DEFAULT & ~_FPU_EXTENDED)|_FPU_DOUBLE;
  _FPU_SETCW(cw);
}

#endif


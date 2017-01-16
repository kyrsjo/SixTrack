// To compile:
// gcc -std=c99 -Wall -W -pedantic test_fpuctl.c -o test_fpuctl

//#include "fpuctl.h"

#include <inttypes.h>
#include <immintrin.h>
#include <x86intrin.h>
#include <stdio.h>

// For comparison; Defines _FPU_GETCW and _FPU_SETCW + various bitmasks.
#if defined(__linux__) || defined(__apple__)

#include <fpu_control.h> 

#else

// Copy-pasted from fpu_control.h:

/* Note that this file sets on x86-64 only the x87 FPU, it does not
   touch the SSE unit.  */

/* Here is the dirty part. Set up your 387 through the control word
 * (cw) register.
 *
 *     15-13    12  11-10  9-8     7-6     5    4    3    2    1    0
 * | reserved | IC | RC  | PC | reserved | PM | UM | OM | ZM | DM | IM
 *
 * IM: Invalid operation mask
 * DM: Denormalized operand mask
 * ZM: Zero-divide mask
 * OM: Overflow mask
 * UM: Underflow mask
 * PM: Precision (inexact result) mask
 *
 * Mask bit is 1 means no interrupt.
 *
 * PC: Precision control
 * 11 - round to extended precision
 * 10 - round to double precision
 * 00 - round to single precision
 *
 * RC: Rounding control
 * 00 - rounding to nearest
 * 01 - rounding down (toward - infinity)
 * 10 - rounding up (toward + infinity)
 * 11 - rounding toward zero
 *
 * IC: Infinity control
 * That is for 8087 and 80287 only.
 *
 * The hardware default is 0x037f which we use.
 */


/* masking of interrupts */
#define _FPU_MASK_IM  0x01
#define _FPU_MASK_DM  0x02
#define _FPU_MASK_ZM  0x04
#define _FPU_MASK_OM  0x08
#define _FPU_MASK_UM  0x10
#define _FPU_MASK_PM  0x20

/* precision control */
#define _FPU_EXTENDED 0x300	/* libm requires double extended precision.  */
#define _FPU_DOUBLE   0x200
#define _FPU_SINGLE   0x0

/* rounding control */
#define _FPU_RC_NEAREST 0x0    /* RECOMMENDED */
#define _FPU_RC_DOWN    0x400
#define _FPU_RC_UP      0x800
#define _FPU_RC_ZERO    0xC00

#define _FPU_RESERVED 0xF0C0  /* Reserved bits in cw */


/* The fdlibm code requires strict IEEE double precision arithmetic,
   and no interrupts for exceptions, rounding to nearest.  */

#define _FPU_DEFAULT  0x037f

/* IEEE:  same as above.  */
#define _FPU_IEEE     0x037f

/* Type of the control word.  */
typedef unsigned int fpu_control_t __attribute__ ((__mode__ (__HI__)));

#endif

uint16_t getCW_x87(){
  // Read the x87 state
  char* buff = calloc(512,1);
  _fxsave(buff);
  uint16_t cw=(*buff) + (*(buff+1)<<8);
  free(buff);
  return cw;
}

#ifndef _WIN32
fpu_control_t getCW_x87_2(){
  // Read the x87 state, using float.h
  fpu_control_t cw = 0;
  _FPU_GETCW(cw);
  return cw;
}
#endif

void print_x87() {
  uint16_t cw=getCW_x87();
  printf("cw:  %0" PRIu16 " [ 0x%" PRIx16 " ]\n", cw,cw);

#ifndef _WIN32
  fpu_control_t cw2 = getCW_x87_2();
  printf("cw2: %" PRIu16 " [ 0x%" PRIx16 " ]\n", cw2, cw2);
#endif
}

int main(){
  print_x87();

  // Set x87 state - round nearest, double precission
  uint16_t newCw = (_FPU_DEFAULT & ~_FPU_EXTENDED)|_FPU_DOUBLE;
  char* buff = calloc(512,1);
  _fxsave(buff); //Load current data
  buff[0] = newCw & 0xFF;
  buff[1] = (newCw & (0xFF<<8))>>8;
  printf("newCW:  %0" PRIu16 " [ 0x%" PRIx16 " ]\n", newCw,newCw);
  _fxrstor(buff);
  
  print_x87();
}

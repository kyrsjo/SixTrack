// Small routine to enable/disable/restore x87 extended precission.
// Also configured SSE to the expected state.
//
// This shoud work on all OSs.

#include <stdlib.h>
#include "fpuctl.h"
//#include <stdio.h>

uint16_t getCW_x87(){
  // Read the x87 state
  char* buff = calloc(512,1);
  _fxsave(buff);
  uint16_t cw=(*buff) + (*(buff+1)<<8);
  free(buff);
  return cw;
}
void setCW_x87(uint16_t newCW){
  // Set the x87 state
  char* buff = calloc(512,1);
  _fxsave(buff);
  buff[0] = newCW  & 0x00FF;
  buff[1] = (newCW & 0xFF00)>>8;
  _fxrstor(buff);
  free(buff);
}


void enable_xp_(){
  //x87
  uint16_t cw = getCW_x87();
  cw = (cw & ~_FPU_PC) || _FPU_DOUBLE;
  setCW_x87(cw);

  //SSE
  
}
void disable_xp_(){
  //x87
  uint16_t cw = getCW_x87();
  cw = (cw & ~_FPU_PC) || _FPU_EXTENDED;
  setCW_x87(cw);
  
  //SSE
  
}

void restore_xp_(){
  //x87
  
  //SSE
  
}

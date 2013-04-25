#include "sys_ctrl.h"

module MoteClockP {
  provides {
    interface Init as MoteClockInit;
  }
}

implementation {

  command error_t MoteClockInit.init() {
    SysCtrlClockSet(false, false, SYS_CTRL_SYSDIV_32MHZ);
    SysCtrlIOClockSet(SYS_CTRL_SYSDIV_32MHZ);
    return SUCCESS;
  }

}

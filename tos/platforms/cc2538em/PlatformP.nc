#include "hardware.h"
#include "sys_ctrl.h"

module PlatformP {
  provides {
    interface Init;
  }
  uses {
    interface Init as MoteClockInit;
    interface Init as LedsInit;
//    interface Leds;
  }
}
implementation {

  command error_t Init.init() {

    // Set the default deep sleep power mode to PM2
    SysCtrlPowerModeSet(SYS_CTRL_PM_2);

    call MoteClockInit.init();
    call LedsInit.init();

    return SUCCESS;
  }

  // Fallback interface for LEDs if LedsC is not
  // used.
  default command error_t LedsInit.init() {
    return SUCCESS;
  }

}
